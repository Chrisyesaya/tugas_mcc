import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Pastikan file ini ada di firebase/firebase_options.dart
import 'firebase/firebase_options.dart';
import 'screen/home.dart';
import 'screen/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Inisialisasi Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase initialized successfully.");
  } catch (e) {
    print("❌ Firebase initialization failed: $e");
    // Anda mungkin ingin menampilkan error ke pengguna di sini
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // 1. STATE TEMA: Default adalah Dark Mode
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    final TextTheme baseTextTheme = GoogleFonts.poppinsTextTheme();

    // --- DEFINISI TEMA LIGHT ---
    final ThemeData lightTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blueAccent,
        brightness: Brightness.light,
        primary: Colors.blueAccent,
        secondary: Colors.amber,
      ),
      useMaterial3: true,
      textTheme: baseTextTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      scaffoldBackgroundColor: Colors.white,
    );

    // --- DEFINISI TEMA DARK ---
    final ThemeData darkTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blueAccent,
        brightness: Brightness.dark,
        primary: Colors.blueAccent,
        secondary: Colors.amber,
      ),
      useMaterial3: true,
      textTheme: baseTextTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
    );

    return MaterialApp(
      title: 'Reads App',
      debugShowCheckedModeBanner: false,

      // Terapkan Tema yang sedang aktif
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,

      // StreamBuilder untuk Autentikasi dan Navigasi Otomatis
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            // KIRIM STATE DAN CALLBACK KE HOMESCREEN setelah login sukses
            return HomeScreen();
          }

          // Kirim ke LoginScreen jika belum login
          return const LoginScreen();
        },
      ),
    );
  }
}
