import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../firebase/book_service.dart';
import 'book_detail.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = "";
  final BookService _service = BookService();
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white24),
        ),
        child: TextField(
          controller: _controller,
          onChanged: (val) => setState(() => _query = val),
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: "Cari judul buku...",
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: Colors.white),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      // Clear controller, reset selection, update state, dan hilangkan fokus
                      _controller.clear();
                      _controller.selection = const TextSelection.collapsed(offset: 0);
                      setState(() => _query = "");
                      FocusScope.of(context).unfocus();
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          ),
        ),
      ),
    );
  }


  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        "Ketik judul untuk mencari",
        style: TextStyle(color: Colors.white70),
      ),
    );
  }

  Widget _buildNoResult() {
    return const Center(
      child: Text(
        "Tidak ditemukan.",
        style: TextStyle(color: Colors.white70),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cari Buku"),
      ),
      body: Column(
        children: [
          _buildSearchField(),
          Expanded(
            child: _query.isEmpty
                ? _buildEmptyState()
                : StreamBuilder<DatabaseEvent>(
                    stream: _service.searchBooks(_query),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      }

                      if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                        return _buildNoResult();
                      }

                      Map<dynamic, dynamic> booksMap =
                          snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

                      List<Map<String, dynamic>> resultList = [];

                      booksMap.forEach((key, value) {
                        final b = Map<String, dynamic>.from(value);
                        b['id'] = key;
                        resultList.add(b);
                      });

                      if (resultList.isEmpty) return _buildNoResult();

                      return ListView.builder(
                        itemCount: resultList.length,
                        itemBuilder: (context, index) {
                          final data = resultList[index];

                          return ListTile(
                            leading: data['coverUrl'] != null &&
                                    (data['coverUrl'] as String).isNotEmpty
                                ? SizedBox(
                                    width: 48,
                                    height: 64,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.network(
                                        data['coverUrl'],
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, err, st) =>
                                            const Icon(Icons.broken_image, color: Colors.white),
                                      ),
                                    ),
                                  )
                                : const SizedBox(
                                    width: 48,
                                    height: 64,
                                    child: Icon(Icons.book, color: Colors.white),
                                  ),
                            title: Text(
                              data['title'] ?? '-',
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              "Rp ${data['price'] ?? 0}",
                              style: const TextStyle(color: Colors.white70),
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookDetailScreen(
                                  bookId: data['id'],
                                  bookData: data,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
