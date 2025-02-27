import 'package:flutter/material.dart';
import 'package:stockflow/utils/theme/colors.dart';
import 'package:stockflow/views/screens/add_sales_details.dart';
import 'package:stockflow/views/screens/customers.dart';
import 'package:stockflow/views/screens/product.dart';
import 'package:stockflow/views/screens/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    Product(),
    Customers(),
    AddSalesDetails(),
    Services(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            const Color.fromARGB(255, 95, 61, 175),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: BottomNavigationBar(
        selectedLabelStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor),
        unselectedLabelStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: AppColors.lightShadeColor),
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: AppColors.textColor,
        unselectedItemColor: AppColors.textColor.withOpacity(0.6),
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.shopping_bag,
              size: 30,
            ),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.people,
              size: 30,
            ),
            label: 'Customers',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.bar_chart,
              size: 30,
            ),
            label: 'Sales',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.miscellaneous_services,
              size: 30,
            ),
            label: 'Services',
          ),
        ],
      ),
    );
  }
}
