import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'book_detail.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    Widget appBarTitle() {
      if (currentUser == null) {
        return const Text(
          "Selamat datang, Pengguna!",
        );
      }

      final DatabaseReference nameRef =
          FirebaseDatabase.instance.ref("accounts/${currentUser.uid}/name");

      return StreamBuilder<DatabaseEvent>(
        stream: nameRef.onValue,
        builder: (context, snap) {
          if (!snap.hasData || snap.data?.snapshot.value == null) {
            return const Text(
              "Selamat datang...",
            );
          }

          final dynamic val = snap.data!.snapshot.value;
          final String name = val?.toString() ?? "Pengguna";

          return Text(
            "Selamat datang, $name!", style: const TextStyle(color: Colors.white),
          );
        },
      );
    }

    // Helper: build grid dari list buku
    Widget buildGridFromList(List<Map<String, dynamic>> list) {
      if (list.isEmpty) {
        return const Center(child: Text("Belum ada buku di kategori ini."));
      }

      return GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final data = list[index];
          final String? coverUrl = data['coverUrl'] as String?;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      BookDetailScreen(bookId: data['id'], bookData: data),
                ),
              );
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(10)),
                      child: coverUrl != null && coverUrl.isNotEmpty
                          ? Image.network(
                              coverUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(Icons.broken_image, size: 50, color: Colors.red),
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(Icons.book, size: 50, color: Colors.blue),
                              ),
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['title'] ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Oleh: ${data['author'] ?? 'Anonim'}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Rp ${data['price'] ?? 0}",
                          style: TextStyle(
                            color: (data['price'] == 0) ? Colors.green : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    // Kategori yang ditampilkan
    const List<String> tabs = [
      "Klasik",
      "Novel",
      "Non Fiksi",
      "Lainnya",
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: appBarTitle(),
          bottom: TabBar(
            tabs: tabs.map((t) => Tab(text: t)).toList(),
            isScrollable: false,
          ),
        ),
        body: StreamBuilder<DatabaseEvent>(
          stream: FirebaseDatabase.instance.ref('books').onValue,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
              return TabBarView(
                children: List.generate(
                  tabs.length,
                  (_) => const Center(child: Text("Belum ada buku tersedia.")),
                ),
              );
            }

            final Map<dynamic, dynamic> booksMap =
                snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

            final List<Map<String, dynamic>> booksList = [];
            booksMap.forEach((key, value) {
              // Pastikan value dipetakan ke Map<String,dynamic>
              final Map<String, dynamic> nextBook = {};
              if (value is Map) {
                // salin semua field yang ada
                for (final entry in value.entries) {
                  nextBook[entry.key.toString()] = entry.value;
                }
              }
              nextBook['id'] = key;
              booksList.add(nextBook);
            });

            // Filter per kategori (menggunakan field 'kategori' dari DB)
            List<Map<String, dynamic>> klasik = [];
            List<Map<String, dynamic>> novel = [];
            List<Map<String, dynamic>> nonFiksi = [];
            List<Map<String, dynamic>> lainnya = [];

            for (final b in booksList) {
              final dynamic raw = b['kategori'] ?? b['category']; // fallback
              final String cat = (raw ?? '').toString().toLowerCase().trim();

              if (cat.contains('klasik')) {
                klasik.add(b);
              } else if (cat.contains('novel')) {
                novel.add(b);
              } else if (cat.contains('nonfiksi') ||
                  cat.contains('non-fiksi') ||
                  cat.contains('non fiction') ||
                  cat.contains('non fiction') ||
                  cat.contains('ilmu') ||
                  cat.contains('pengetahuan') ||
                  cat.contains('sains') ||
                  cat.contains('science') ||
                  cat.contains('non fiksi')) {
                // term-term yang menunjukkan buku non-fiksi
                nonFiksi.add(b);
              } else {
                // kalau kategori kosong atau tidak match, masuk 'Lainnya'
                lainnya.add(b);
              }
            }

            return TabBarView(
              children: [
                buildGridFromList(klasik),
                buildGridFromList(novel),
                buildGridFromList(nonFiksi),
                buildGridFromList(lainnya),
              ],
            );
          },
        ),
      ),
    );
  }
}
