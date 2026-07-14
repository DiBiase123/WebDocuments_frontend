import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:webdocuments/config.dart';
import 'package:webdocuments/services/auth_storage.dart';

class WebDocumentsService {
  final Dio _dio;
  final AuthStorage _authStorage;

  WebDocumentsService({String? baseUrl})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl ?? Config.buildUrl(''),
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      ),
      _authStorage = AuthStorage();

  Future<Map<String, String>> _getHeaders() async {
    final authData = await _authStorage.loadAuthData();
    return {
      'Content-Type': 'application/json',
      if (authData != null) 'Authorization': 'Bearer ${authData['token']}',
    };
  }

  Future<List<dynamic>> getDocuments() async {
    try {
      final r = await _dio.get(
        '/api/webdocuments',
        options: Options(headers: await _getHeaders()),
      );
      if (r.data['success'] == true) return r.data['data'] ?? [];
      throw Exception('Errore');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return [];
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getDocumentById(String id) async {
    final r = await _dio.get(
      '/api/webdocuments/$id',
      options: Options(headers: await _getHeaders()),
    );
    if (r.data['success'] == true) return r.data['data'];
    throw Exception('Documento non trovato');
  }

  Future<Map<String, dynamic>> createDocument({
    required String description,
    required String documentDate,
    required List<String> enteIds,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    final r = await _dio.post(
      '/api/webdocuments',
      data: {
        'description': description,
        'documentDate': documentDate,
        'enteIds': enteIds,
        'fileName': fileName,
        'fileData': base64.encode(fileBytes),
      },
      options: Options(headers: await _getHeaders()),
    );
    if (r.data['success'] == true) return r.data['data'];
    throw Exception(r.data['message'] ?? 'Errore');
  }

  Future<void> updateDocument({
    required String id,
    String? description,
    String? documentDate,
    List<String>? enteIds,
  }) async {
    final body = <String, dynamic>{
      if (description != null) 'description': description,
      if (documentDate != null) 'documentDate': documentDate,
      if (enteIds != null) 'enteIds': enteIds,
    };
    final r = await _dio.put(
      '/api/webdocuments/$id',
      data: body,
      options: Options(headers: await _getHeaders()),
    );
    if (r.data['success'] != true) throw Exception('Errore');
  }

  Future<void> deleteDocument(String id) async {
    final r = await _dio.delete(
      '/api/webdocuments/$id',
      options: Options(headers: await _getHeaders()),
    );
    if (r.data['success'] != true) throw Exception('Errore');
  }

  Future<List<dynamic>> getEnti() async {
    try {
      final r = await _dio.get(
        '/api/enti',
        options: Options(headers: await _getHeaders()),
      );
      if (r.data['success'] == true) return r.data['data'] ?? [];
      throw Exception('Errore');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return [];
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createEnte(String nome) async {
    final r = await _dio.post(
      '/api/enti',
      data: {'nome': nome},
      options: Options(headers: await _getHeaders()),
    );
    if (r.data['success'] == true) return r.data['data'];
    throw Exception(r.data['message'] ?? 'Errore');
  }

  Future<void> deleteEnte(String id) async {
    final r = await _dio.delete(
      '/api/enti/$id',
      options: Options(headers: await _getHeaders()),
    );
    if (r.data['success'] != true) throw Exception('Errore');
  }

  Future<void> updateEnte(String id, String nome) async {
    final r = await _dio.put(
      '/api/enti/$id',
      data: {'nome': nome},
      options: Options(headers: await _getHeaders()),
    );
    if (r.data['success'] != true) throw Exception('Errore');
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final r = await _dio.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );
      if (r.data['success'] == true) {
        final d = r.data['data'];
        await _authStorage.saveAuthData(
          token: d['token'],
          refreshToken: d['refreshToken'],
          userId: d['user']['id'],
          username: d['user']['username'],
        );
        return d;
      }
      throw Exception(r.data['message'] ?? 'Login fallito');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ?? 'Riprovare server occupato',
      );
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(
        '/api/auth/logout',
        options: Options(headers: await _getHeaders()),
      );
    } catch (_) {}
    await _authStorage.clearAuthData();
  }
}
