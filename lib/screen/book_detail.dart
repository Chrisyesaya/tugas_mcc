import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../firebase/book_service.dart';
import 'reader_screen.dart'; // Import ReaderScreen

class BookDetailScreen extends StatelessWidget {
  final String bookId;
  final Map<String, dynamic> bookData;

  const BookDetailScreen({super.key, required this.bookId, required this.bookData});

  void _openReader(BuildContext context) {
      // Asumsi konten buku disimpan di field 'full_text' di bookData
      String content = bookData['full_text'] ?? "Maaf, konten buku tidak ditemukan.";
      String title = bookData['title'] ?? "Buku";

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ReaderScreen(
                  title: title,
                  content: content,
              )));
  }

  // Widget baru untuk menampilkan Cover atau Placeholder
  Widget _buildCoverImage(String? url) {
    if (url != null && url.isNotEmpty) {
      // Tampilkan Image.network jika URL tersedia
      return ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Image.network(
          url,
          width: 150,
          height: 220,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const SizedBox(
              width: 150,
              height: 220,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            // Fallback jika gagal load
            return const Icon(Icons.broken_image, size: 100, color: Colors.red);
          },
        ),
      );
    } else {
      // Tampilkan Icon.book jika URL tidak ada (fallback)
      return const Icon(Icons.book, size: 100, color: Colors.blue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final BookService service = BookService();
    int price = bookData['price'] ?? 0;
    bool isFree = price == 0;
    // 1. Ambil coverUrl dari data buku
    String? coverUrl = bookData['coverUrl'] as String?;

    return Scaffold(
      appBar: AppBar(title: Text(bookData['title'])),
      body: StreamBuilder<DatabaseEvent>(
        stream: service.getUserData(),
        builder: (context, snapshot) {

          Map<dynamic, dynamic>? ownedMap;
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final val = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
            if (val.containsKey('owned_books')) {
              ownedMap = val['owned_books'] as Map<dynamic, dynamic>;
            }
          }
          
          bool isOwned = service.isBookOwned(ownedMap, bookId);

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: _buildCoverImage(coverUrl)),
                const SizedBox(height: 20),
                Text(bookData['title'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text("Penulis: ${bookData['author'] ?? '-'}", style: const TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(bookData['description'] ?? "Tidak ada deskripsi."),
                  ),
                ),
                const SizedBox(height: 20),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isOwned || isFree ? Colors.green : Colors.blue
                    ),
                    onPressed: () {
                      if (isOwned || isFree) {
                        _openReader(context);
                      } else {
                        // Dialog Konfirmasi Beli
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Beli Buku"),
                            content: Text("Harga: Rp $price. Lanjutkan?"),
                            actions: [
                              TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text("Batal")),
                              ElevatedButton(
                                onPressed: () async {
                                  Navigator.pop(ctx);
                                  await service.buyBook(bookId, price);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Pembelian Berhasil!")));
                                    // Buka reader setelah pembelian
                                    _openReader(context); 
                                  }
                                },
                                child: const Text("BELI"),
                              )
                            ],
                          )
                        );
                      }
                    },
                    child: Text(
                      isOwned ? "BACA (Milik Anda)" : (isFree ? "BACA GRATIS" : "BELI - Rp $price"),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}