import 'package:absensi/views/auth_page/regist.dart';
import 'package:absensi/services/auth_services.dart';
import 'package:absensi/API_models/login_model.dart';
import 'package:absensi/views/absensi.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  void _handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password wajib diisi')),
      );
      return;
    }
    setState(() {
      isLoading = true;
    });
    final Login? result = await AuthService.login(
      email: email,
      password: password,
    );

    setState(() {
      isLoading = false;
    });

    if (result != null && result.data?.token != null) {
      print("Login berhasil: Token = ${result.data?.token}");

      print("User Email: ${result.data?.user?.email}");
      final userName = result.data?.user?.name ?? "User";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Selamat datang, ${result.data?.user?.name}")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AbsensiPage()),
      );
    } else {
      print("Login gagal: Token tidak ditemukan di response.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login gagal, cek email dan password kamu."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SIGN IN !',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Spacer(flex: 1),
            const Text(
              'Halo, Selamat Datang',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            const Text('Email', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 6),
            TextField(
              controller: emailController,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            const Text('Password', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 6),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                ),
                child:
                    isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'LOGIN',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  ); // Navigasi ke halaman registrasi
                },
                child: const Text(
                  'Belum punya akun? Daftar di sini!',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}
