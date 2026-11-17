import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_service.dart';
import '../models/article_model.dart';
import 'bookmark_screen.dart';
import 'detail_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Article> _articles = [];
  List<String> _availableNewsSites = ['Semua'];
  String _selectedNewsSite = 'Semua';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  // Mengambil daftar berita dari API
  Future<void> _fetchArticles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Mengambil minimal 25 artikel (melebihi batas minimal 10)
      final results = await ApiService.getArticles(limit: 25);

      // Ekstrak daftar unik sumber publikasi (news site) untuk Filter Chips
      final sitesSet = <String>{};
      for (var a in results) {
        if (a.newsSite.isNotEmpty) {
          sitesSet.add(a.newsSite);
        }
      }
      final sortedSites = sitesSet.toList()..sort();

      setState(() {
        _articles = results;
        _availableNewsSites = ['Semua', ...sortedSites];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  // Filter list artikel berdasarkan FilterChip yang dipilih
  List<Article> get _filteredArticles {
    if (_selectedNewsSite == 'Semua') {
      return _articles;
    }
    return _articles
        .where((article) => article.newsSite == _selectedNewsSite)
        .toList();
  }

  // Fungsi Logout
  void _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('loginData', false);
      await prefs.remove('currentUser');

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Menampilkan username pengguna yang sedang login di title
        title: Text(
          widget.username.isNotEmpty ? widget.username : 'SpaceNews Explorer',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo.shade900,
        foregroundColor: Colors.white,
        actions: [
          // Tombol ke Halaman Bookmark
          IconButton(
            tooltip: 'Halaman Bookmark',
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BookmarkScreen(),
                ),
              );
            },
          ),
          // Tombol Logout di samping kanan Bookmark
          IconButton(
            tooltip: 'Keluar (Logout)',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          // --- FITUR FILTER BERITA (HORIZONTAL FILTER CHIPS) ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: _availableNewsSites.map((site) {
                  final isSelected = _selectedNewsSite == site;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(site),
                      selected: isSelected,
                      selectedColor: Colors.indigo.shade100,
                      checkmarkColor: Colors.indigo.shade900,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.indigo.shade900
                            : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? Colors.indigo
                              : Colors.grey.shade400,
                        ),
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedNewsSite = site;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // --- DAFTAR BERITA / LOADING / ERROR ---
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchArticles,
              child: _buildArticleList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleList() {
    // 1. Loading Indicator
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Memuat berita antariksa...'),
          ],
        ),
      );
    }

    // 2. Tampilan Error jika gagal mengambil data
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                'Gagal Mengambil Berita',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
                onPressed: _fetchArticles,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final displayArticles = _filteredArticles;

    // 3. Tampilan jika tidak ada artikel sesuai filter
    if (displayArticles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'Tidak ada berita untuk sumber "$_selectedNewsSite"',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      );
    }

    // 4. List Berita
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: displayArticles.length,
      itemBuilder: (context, index) {
        final article = displayArticles[index];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          elevation: 2.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(article: article),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar Berita
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: article.imageUrl.isNotEmpty
                        ? Image.network(
                            article.imageUrl,
                            width: 85,
                            height: 85,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 85,
                              height: 85,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image,
                                  color: Colors.grey),
                            ),
                          )
                        : Container(
                            width: 85,
                            height: 85,
                            color: Colors.grey.shade200,
                            child:
                                const Icon(Icons.image, color: Colors.grey),
                          ),
                  ),
                  const SizedBox(width: 12),

                  // Detail Teks Berita
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge Sumber Berita (News Site)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            article.newsSite,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo.shade900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Judul Berita
                        Text(
                          article.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Tanggal Publikasi (Standar Indonesia)
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                size: 12, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                article.formattedPublishedDate,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
