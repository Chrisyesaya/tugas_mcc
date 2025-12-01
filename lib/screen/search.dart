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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(
            hintText: "Cari judul buku...",
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (val) => setState(() => _query = val),
        ),
      ),
      body: _query.isEmpty
          ? const Center(child: Text("Ketik judul untuk mencari"))
          : StreamBuilder<DatabaseEvent>(
              stream: _service.searchBooks(_query),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                  return const Center(child: Text("Tidak ditemukan."));
                }

                Map<dynamic, dynamic> booksMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                List<Map<String, dynamic>> resultList = [];
                booksMap.forEach((key, value) {
                  final b = Map<String, dynamic>.from(value);
                  b['id'] = key;
                  resultList.add(b);
                });

                return ListView.builder(
                  itemCount: resultList.length,
                  itemBuilder: (context, index) {
                    var data = resultList[index];
                    return ListTile(
                      title: Text(data['title']),
                      subtitle: Text("Rp ${data['price']}"),
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => BookDetailScreen(bookId: data['id'], bookData: data)
                      )),
                    );
                  },
                );
              },
            ),
    );
  }
}