import 'package:flutter/material.dart';
import 'package:stockflow/services/auth_services.dart';
import 'package:stockflow/utils/theme/colors.dart';
import 'package:stockflow/utils/theme/text_styles.dart';
import 'package:stockflow/views/screens/add_product.dart';
import 'package:stockflow/views/screens/customers.dart';
import 'package:stockflow/views/screens/product.dart';
import 'package:stockflow/views/screens/add_sales.dart';
import 'package:stockflow/views/screens/services.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    AuthServices authServices = AuthServices();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.textColor,
        title: Text(
          'Main Menu',
          style: AppTextStyles.appBarText,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              authServices.signOut(context);
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddProduct()));
        },
        child: Icon(Icons.add),
        backgroundColor: AppColors.primaryShadeTwoColor,
        foregroundColor: AppColors.textColor,
        shape: CircleBorder(),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
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
      child: BottomAppBar(
        notchMargin: 5.0,
        shape: CircularNotchedRectangle(),
        clipBehavior: Clip.antiAlias,
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNavItem(context, Icons.shopping_bag, 'Product', Product()),
            _buildNavItem(context, Icons.people, 'Customers', Customers()),
            _buildNavItem(context, Icons.bar_chart, 'Sales', SalesReport()),
            _buildNavItem(
                context, Icons.miscellaneous_services, 'Services', Services()),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, IconData icon, String label, Widget screen) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      borderRadius: BorderRadius.circular(10),
      splashColor: Colors.white.withOpacity(0.3), // Ripple effect
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textColor),
          Text(label, style: AppTextStyles.bottomNavItmes),
        ],
      ),
    );
  }
}
