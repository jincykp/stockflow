import 'package:flutter/material.dart';
import 'package:stockflow/views/widgets/custom_appbar.dart';

class Product extends StatelessWidget {
  const Product({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Products"),
      body: Column(
        children: [],
      ),
    );
  }
}
