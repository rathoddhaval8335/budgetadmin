// ForgotSimplePage.dart
import 'dart:convert';
import 'package:budgetadmin/Service/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotSimplePage extends StatefulWidget {
  const ForgotSimplePage({super.key});

  @override
  State<ForgotSimplePage> createState() => _ForgotSimplePageState();
}

class _ForgotSimplePageState extends State<ForgotSimplePage> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  bool loading = false;

  Future<void> submit() async {
    final name = nameCtrl.text.trim();
    final pass = passCtrl.text.trim();
    if (name.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter name and new password")));
      return;
    }

    setState(() => loading = true);
    //const apiUrl = "http://192.168.43.192/BUDGET_APP/fd_forgot_simple.php";
    var apiUrl = ApiService.getUrl("fd_forgot_simple.php");

    try {
      final resp = await http.post(Uri.parse(apiUrl), body: {
        "admin_name": name,
        "new_pass": pass,
      });

      final data = jsonDecode(resp.body);
      final msg = data['message'] ?? 'No response message';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      if (data['status'] == 'success') {
        // Optionally go back to login
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forgot Password (Simple)"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Admin name"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passCtrl,
              decoration: const InputDecoration(labelText: "New password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : submit,
              child: loading ? const CircularProgressIndicator(color: Colors.white) : const Text("Update Password"),
            ),
          ],
        ),
      ),
    );
  }
}
