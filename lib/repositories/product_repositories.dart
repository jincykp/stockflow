import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stockflow/model/product_model.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addProduct(ProductModel product) async {
    try {
      await _firestore
          .collection('allproducts')
          .doc(product.id)
          .set(product.toMap());
    } catch (e) {
      throw Exception("Failed to add product: $e");
    }
  }
}
