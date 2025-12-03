import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<DatabaseEvent> getTrendingBooks() {
    return _db.child('books').orderByKey().onValue; 
  }

  // Mencari buku berdasarkan title_lower
  Stream<DatabaseEvent> searchBooks(String query) {
    return _db
        .child('books')
        .orderByChild('title_lower')
        .startAt(query.toLowerCase())
        .endAt(query.toLowerCase() + "\uf8ff")
        .onValue;
  }

  // Mengambil data user saat ini untuk mengecek kepemilikan buku
  Stream<DatabaseEvent> getUserData() {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _db.child('users').child(uid).onValue;
  }

  // Fungsi Beli Buku
  Future<void> buyBook(String bookId, int price) async {
    String uid = _auth.currentUser!.uid;

    await _db.child('users').child(uid).child('owned_books').update({
      bookId: true
    });
  }

  // Cek apakah user sudah punya buku tertentu
  bool isBookOwned(Map<dynamic, dynamic>? ownedBooks, String bookId) {
    if (ownedBooks == null) return false;
    return ownedBooks.containsKey(bookId);
  }

  // Tambah buku baru
  Future<void> addBook(Map<String, dynamic> bookData) async {
    final newBookRef = _db.child('books').push();

    String title = bookData['title'] as String? ?? "Untitled";
    bookData['title_lower'] = title.toLowerCase();

    await newBookRef.set(bookData);

    String? uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _db.child('users').child(uid).child('owned_books').update({
        newBookRef.key!: true,
      });
    }
  }

  // Hapus kepemilikan buku
  Future<void> removeOwnedBook(String bookId) async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _db.child('users').child(uid).child('owned_books').child(bookId).remove();
  }
}