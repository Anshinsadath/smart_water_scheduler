import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text =
        FirebaseAuth.instance.currentUser?.displayName ?? '';
  }

  /// 🔤 Update Display Name
  Future<void> _updateName() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.updateDisplayName(name);
      await user.reload();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Name updated successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // 🔁 Refresh HomeScreen
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// 🔐 Change Password (with re-auth)
  Future<void> _changePassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    if (currentPassword.isEmpty || newPassword.length < 6) {
      _showError("Password must be at least 6 characters");
      return;
    }

    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final email = user.email!;

      // 🔑 Re-authenticate
      final cred = EmailAuthProvider.credential(
        email: email,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password changed successfully"),
          backgroundColor: Colors.green,
        ),
      );

      _currentPasswordController.clear();
      _newPasswordController.clear();
    } catch (e) {
      _showError("Incorrect current password");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Edit Profile",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Display Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _updateName,
              child: const Text("Save Name"),
            ),

            const Divider(height: 40),

            const Text(
              "Change Password",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),
            TextField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Current Password",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "New Password (min 6 chars)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _changePassword,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text("Change Password"),
            ),
          ],
        ),
      ),
    );
  }
}
