import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

 Future<void> _register() async {
  try {
    final cred = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: emailCtrl.text.trim(),
      password: passCtrl.text.trim(),
    );

    // Create user document
    await FirebaseFirestore.instance
        .collection('users')
        .doc(cred.user!.uid)
        .set({
      'email': emailCtrl.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 🔴 IMPORTANT: sign out immediately
    await FirebaseAuth.instance.signOut();

    // Go back to login screen
    Navigator.pop(context);
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(e.message ?? 'Register failed')));
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: passCtrl, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _register, child: const Text("Register")),
          ],
        ),
      ),
    );
  }
}
