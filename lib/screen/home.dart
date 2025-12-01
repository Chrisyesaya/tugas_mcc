import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../firebase/book_service.dart';
import 'book_detail.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BookService bookService = BookService();

    return Scaffold(
      appBar: AppBar(title: const Text("Reads - Trending")),
      body: StreamBuilder<DatabaseEvent>(
        stream: bookService.getTrendingBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return const Center(child: Text("Belum ada buku tersedia."));
          }

          // Parsing Map dari RTDB ke List
          Map<dynamic, dynamic> booksMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          List<Map<String, dynamic>> booksList = [];
          booksMap.forEach((key, value) {
            final nextBook = Map<String, dynamic>.from(value);
            nextBook['id'] = key;
            booksList.add(nextBook);
          });

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: booksList.length,
            itemBuilder: (context, index) {
              var data = booksList[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => BookDetailScreen(bookId: data['id'], bookData: data)
                  ));
                },
                child: Card(
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.grey[200],
                          child: const Center(child: Icon(Icons.book, size: 50)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['title'] ?? '-', 
                                maxLines: 1, 
                                overflow: TextOverflow.ellipsis, 
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text("Rp ${data['price'] ?? 0}", 
                                style: TextStyle(color: (data['price'] == 0) ? Colors.green : Colors.orange)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}