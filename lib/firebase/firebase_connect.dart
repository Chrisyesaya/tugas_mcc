// lib/firebase/firebase_connect.dart

import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';

// Fungsi initFirebase tidak lagi diperlukan karena sudah ada di main.dart
// namun kita bisa menyimpannya untuk keperluan monitoring koneksi.

Future<void> initFirebase({bool logConnection = true}) async {
  // Hanya inisialisasi jika belum diinisialisasi di main
  if (Firebase.apps.isEmpty) {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Monitoring koneksi ke Realtime Database
  if (logConnection) {
    FirebaseDatabase.instance.ref('.info/connected').onValue.listen(
      (e) => print(e.snapshot.value == true ? 'Connected to DB' : 'Disconnected from DB'),
      onError: (err) => print('Error Connection: $err'),
    );
  }
}

// Catatan: Jika Anda tidak menggunakan initFirebase() di main, 
// Anda bisa memanggilnya di main.dart. Saat ini, 
// inisialisasi sudah dilakukan langsung di main.dart.