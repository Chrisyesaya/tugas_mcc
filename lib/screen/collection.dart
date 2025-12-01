import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../firebase/book_service.dart';
import 'book_detail.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BookService service = BookService();

    return Scaffold(
      appBar: AppBar(title: const Text("My Collection")),
      body: StreamBuilder<DatabaseEvent>(
        stream: service.getUserData(),
        builder: (context, userSnap) {
          // 1. Ambil data owned_books user
          Map<dynamic, dynamic>? ownedMap;
          if (userSnap.hasData && userSnap.data!.snapshot.value != null) {
            final uData = userSnap.data!.snapshot.value as Map<dynamic, dynamic>;
            if (uData.containsKey('owned_books')) {
              ownedMap = uData['owned_books'] as Map<dynamic, dynamic>;
            }
          }

          if (ownedMap == null) return const Center(child: Text("Kamu belum memiliki buku."));

          // 2. Ambil semua buku untuk dicocokkan
          return StreamBuilder<DatabaseEvent>(
            stream: FirebaseDatabase.instance.ref('books').onValue,
            builder: (context, bookSnap) {
              if (!bookSnap.hasData || bookSnap.data?.snapshot.value == null) {
                return const Center(child: CircularProgressIndicator());
              }

              Map<dynamic, dynamic> allBooks = bookSnap.data!.snapshot.value as Map<dynamic, dynamic>;
              List<Map<String, dynamic>> myBooks = [];

              // 3. Filter Manual
              allBooks.forEach((key, value) {
                if (ownedMap!.containsKey(key)) {
                  final b = Map<String, dynamic>.from(value);
                  b['id'] = key;
                  myBooks.add(b);
                }
              });

              return ListView.builder(
                itemCount: myBooks.length,
                itemBuilder: (context, index) {
                  var data = myBooks[index];
                  return ListTile(
                    leading: const Icon(Icons.library_books, color: Colors.green),
                    title: Text(data['title']),
                    subtitle: const Text("Dimiliki"),
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => BookDetailScreen(bookId: data['id'], bookData: data)
                    )),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}