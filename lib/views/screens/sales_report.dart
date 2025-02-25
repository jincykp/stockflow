import 'package:flutter/material.dart';
import 'package:stockflow/utils/theme/colors.dart';
import 'package:stockflow/views/screens/add_sales_details.dart';
import 'package:stockflow/views/widgets/custom_appbar.dart';

class SalesReport extends StatelessWidget {
  const SalesReport({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Sales Report"),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddSalesDetails()));
        },
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textColor,
        child: Icon(Icons.add),
      ),
    );
  }
}
