import 'package:flutter/material.dart';

import 'inexhistory.dart';

class SelectIncomeExpense extends StatefulWidget {
  final String userId;     // 👈 need this to fetch user-wise data
  final String userName;
  const SelectIncomeExpense({super.key, required this.userId, required this.userName});

  @override
  State<SelectIncomeExpense> createState() => _SelectIncomeExpenseState();
}

class _SelectIncomeExpenseState extends State<SelectIncomeExpense> {
  int selectedIndex = 0;
  List<String> _expenseitem=["Expense","Income"];
  String _selectedItem ="Expense";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: DropdownButton(
            value: _selectedItem,
            items: _expenseitem.map((String item){
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item,style: TextStyle(color:Colors.black,fontWeight: FontWeight.w900,fontSize: 15),),
              );
            }).toList(),
            onChanged: (String? val){
              setState(() {
                _selectedItem=val!;
              });
            }
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: IncomeExpense(selectedType:_selectedItem, userId:widget.userId,),
      ),
    );
  }
}
