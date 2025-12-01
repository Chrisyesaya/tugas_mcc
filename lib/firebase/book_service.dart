import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mengambil buku trending (limit 10)
  // Data dikirim sebagai Stream<DatabaseEvent> untuk pembaruan real-time.
  Stream<DatabaseEvent> getTrendingBooks() {
    return _db.child('books').limitToFirst(10).onValue;
  }

  // Mencari buku berdasarkan title_lower
  // Metode ini memerlukan index 'title_lower' di Rules Firebase agar bekerja secara efisien.
  Stream<DatabaseEvent> searchBooks(String query) {
    return _db
        .child('books')
        .orderByChild('title_lower')
        .startAt(query.toLowerCase())
        .endAt(query.toLowerCase() + "\uf8ff") // "\uf8ff" adalah karakter Unicode maksimum untuk rentang pencarian string.
        .onValue;
  }

  // Mengambil data user saat ini untuk mengecek kepemilikan buku
  Stream<DatabaseEvent> getUserData() {
    String? uid = _auth.currentUser?.uid;
    // Jika tidak ada user, kembalikan stream kosong
    if (uid == null) return const Stream.empty();
    return _db.child('users').child(uid).onValue;
  }

  // Fungsi Beli Buku: menambahkan bookId ke daftar 'owned_books' user
  Future<void> buyBook(String bookId, int price) async {
    String uid = _auth.currentUser!.uid;
    // Simpan bookId sebagai key dengan value 'true' di node owned_books.
    // Ini memudahkan pengecekan kepemilikan.
    await _db.child('users').child(uid).child('owned_books').update({
      bookId: true
    });
  }

  // Helper: Cek apakah buku sudah dibeli berdasarkan Map owned_books dari DB
  bool isBookOwned(Map<dynamic, dynamic>? ownedBooks, String bookId) {
    if (ownedBooks == null) return false;
    // Cek apakah key bookId ada dalam Map ownedBooks
    return ownedBooks.containsKey(bookId);
  }
}