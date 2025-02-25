import 'package:flutter/material.dart';
import 'package:stockflow/views/screens/sales_report.dart';
import 'package:stockflow/views/widgets/custom_appbar.dart';
import 'package:stockflow/views/widgets/service_card.dart';

class Services extends StatelessWidget {
  const Services({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Services"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Sales Report Card
            ServiceCard(
              title: "Sales Report",
              description: "View detailed sales analytics and reports",
              icon: Icons.bar_chart,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SalesReportScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Items Reports Card
            ServiceCard(
              title: "Items Reports",
              description: "Check inventory and item performance",
              icon: Icons.inventory,
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => const ItemsReportScreen(),
                //   ),
                // );
              },
            ),

            const SizedBox(height: 16),

            // Customer Ledger Card
            ServiceCard(
              title: "Customer Ledger",
              description:
                  "All transactions related to the customer are displayed here",
              icon: Icons.person,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Card Widget for Services
