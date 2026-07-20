import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/app_models.dart';

class ProjectRepository {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  static const Duration _uploadTimeout = Duration(seconds: 45);

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Please login first.');
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _projects =>
      _firestore.collection('users').doc(_uid).collection('projects');

  CollectionReference<Map<String, dynamic>> get _chatHistory =>
      _firestore.collection('users').doc(_uid).collection('chat_history');

  Future<String> uploadDesignImage(Uint8List bytes, String fileName) async {
    return _uploadToCloudinary(
      bytes: bytes,
      fileName: fileName,
      folder: 'users/$_uid/generated',
    );
  }

  Future<String> uploadReferenceImage(Uint8List bytes, String fileName) async {
    return _uploadToCloudinary(
      bytes: bytes,
      fileName: fileName,
      folder: 'users/$_uid/reference',
    );
  }

  Future<void> saveProject({
    required String type,
    required String style,
    required String prompt,
    required String generatedImageUrl,
    String referenceImageUrl = '',
  }) async {
    await _projects.add({
      'type': type,
      'style': style,
      'prompt': prompt,
      'generatedImageUrl': generatedImageUrl,
      'referenceImageUrl': referenceImageUrl,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<DesignProject>> watchProjects() {
    return _projects.orderBy('createdAt', descending: true).snapshots().map((
      snap,
    ) {
      return snap.docs
          .map((d) => DesignProject.fromMap(d.id, d.data()))
          .toList();
    });
  }

  Future<void> deleteProject(String id) async {
    await _projects.doc(id).delete();
  }

  Future<void> saveAssistantMessage(AssistantMessage message) async {
    await _chatHistory.add(message.toMap());
  }

  Future<ProjectSaveResult> saveGeneratedProjectWithFallback({
    required String type,
    required String style,
    required String prompt,
    required Uint8List generatedImageBytes,
    required Uint8List referenceImageBytes,
  }) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final refUrl = await uploadReferenceImage(
        referenceImageBytes,
        '${now}_ref.jpg',
      );
      final generatedUrl = await uploadDesignImage(
        generatedImageBytes,
        '${now}_generated.png',
      );
      await saveProject(
        type: type,
        style: style,
        prompt: prompt,
        generatedImageUrl: generatedUrl,
        referenceImageUrl: refUrl,
      );
      return const ProjectSaveResult.saved();
    } on UploadFailure catch (e) {
      if (!e.retryable) rethrow;
      await _enqueuePendingTask(
        type: type,
        style: style,
        prompt: prompt,
        generatedImageBytes: generatedImageBytes,
        referenceImageBytes: referenceImageBytes,
      );
      final pendingCount = await getPendingUploadCount();
      return ProjectSaveResult.queued(pendingCount: pendingCount);
    }
  }

  Future<int> getPendingUploadCount() async {
    final tasks = await _readPendingTasks();
    return tasks.length;
  }

  Future<PendingUploadRetryResult> retryPendingUploads() async {
    final tasks = await _readPendingTasks();
    if (tasks.isEmpty) return const PendingUploadRetryResult();

    final remaining = <_PendingUploadTask>[];
    var uploadedCount = 0;
    String? lastError;

    for (final task in tasks) {
      try {
        final generatedFile = File(task.generatedImagePath);
        final referenceFile = File(task.referenceImagePath);
        if (!await generatedFile.exists() || !await referenceFile.exists()) {
          lastError = 'Pending files missing.';
          continue;
        }

        final generatedBytes = await generatedFile.readAsBytes();
        final referenceBytes = await referenceFile.readAsBytes();

        final refUrl = await uploadReferenceImage(
          referenceBytes,
          '${DateTime.now().millisecondsSinceEpoch}_${task.id}_ref.jpg',
        );
        final generatedUrl = await uploadDesignImage(
          generatedBytes,
          '${DateTime.now().millisecondsSinceEpoch}_${task.id}_generated.png',
        );

        await saveProject(
          type: task.type,
          style: task.style,
          prompt: task.prompt,
          generatedImageUrl: generatedUrl,
          referenceImageUrl: refUrl,
        );
        uploadedCount += 1;
        await _deletePendingTaskFiles(task);
      } on UploadFailure catch (e) {
        lastError = e.message;
        remaining.add(task);
      } catch (e) {
        lastError = e.toString();
        remaining.add(task);
      }
    }

    await _writePendingTasks(remaining);
    return PendingUploadRetryResult(
      uploadedCount: uploadedCount,
      remainingCount: remaining.length,
      lastError: lastError,
    );
  }

  Future<String> _uploadToCloudinary({
    required Uint8List bytes,
    required String fileName,
    required String folder,
  }) async {
    final cloudinaryUrl = dotenv.env['CLOUDINARY_URL']?.trim() ?? '';
    if (cloudinaryUrl.isEmpty) {
      throw Exception(
        'Cloudinary config missing. Please set CLOUDINARY_URL in .env.',
      );
    }
    final parsed = _parseCloudinaryUrl(cloudinaryUrl);
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final signature = _buildSignature(
      apiSecret: parsed.apiSecret,
      folder: folder,
      timestamp: timestamp,
    );

    final request =
        http.MultipartRequest(
            'POST',
            Uri.parse(
              'https://api.cloudinary.com/v1_1/${parsed.cloudName}/image/upload',
            ),
          )
          ..fields['api_key'] = parsed.apiKey
          ..fields['folder'] = folder
          ..fields['timestamp'] = '$timestamp'
          ..fields['signature'] = signature
          ..files.add(
            http.MultipartFile.fromBytes('file', bytes, filename: fileName),
          );

    http.StreamedResponse streamed;
    try {
      streamed = await request.send().timeout(_uploadTimeout);
    } on SocketException {
      throw const UploadFailure(
        'No internet connection. Upload queued and will retry later.',
        retryable: true,
      );
    } on TimeoutException {
      throw const UploadFailure(
        'Upload timed out. Upload queued and will retry later.',
        retryable: true,
      );
    } on http.ClientException {
      throw const UploadFailure(
        'Network error during upload. Upload queued and will retry later.',
        retryable: true,
      );
    }

    final response = await http.Response.fromStream(streamed);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final msg = _extractCloudinaryError(response.statusCode, response.body);
      final retryable =
          response.statusCode == 408 ||
          response.statusCode == 429 ||
          response.statusCode >= 500;
      throw UploadFailure(msg, retryable: retryable);
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final secureUrl = json['secure_url']?.toString() ?? '';
    if (secureUrl.isEmpty) {
      throw const UploadFailure(
        'Cloudinary upload succeeded but no secure URL returned.',
        retryable: true,
      );
    }
    return secureUrl;
  }

  String _extractCloudinaryError(int statusCode, String body) {
    String? msg;
    try {
      final parsed = jsonDecode(body) as Map<String, dynamic>;
      final error = parsed['error'];
      if (error is Map<String, dynamic>) {
        msg = error['message']?.toString();
      }
    } catch (_) {
      msg = null;
    }

    if (statusCode == 401 || statusCode == 403) {
      return 'Cloudinary credentials are invalid.';
    }
    if (statusCode == 429) {
      return 'Cloudinary rate limit exceeded. Please retry shortly.';
    }
    if (statusCode >= 500) {
      return 'Cloudinary server is temporarily unavailable.';
    }
    return msg?.trim().isNotEmpty == true
        ? 'Cloudinary upload failed ($statusCode): ${msg!.trim()}'
        : 'Cloudinary upload failed ($statusCode).';
  }

  String get _pendingTasksStorageKey => 'pending_upload_tasks_$_uid';

  Future<void> _enqueuePendingTask({
    required String type,
    required String style,
    required String prompt,
    required Uint8List generatedImageBytes,
    required Uint8List referenceImageBytes,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final dir = await _pendingUploadsDir();
    final generatedPath =
        '${dir.path}${Platform.pathSeparator}${id}_generated.bin';
    final referencePath =
        '${dir.path}${Platform.pathSeparator}${id}_reference.bin';
    await File(generatedPath).writeAsBytes(generatedImageBytes, flush: true);
    await File(referencePath).writeAsBytes(referenceImageBytes, flush: true);

    final tasks = await _readPendingTasks();
    tasks.add(
      _PendingUploadTask(
        id: id,
        type: type,
        style: style,
        prompt: prompt,
        generatedImagePath: generatedPath,
        referenceImagePath: referencePath,
        createdAtIso: DateTime.now().toIso8601String(),
      ),
    );
    await _writePendingTasks(tasks);
  }

  Future<Directory> _pendingUploadsDir() async {
    final base = await getTemporaryDirectory();
    final dir = Directory(
      '${base.path}${Platform.pathSeparator}artitecture_design_pending_uploads${Platform.pathSeparator}$_uid',
    );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<List<_PendingUploadTask>> _readPendingTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingTasksStorageKey);
    if (raw == null || raw.trim().isEmpty) return <_PendingUploadTask>[];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(_PendingUploadTask.fromMap)
          .toList();
    } catch (_) {
      return <_PendingUploadTask>[];
    }
  }

