import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../firebase/book_service.dart';

class BookDetailScreen extends StatelessWidget {
  final String bookId;
  final Map<String, dynamic> bookData;

  const BookDetailScreen({super.key, required this.bookId, required this.bookData});

  @override
  Widget build(BuildContext context) {
    final BookService service = BookService();
    int price = bookData['price'] ?? 0;
    bool isFree = price == 0;

    return Scaffold(
      appBar: AppBar(title: Text(bookData['title'])),
      body: StreamBuilder<DatabaseEvent>(
        stream: service.getUserData(),
        builder: (context, snapshot) {
          // Cek kepemilikan
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
                const Center(child: Icon(Icons.book, size: 100, color: Colors.blue)),
                const SizedBox(height: 20),
                Text(bookData['title'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text("Penulis: ${bookData['author'] ?? '-'}", style: const TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 20),
                Text(bookData['description'] ?? "Tidak ada deskripsi."),
                const Spacer(),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isOwned || isFree ? Colors.green : Colors.blue
                    ),
                    onPressed: () {
                      if (isOwned || isFree) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Membuka buku...")));
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