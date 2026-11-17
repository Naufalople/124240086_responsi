class Article {
  final int id;
  final String title;
  final String url;
  final String imageUrl;
  final String newsSite;
  final String summary;
  final String publishedAt;
  final List<String> authors;

  Article({
    required this.id,
    required this.title,
    required this.url,
    required this.imageUrl,
    required this.newsSite,
    required this.summary,
    required this.publishedAt,
    required this.authors,
  });

  // Format pengarang berita menjadi string yang rapi
  String get authorsText {
    if (authors.isEmpty) {
      return 'Unknown Author';
    }
    return authors.join(', ');
  }

  // Format tanggal standar Indonesia (contoh: 16 November 2026, 12:05 WIB)
  String get formattedPublishedDate {
    try {
      final dt = DateTime.parse(publishedAt).toLocal();
      const monthNames = [
        '',
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];
      final day = dt.day;
      final month = monthNames[dt.month];
      final year = dt.year;
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$day $month $year, $hour:$minute WIB';
    } catch (_) {
      return publishedAt;
    }
  }

  // Deserialisasi dari JSON API
  factory Article.fromJson(Map<String, dynamic> json) {
    List<String> parsedAuthors = [];
    if (json['authors'] != null && json['authors'] is List) {
      for (var item in json['authors']) {
        if (item is Map && item['name'] != null) {
          final name = item['name'].toString().trim();
          if (name.isNotEmpty) {
            parsedAuthors.add(name);
          }
        }
      }
    }

    return Article(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'No Title',
      url: json['url'] ?? '',
      imageUrl: json['image_url'] ?? '',
      newsSite: json['news_site'] ?? 'Unknown',
      summary: json['summary'] ?? '',
      publishedAt: json['published_at'] ?? '',
      authors: parsedAuthors,
    );
  }

  // Serialisasi ke Map untuk disimpan di database lokal (Hive)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'image_url': imageUrl,
      'news_site': newsSite,
      'summary': summary,
      'published_at': publishedAt,
      'authors': authors,
    };
  }

  // Deserialisasi dari Map database lokal (Hive)
  factory Article.fromMap(Map<dynamic, dynamic> map) {
    return Article(
      id: map['id'] ?? 0,
      title: map['title'] ?? '',
      url: map['url'] ?? '',
      imageUrl: map['image_url'] ?? '',
      newsSite: map['news_site'] ?? '',
      summary: map['summary'] ?? '',
      publishedAt: map['published_at'] ?? '',
      authors: (map['authors'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