  Future<void> _writePendingTasks(List<_PendingUploadTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(tasks.map((t) => t.toMap()).toList());
    await prefs.setString(_pendingTasksStorageKey, raw);
  }

  Future<void> _deletePendingTaskFiles(_PendingUploadTask task) async {
    final generated = File(task.generatedImagePath);
    final reference = File(task.referenceImagePath);
    if (await generated.exists()) {
      await generated.delete();
    }
    if (await reference.exists()) {
      await reference.delete();
    }
  }

  String _buildSignature({
    required String apiSecret,
    required String folder,
    required int timestamp,
  }) {
    final payload = 'folder=$folder&timestamp=$timestamp$apiSecret';
    return sha1.convert(utf8.encode(payload)).toString();
  }

  _CloudinaryCredentials _parseCloudinaryUrl(String cloudinaryUrl) {
    final uri = Uri.tryParse(cloudinaryUrl);
    if (uri == null ||
        uri.scheme != 'cloudinary' ||
        uri.userInfo.isEmpty ||
        uri.host.isEmpty) {
      throw Exception('Invalid CLOUDINARY_URL format.');
    }

    final userInfoParts = uri.userInfo.split(':');
    if (userInfoParts.length != 2 ||
        userInfoParts[0].isEmpty ||
        userInfoParts[1].isEmpty) {
      throw Exception('Invalid Cloudinary credentials in CLOUDINARY_URL.');
    }

    return _CloudinaryCredentials(
      apiKey: userInfoParts[0],
      apiSecret: userInfoParts[1],
      cloudName: uri.host,
    );
  }
}

