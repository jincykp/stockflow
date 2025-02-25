import 'package:flutter/material.dart';
import 'package:stockflow/views/widgets/custom_appbar.dart';

class ItemReports extends StatelessWidget {
  const ItemReports({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Item Reports"),
    );
  }
}
