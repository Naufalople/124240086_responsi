import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/article_model.dart';

class BookmarkService {
  static const String boxName = 'bookmarks';

  static Box get _box => Hive.box(boxName);

  /// Cek apakah suatu artikel sudah ada di bookmark
  static bool isBookmarked(int id) {
    return _box.containsKey(id);
  }

  /// Toggle bookmark: jika sudah ada dihapus, jika belum ada disimpan
  /// Return true jika berhasil ditambahkan, false jika dihapus
  static Future<bool> toggleBookmark(Article article) async {
    if (isBookmarked(article.id)) {
      await _box.delete(article.id);
      return false;
    } else {
      await _box.put(article.id, article.toMap());
      return true;
    }
  }

  /// Menghapus artikel dari bookmark berdasarkan ID
  static Future<void> removeBookmark(int id) async {
    await _box.delete(id);
  }

  /// Mengambil semua artikel yang ada di bookmark
  static List<Article> getBookmarks() {
    return _box.values
        .map((item) => Article.fromMap(Map<dynamic, dynamic>.from(item)))
        .toList();
  }

  /// ValueListenable agar UI halaman Bookmark bisa reaktif otomatis
  static ValueListenable<Box> listenable() {
    return _box.listenable();
  }
}
