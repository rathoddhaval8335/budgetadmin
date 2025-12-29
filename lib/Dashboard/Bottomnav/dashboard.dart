import 'dart:convert';
import 'package:budgetadmin/adminlogin/adminloginpage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../Service/apiservice.dart';
import '../../Sharedpref/sharedpref.dart';
import '../Category/add_catgory.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int totalUsers = 0;
  double totalIncome = 0;
  double totalExpense = 0;
  bool isLoading = true;
  final SharedPrefService _sharedPrefService = SharedPrefService();

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    await Future.wait([
      fetchTotalUsers(),
      fetchTotalIncome(),
      fetchTotalExpense(),
    ]);
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchTotalUsers() async {
    String apiUrl = ApiService.getUrl("fd_total_user.php");

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          totalUsers = data['total_users'];
        }
      }
    } catch (e) {
      debugPrint('User fetch error: $e');
    }
  }

  Future<void> fetchTotalIncome() async {
    String apiUrl = ApiService.getUrl("total_income_ad.php");
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          totalIncome = data['total_income'].toDouble();
        }
      }
    } catch (e) {
      debugPrint('Income fetch error: $e');
    }
  }

  Future<void> fetchTotalExpense() async {
    String apiUrl = ApiService.getUrl("total_expense_ad.php");
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          totalExpense = data['total_expense'].toDouble();
        }
      }
    } catch (e) {
      debugPrint('Expense fetch error: $e');
    }
  }

  // Show logout confirmation dialog
  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text("Cancel", style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () async {
                // Clear shared preferences
                await _sharedPrefService.clearAllData();

                // Navigate to login page
                Navigator.of(context).pop(); // Close dialog
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminLoginPage()),
                      (route) => false,
                );
              },
              child: const Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final remainingBalance = totalIncome - totalExpense;

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              _showLogoutDialog(context);
            },
            icon: const Icon(Icons.logout, color: Colors.black),
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, Admin 👋',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Here is your budget summary',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildDashboardCard('Total Users', totalUsers.toString(),
                      Icons.people, Colors.blue),
                  _buildDashboardCard('Total Income', '₹${totalIncome.toStringAsFixed(2)}',
                      Icons.account_balance_wallet, Colors.green),
                  _buildDashboardCard('Total Expense', '₹${totalExpense.toStringAsFixed(2)}',
                      Icons.money_off, Colors.red),
                  _buildDashboardCard('Remaining Balance', '₹${remainingBalance.toStringAsFixed(2)}',
                      Icons.savings, Colors.orange),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddCategoryPage()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDashboardCard(String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            radius: 26,
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}