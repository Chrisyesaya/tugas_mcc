import 'package:flutter/material.dart';
import 'home.dart';
import 'search.dart';
import 'collection.dart';
import 'profile.dart';

class MainNav extends StatefulWidget {
  const MainNav({super.key});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _currentIndex = 0;
  
  // Daftar layar yang akan ditampilkan
  final List<Widget> _pages = [
    const HomeScreen(),
    const SearchScreen(),
    const CollectionScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Tampilkan halaman sesuai dengan index yang dipilih
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        // Gunakan type fixed agar label selalu terlihat
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Cari"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Koleksi"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}