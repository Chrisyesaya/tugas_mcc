import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'login.dart';
import 'package:tugas_mcc/widgets/video_background.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  // 1. Tambahkan Controller baru
  final _nameCtrl = TextEditingController(); // Controller untuk Nama
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  
  bool _isLoading = false;
  bool _obscureText = true;

  Future<void> _register() async {
    setState(() => _isLoading = true);
    try {
      // 2. Buat Akun Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: _emailCtrl.text.trim(), password: _passCtrl.text.trim());

      // 3. Simpan data user di Realtime DB dengan parent 'accounts'
      String uid = userCredential.user!.uid;
      
      // Mengubah path dari "users/$uid" menjadi "accounts/$uid"
      await FirebaseDatabase.instance.ref("accounts/$uid").set({
        "email": _emailCtrl.text.trim(),
        "name": _nameCtrl.text.trim(),       // Menyimpan Nama
        "phone": _phoneCtrl.text.trim(),     // Menyimpan No HP
        "address": _addressCtrl.text.trim(), // Menyimpan Alamat
        "created_at": DateTime.now().toIso8601String(),
      });

      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0, 
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Video Background
          const VideoBackground(),

          // Content Overlay
          Container(
            color: Colors.black.withOpacity(0.3), 
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: SingleChildScrollView( // Tambahkan Scroll agar tidak overflow
                  child: Container(
                    padding: const EdgeInsets.all(24.0),
                    margin: const EdgeInsets.only(top: 60.0), 
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20.0,
                          spreadRadius: 5.0,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Reads - Register",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 30),
                        
                        // --- EMAIL INPUT ---
                        TextField(
                          controller: _emailCtrl,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: "Email",
                            labelStyle: const TextStyle(color: Colors.black54),
                            floatingLabelStyle: const TextStyle(color: Colors.blue),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black54, width: 2.0),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // --- NAME INPUT (BARU) ---
                        TextField(
                          controller: _nameCtrl,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: "Nama",
                            labelStyle: const TextStyle(color: Colors.black54),
                            floatingLabelStyle: const TextStyle(color: Colors.blue),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black54, width: 2.0),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // --- PHONE INPUT ---
                        TextField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: "No HP",
                            labelStyle: const TextStyle(color: Colors.black54),
                            floatingLabelStyle: const TextStyle(color: Colors.blue),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black54, width: 2.0),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // --- ADDRESS INPUT ---
                        TextField(
                          controller: _addressCtrl,
                          keyboardType: TextInputType.streetAddress,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: "Alamat",
                            labelStyle: const TextStyle(color: Colors.black54),
                            floatingLabelStyle: const TextStyle(color: Colors.blue),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black54, width: 2.0),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // --- PASSWORD INPUT ---
                        TextField(
                          controller: _passCtrl,
                          obscureText: _obscureText,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            labelText: "Password",
                            labelStyle: const TextStyle(color: Colors.black54),
                            floatingLabelStyle: const TextStyle(color: Colors.blue),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black54, width: 2.0),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.black54,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // --- BUTTON ---
                        _isLoading
                            ? const CircularProgressIndicator(color: Colors.black)
                            : ElevatedButton(
                                onPressed: _register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 50, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  elevation: 5,
                                ),
                                child: const Text("DAFTAR AKUN",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold, // Make text bold
                                    )),
                              ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginScreen()),
                                (route) => false);
                          },
                          child: const Text(
                            "Sudah memiliki akun? Login",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}