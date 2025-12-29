import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../Service/apiservice.dart';

class IncomeExpense extends StatefulWidget {
  final String userId;
  final String selectedType; // "Income" or "Expense"

  const IncomeExpense({
    super.key,
    required this.userId,
    required this.selectedType,
  });

  @override
  State<IncomeExpense> createState() => _IncomeExpenseState();
}

class _IncomeExpenseState extends State<IncomeExpense> {
  List<Map<String, dynamic>> records = [];
  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void didUpdateWidget(covariant IncomeExpense oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedType != widget.selectedType ||
        oldWidget.userId != widget.userId) {
      fetchData();
    }
  }

  Future<void> fetchData() async {
    if (widget.userId.isEmpty) {
      setState(() {
        errorMessage = 'User ID is empty';
        records = [];
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
      records = [];
    });

    // Debug print
    debugPrint('Fetching ${widget.selectedType} for user: ${widget.userId}');

    // String apiUrl = widget.selectedType.toLowerCase() == 'income'
    //     ? 'http://192.168.43.192/BUDGET_APP/view_user_income.php'
    //     : 'http://192.168.43.192/BUDGET_APP/view_user_expense.php';

    String apiUrl = widget.selectedType.toLowerCase() == 'income'
        ?  ApiService.getUrl("view_user_income.php")
        :  ApiService.getUrl("view_user_expense.php");

    try {
      // Create request body properly
      final Map<String, String> requestBody = {
        'user_id': widget.userId,
      };

      debugPrint('Sending request with: $requestBody');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded', // Try this content type
        },
        body: requestBody, // Direct map, http package will encode it
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Check if response contains status
        if (jsonData.containsKey('status')) {
          if (jsonData['status'] == 'success') {
            setState(() {
              records = List<Map<String, dynamic>>.from(jsonData['data'] ?? []);
              errorMessage = '';
            });
          } else {
            setState(() {
              records = [];
              errorMessage = jsonData['message'] ?? 'No data found';
            });
          }
        } else {
          // If no status field, assume error
          setState(() {
            records = [];
            errorMessage = 'Invalid response format';
          });
        }
      } else {
        setState(() {
          records = [];
          errorMessage = 'Server error: ${response.statusCode}';
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
      setState(() {
        records = [];
        errorMessage = 'Network error: $e';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.selectedType.toLowerCase() == 'income';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : records.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  errorMessage.isEmpty
                      ? 'No ${widget.selectedType} Records'
                      : errorMessage,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: fetchData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          )
              : ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final item = records[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                    isIncome ? Colors.green[100] : Colors.red[100],
                    child: Icon(
                      isIncome
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: isIncome ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(
                    item['cat_name']?.toString() ?? 'No Category',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '₹${item['amount'] ?? '0'}',
                    style: TextStyle(
                      color: isIncome ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  trailing: Text(
                    isIncome ? 'Income' : 'Expense',
                    style: TextStyle(
                      color: isIncome ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}