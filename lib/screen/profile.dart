import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart'; // Import Firebase Realtime Database
import 'login.dart'; // Digunakan untuk navigasi setelah logout

// --- PROFILE SCREEN (VERSI DITINGKATKAN DENGAN DETAIL) ---
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Ambil user saat ini di state
  final User? user = FirebaseAuth.instance.currentUser;
  
  // Inisialisasi referensi Database (akan diinisialisasi di initState)
  late final DatabaseReference _userRef; 

  // State untuk menyimpan data tambahan (Nama, Nomor HP, Alamat)
  String _dbName = "Memuat..."; // Data Nama dari database
  String _phoneNumber = "Memuat...";
  String _address = "Memuat...";

  @override
  void initState() {
    super.initState();
    if (user != null) {
      // Menggunakan path 'accounts'
      _userRef = FirebaseDatabase.instance.ref('accounts').child(user!.uid);
      
      // Mulai mendengarkan data user secara real-time
      _userRef.onValue.listen((event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            _dbName = data['name'] ?? 'Belum Diatur'; 
            _phoneNumber = data['phone'] ?? 'Belum Diatur'; 
            _address = data['address'] ?? 'Belum Diatur';
          });
        } else {
           setState(() {
            _dbName = 'Tidak Ada Data';
            _phoneNumber = 'Tidak Ada Data';
            _address = 'Tidak Ada Data';
          });
        }
      }, onError: (error) {
        // Penanganan error
        setState(() {
          _dbName = 'Error Memuat';
          _phoneNumber = 'Error Memuat';
          _address = 'Error Memuat';
        });
        // print("Error fetching user data: $error");
      });
    } else {
       // Jika user null (fallback aman)
       _dbName = 'Tidak Tersedia (Guest)';
       _phoneNumber = 'Tidak Tersedia (Guest)';
       _address = 'Tidak Tersedia (Guest)';
    }
  }

  // Helper untuk format tanggal
  String _formatDate(DateTime? time) {
    if (time == null) return 'N/A';
    return time.toLocal().toString().split(' ')[0]; // Ambil hanya tanggalnya
  }

  // Teks yang akan ditampilkan sebagai nama, prioritas: DB Name > Auth DisplayName > Email
  String get _displayName {
    // 1. Prioritas utama dari database (setelah dimuat)
    if (_dbName.isNotEmpty && _dbName != "Memuat..." && _dbName != "Tidak Ada Data") {
      return _dbName;
    }
    // 2. Fallback ke Firebase Auth DisplayName
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user!.displayName!;
    }
    // 3. Fallback ke bagian email
    return user?.email?.split('@')[0] ?? "Tamu";
  }

  @override
  Widget build(BuildContext context) {
    // Jika user null, arahkan ke login (proteksi)
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    // Konstanta untuk menyamakan margin Card dan Padding tombol Logout
    const double cardHorizontalMargin = 10.0;

    return Scaffold(
      appBar: AppBar(
        title: Text("Profil $_displayName"),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar pengguna
              CircleAvatar(
                radius: 60,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? const Icon(Icons.person, size: 60, color: Colors.white)
                    : null,
                backgroundColor: Colors.blueAccent,
              ),
              const SizedBox(height: 25),

              // Nama Pengguna (Prominen) - [EDIT] Warna Teks menjadi Putih
              Text(
                _displayName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 5),
              
              // Email (Prominen) - [EDIT] Warna Teks menjadi Putih Sedikit Transparan
              Text(
                user?.email ?? "Email Tidak Tersedia",
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 25),

              // --- Detail Informasi Tambahan ---
              Card(
                elevation: 4,
                // [EDIT] Menggunakan warna latar belakang gelap untuk Card agar kontras dengan teks putih
                color: const Color(0xFF2C2C2C), 
                margin: const EdgeInsets.symmetric(horizontal: cardHorizontalMargin),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        Icons.person_outline, 
                        "Nama Lengkap", 
                        _dbName
                      ),
                      const Divider(height: 25, color: Colors.white12), // Warna Divider menyesuaikan
                      
                      _buildDetailRow(
                        Icons.email_outlined, 
                        "Email", 
                        user?.email ?? 'N/A'
                      ),
                      const Divider(height: 25, color: Colors.white12),

                      _buildDetailRow(
                        Icons.phone_android, 
                        "Nomor HP", 
                        _phoneNumber 
                      ),
                      const Divider(height: 25, color: Colors.white12),

                      _buildDetailRow(
                        Icons.location_on_outlined, 
                        "Alamat", 
                        _address 
                      ),
                      const Divider(height: 25, color: Colors.white12),
                      
                      _buildDetailRow(
                        Icons.calendar_today, 
                        "Akun Dibuat", 
                        _formatDate(user?.metadata.creationTime)
                      ),
                      const Divider(height: 25, color: Colors.white12),
                      
                      _buildDetailRow(
                        Icons.login, 
                        "Login Terakhir", 
                        _formatDate(user?.metadata.lastSignInTime)
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 35),

              // Tombol Logout
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: cardHorizontalMargin), 
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50), // double.infinity memastikan lebar penuh
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text("Logout", style: TextStyle(fontSize: 18)),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (Route<dynamic> route) => false,
                      );
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Widget kustom untuk menampilkan baris detail
  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      children: [
        // [EDIT] Warna Icon diubah agar terlihat di latar belakang gelap
        Icon(icon, color: Colors.blueAccent, size: 24), 
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // [EDIT] Warna Teks Judul Detail diubah menjadi Putih
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white70, // Lebih cerah
                ),
              ),
              const SizedBox(height: 2),
              // [EDIT] Warna Teks Nilai Detail diubah menjadi Putih
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white, // Paling cerah
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}