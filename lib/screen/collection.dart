import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../firebase/book_service.dart';
import 'book_detail.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  void _showAddBookDialog(BuildContext context, BookService service) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController authorController = TextEditingController();
    final TextEditingController priceController = TextEditingController(text: '0');
    final TextEditingController contentController = TextEditingController();
    final TextEditingController coverUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Tambahkan Buku Baru"),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Judul'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: authorController,
                decoration: const InputDecoration(labelText: 'Penulis'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Harga (Rp, 0 untuk gratis)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: coverUrlController,
                decoration: const InputDecoration(labelText: 'Cover URL (Opsional)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Konten Penuh (full_text)'),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty || contentController.text.isEmpty) {
                return;
              }

              final newBookData = {
                'title': titleController.text,
                'author': authorController.text,
                'price': int.tryParse(priceController.text) ?? 0,
                'description': contentController.text.substring(
                      0,
                      contentController.text.length > 100
                          ? 100
                          : contentController.text.length,
                    ) +
                    "...",
                'full_text': contentController.text,
                'coverUrl': coverUrlController.text.isNotEmpty
                    ? coverUrlController.text
                    : null,
              };

              Navigator.of(ctx).pop();

              try {
                await service.addBook(newBookData);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Buku berhasil ditambahkan!")),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Gagal menambahkan buku: $e")),
                  );
                }
              }
            },
            child: const Text("Tambah"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final BookService service = BookService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Koleksi Saya"),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: service.getUserData(),
        builder: (context, userSnap) {
          Map<dynamic, dynamic>? ownedMap;

          if (userSnap.hasData && userSnap.data!.snapshot.value != null) {
            final uData = userSnap.data!.snapshot.value as Map<dynamic, dynamic>;
            if (uData.containsKey('owned_books')) {
              ownedMap = uData['owned_books'] as Map<dynamic, dynamic>;
            }
          }

          if (ownedMap == null || ownedMap.isEmpty) {
            return const Center(child: Text("Kamu belum memiliki buku."));
          }

          return StreamBuilder<DatabaseEvent>(
            stream: FirebaseDatabase.instance.ref('books').onValue,
            builder: (context, bookSnap) {
              if (!bookSnap.hasData || bookSnap.data?.snapshot.value == null) {
                return const Center(child: CircularProgressIndicator());
              }

              Map<dynamic, dynamic> allBooks =
                  bookSnap.data!.snapshot.value as Map<dynamic, dynamic>;

              List<Map<String, dynamic>> myBooks = [];

              allBooks.forEach((key, value) {
                if (ownedMap!.containsKey(key)) {
                  final b = Map<String, dynamic>.from(value);
                  b['id'] = key;
                  myBooks.add(b);
                }
              });

              if (myBooks.isEmpty) {
                return const Center(child: Text("Koleksi Anda kosong."));
              }

              return ListView.builder(
                itemCount: myBooks.length,
                itemBuilder: (context, index) {
                  var data = myBooks[index];
                  return ListTile(
                    leading: const Icon(Icons.library_books, color: Colors.green),
                    title: Text(data['title']),
                    subtitle: Text("Oleh: ${data['author'] ?? 'Anonim'}"),

                    // === TOMBOL HAPUS DI SINI ===
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Hapus Buku"),
                            content: Text("Yakin ingin menghapus '${data['title']}' dari koleksi?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Batal"),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Hapus"),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await service.removeOwnedBook(data['id']);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Buku '${data['title']}' dihapus.")),
                            );
                          }
                        }
                      },
                    ),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookDetailScreen(
                            bookId: data['id'],
                            bookData: data,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: Builder(
        builder: (context) {
          return FloatingActionButton(
            onPressed: () => _showAddBookDialog(context, service),
            tooltip: 'Tambah Buku',
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}