class UploadFailure implements Exception {
  const UploadFailure(this.message, {required this.retryable});

  final String message;
  final bool retryable;

  @override
  String toString() => message;
}

class ProjectSaveResult {
  const ProjectSaveResult.saved() : queued = false, pendingCount = 0;
  const ProjectSaveResult.queued({required this.pendingCount}) : queued = true;

  final bool queued;
  final int pendingCount;
}

class PendingUploadRetryResult {
  const PendingUploadRetryResult({
    this.uploadedCount = 0,
    this.remainingCount = 0,
    this.lastError,
  });

  final int uploadedCount;
  final int remainingCount;
  final String? lastError;
}

class _PendingUploadTask {
  const _PendingUploadTask({
    required this.id,
    required this.type,
    required this.style,
    required this.prompt,
    required this.generatedImagePath,
    required this.referenceImagePath,
    required this.createdAtIso,
  });

  final String id;
  final String type;
  final String style;
  final String prompt;
  final String generatedImagePath;
  final String referenceImagePath;
  final String createdAtIso;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'style': style,
      'prompt': prompt,
      'generatedImagePath': generatedImagePath,
      'referenceImagePath': referenceImagePath,
      'createdAtIso': createdAtIso,
    };
  }

  factory _PendingUploadTask.fromMap(Map<String, dynamic> map) {
    return _PendingUploadTask(
      id: map['id']?.toString() ?? '',
      type: map['type']?.toString() ?? '',
      style: map['style']?.toString() ?? '',
      prompt: map['prompt']?.toString() ?? '',
      generatedImagePath: map['generatedImagePath']?.toString() ?? '',
      referenceImagePath: map['referenceImagePath']?.toString() ?? '',
      createdAtIso: map['createdAtIso']?.toString() ?? '',
    );
  }
}

class _CloudinaryCredentials {
  const _CloudinaryCredentials({
    required this.apiKey,
    required this.apiSecret,
    required this.cloudName,
  });

  final String apiKey;
  final String apiSecret;
  final String cloudName;
}
