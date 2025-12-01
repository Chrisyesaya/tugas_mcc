import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';

// --- PROFILE SCREEN ---
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key}); // Ditambahkan const constructor

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")), // Ditambahkan const
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)), // Ditambahkan const
            const SizedBox(height: 20), // Ditambahkan const
            Text(user?.email ?? "Guest", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Ditambahkan const
            const SizedBox(height: 20), // Ditambahkan const
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) { // Pengecekan mounted untuk navigasi asinkron
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
                }
              },
              child: const Text("Logout", style: TextStyle(color: Colors.white)), // Ditambahkan const
            )
          ],
        ),
      ),
    );
  }
}