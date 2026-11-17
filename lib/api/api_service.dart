import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article_model.dart';

class ApiService {
  static const String baseUrl = 'https://api.spaceflightnewsapi.net/v4/articles';

  /// Mengambil daftar artikel dari API Spaceflight News
  /// [newsSite] opsional untuk memfilter berdasarkan sumber berita di level API
  /// [limit] default minimal 20 berita (ketentuan soal: minimal 10)
  static Future<List<Article>> getArticles({String? newsSite, int limit = 25}) async {
    try {
      String url = '$baseUrl/?limit=$limit';
      if (newsSite != null &&
          newsSite.isNotEmpty &&
          newsSite != 'All' &&
          newsSite != 'Semua') {
        url += '&news_site=${Uri.encodeComponent(newsSite)}';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> results = data['results'] ?? [];

        return results.map((item) => Article.fromJson(item)).toList();
      } else {
        throw Exception(
            'Gagal memuat berita dari server (Kode: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan koneksi: $e');
    }
  }

  /// Mengambil detail satu artikel berdasarkan ID jika diperlukan
  static Future<Article> getArticleById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id/'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Article.fromJson(data);
      } else {
        throw Exception(
            'Gagal memuat detail berita (Kode: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan koneksi: $e');
    }
  }
}
