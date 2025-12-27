import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../Service/apiservice.dart';

class ViewCategory extends StatefulWidget {
  const ViewCategory({super.key});

  @override
  State<ViewCategory> createState() => _ViewCategoryState();
}

class _ViewCategoryState extends State<ViewCategory> {
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  // Fetch all categories from PHP API
  Future<void> fetchCategories() async {
    //var apiUrl = "http://192.168.43.192/BUDGET_APP/fd_view_category.php";
    var apiUrl = ApiService.getUrl("fd_view_category.php");
    try {
      final response = await http.post(Uri.parse(apiUrl));
      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        setState(() {
          categories = List<Map<String, dynamic>>.from(data['data']);
          isLoading = false;
        });
      } else {
        setState(() {
          categories = [];
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "No categories found")),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // Delete category API
  Future<void> deleteCategory(String id) async {
   // const apiUrl = "http://192.168.43.192/BUDGET_APP/fd_delete_category.php";
    var apiUrl = ApiService.getUrl("fd_delete_category.php");
    try {
      final response = await http.post(Uri.parse(apiUrl), body: {"id": id});
      final data = jsonDecode(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? "Deleted")),
      );

      if (data['status'] == "success") {
        fetchCategories(); // Refresh list
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // Edit category: only name & type editable
  Future<void> updateCategory(Map<String, dynamic> category) async {
    final TextEditingController nameController =
    TextEditingController(text: category['cat_name']);
    String selectedType = category['cat_type'] ?? 'Expense';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Category"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Category Name"),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedType,
              items: const [
                DropdownMenuItem(value: "Expense", child: Text("Expense")),
                DropdownMenuItem(value: "Income", child: Text("Income")),
              ],
              onChanged: (value) {
                if (value != null) selectedType = value;
              },
              decoration: const InputDecoration(labelText: "Category Type"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              // Call PHP update API
              // var apiUrl =
              //     "http://192.168.43.192/BUDGET_APP/fd_update_category.php";
              var apiUrl = ApiService.getUrl("fd_update_category.php");
              try {
                final response = await http.post(Uri.parse(apiUrl), body: {
                  "id": category['id'].toString(),
                  "cat_name": nameController.text,
                  "cat_type": selectedType,
                  "cat_icon": category['cat_icon'].toString(), // icon unchanged
                });
                final data = jsonDecode(response.body);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(data['message'] ?? "Updated")),
                );
                if (data['status'] == "success") {
                  Navigator.pop(context);
                  fetchCategories();
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: $e")),
                );
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Categories"),
        centerTitle: true,
        backgroundColor: Colors.blue.shade600,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : categories.isEmpty
          ? const Center(child: Text("No categories found"))
          : ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final iconCode =
              int.tryParse(cat['cat_icon'].toString()) ?? 0;
          return Card(
            margin:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade600,
                child: Icon(
                  IconData(iconCode, fontFamily: 'MaterialIcons'),
                  color: Colors.white,
                ),
              ),
              title: Text(cat['cat_name'] ?? ''),
              subtitle: Text("Type: ${cat['cat_type']}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => updateCategory(cat),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () =>
                        deleteCategory(cat['id'].toString()),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
