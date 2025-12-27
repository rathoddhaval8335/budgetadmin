import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../Service/apiservice.dart';
import 'view_category.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {

  void _saveCategory() async {
    String name = _nameController.text.trim();
    if (name.isEmpty || selectedIcon == null || selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    // Convert icon code to int for storing
    int iconCode = selectedIcon!.codePoint;

    // API URL
    //String apiUrl = "http://192.168.43.192/BUDGET_APP/fd_add_category.php";
    String apiUrl = ApiService.getUrl("fd_add_category.php");


    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'cat_name': name,
          'cat_icon': iconCode.toString(),
          'cat_type': selectedType!,
        },
      );

      var data = jsonDecode(response.body);

      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ ${data['message']}")),
        );
        _nameController.clear();
        setState(() {
          selectedIcon = null;
          selectedType = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("⚠️ ${data['message']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }
  final TextEditingController _nameController = TextEditingController();
  IconData? selectedIcon;
  String? selectedType;

  // Available icons (you can add more if you want)
  final List<IconData> availableIcons = [
    // Basic & Common
    Icons.home,
    Icons.fastfood,
    Icons.shopping_cart,
    Icons.sports_soccer,
    Icons.school,
    Icons.work,
    Icons.flight,
    Icons.movie,
    Icons.local_gas_station,
    Icons.savings,
    Icons.pets,
    Icons.favorite,
    Icons.card_giftcard,
    Icons.phone,
    Icons.lightbulb,

    // Payments & Money
    Icons.credit_card,
    Icons.account_balance,
    Icons.payment,
    Icons.money,
    Icons.attach_money,
    Icons.wallet,
    Icons.receipt,
    Icons.bar_chart,

    // Transportation
    Icons.directions_car,
    Icons.directions_bus,
    Icons.train,
    Icons.directions_bike,
    Icons.flight_takeoff,
    Icons.directions_walk,
    Icons.local_taxi,

    // Food & Dining
    Icons.restaurant,
    Icons.local_cafe,
    Icons.local_bar,
    Icons.icecream,
    Icons.cake,
    Icons.local_pizza,
    Icons.set_meal,

    // Shopping
    Icons.store,
    Icons.local_mall,
    Icons.shopping_bag,
    Icons.redeem,
    Icons.discount,

    // Entertainment
    Icons.music_note,
    Icons.games,
    Icons.tv,
    Icons.theaters,
    Icons.casino,
    Icons.sports_esports,

    // Health & Fitness
    Icons.fitness_center,
    Icons.local_hospital,
    Icons.medical_services,
    Icons.spa,
    Icons.self_improvement,

    // Travel
    Icons.hotel,
    Icons.beach_access,
    Icons.landscape,
    Icons.flight_land,

    // Utilities
    Icons.wifi,
    Icons.electric_bolt,
    Icons.water_drop,
    Icons.local_laundry_service,
    Icons.cleaning_services,

    // Education
    Icons.menu_book,
    Icons.history_edu,
    Icons.calculate,
    Icons.computer,

    // Personal Care
    Icons.cut,
    Icons.spa,
    Icons.face_retouching_natural,

    // Miscellaneous
    Icons.celebration,
    Icons.emoji_events,
    Icons.forest,
    Icons.pedal_bike,
    Icons.directions_boat,
    Icons.smartphone,
    Icons.laptop,
    Icons.headphones,
    Icons.memory,

    // Home & Living
    Icons.king_bed,
    Icons.chair,
    Icons.kitchen,
    Icons.yard,

    // Services
    Icons.handyman,
    Icons.plumbing,
    Icons.electrical_services,
    Icons.carpenter,

    // Family
    Icons.family_restroom,
    Icons.child_care,
    Icons.emoji_people,

    // Business
    Icons.business_center,
    Icons.meeting_room,
    Icons.apartment,

  ];

  // Show dialog with all icons
  void _showIconDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Icon"),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: GridView.builder(
              itemCount: availableIcons.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                return IconButton(
                  icon: Icon(
                    availableIcons[index],
                    size: 30,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    setState(() {
                      selectedIcon = availableIcons[index];
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Category"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Category Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Select Icon
            Row(
              children: [
                const Text(
                  "Select Icon:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 20),
                InkWell(
                  onTap: _showIconDialog,
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(
                      selectedIcon ?? Icons.add,
                      size: 28,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Dropdown Type
            DropdownButtonFormField<String>(
              value: selectedType,
              items: const [
                DropdownMenuItem(value: "Income", child: Text("Income")),
                DropdownMenuItem(value: "Expense", child: Text("Expense")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedType = value;
                });
              },
              decoration: const InputDecoration(
                labelText: "Category Type",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),

            // Save Button
            Center(
              child: ElevatedButton(
                onPressed: _saveCategory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Save Category",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewCategory()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "View All Category",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
