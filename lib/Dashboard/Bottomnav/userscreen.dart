import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../Service/apiservice.dart';
import '../History/inexhistory.dart';
import '../History/mainpage.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    //const String apiUrl = 'http://192.168.43.192/BUDGET_APP/view_all_user.php';
     String apiUrl = ApiService.getUrl("view_all_user.ph");

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          setState(() {
            users = List<Map<String, dynamic>>.from(jsonData['data']);
            isLoading = false;
          });
        } else {
          setState(() {
            users = [];
            isLoading = false;
          });
        }
      } else {
        setState(() => isLoading = false);
        debugPrint('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error: $e');
    }
  }

  Future<void> deleteUser(String id) async {
    //const String apiUrl = 'http://192.168.43.192/BUDGET_APP/fd_delete_user.php';
     String apiUrl = ApiService.getUrl("fd_delete_user.php");

    try {
      final response = await http.post(Uri.parse(apiUrl), body: {'id': id});
      final jsonData = json.decode(response.body);

      if (jsonData['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonData['message'])),
        );
        fetchUsers(); // Refresh list after deletion
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${jsonData['message']}')),
        );
      }
    } catch (e) {
      debugPrint('Delete error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting user')),
      );
    }
  }

  void confirmDelete(String id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteUser(id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users List'), centerTitle: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
          ? const Center(child: Text('No users found'))
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SelectIncomeExpense(
                      userId: user['id'].toString(),
                      userName: user['name'],
                    ),
                  ),
                );
              },
            child: Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    user['name'][0].toUpperCase(),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                title: Text(user['name']),
                subtitle: Text(user['email']),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => confirmDelete(user['id'].toString(), user['name']),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
