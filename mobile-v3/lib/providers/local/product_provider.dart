// =======================>> Flutter Core
import 'package:flutter/material.dart';

// =======================>> Local Services
import 'package:calendar/services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  // Feilds
  bool _isLoading = false;
  ProductService get service => _service;
  String? _error;
  Map<String, dynamic>? _productData;
  Map<String, dynamic>? _productType;

  // Services
  final ProductService _service = ProductService();
  // final CreateRequestService _createRequestService = CreateRequestService();

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get productData => _productData;
  Map<String, dynamic>? get productType => _productType;

  // Setters

  // Initialize
  ProductProvider() {
    getHome();
  }

  // Functions
  Future<void> getHome({
    String? key,
    int? sortValue,
    int? categoryFilter,
    int? creatorFilter,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? sortBy;
      String? order;

      // Handle sorting
      if (sortValue != null) {
        switch (sortValue) {
          case 1: // Latest (created_at DESC)
            sortBy = 'created_at';
            order = 'DESC';
            break;
          case 2: // Oldest (created_at ASC)
            sortBy = 'created_at';
            order = 'ASC';
            break;
          case 3: // Price high to low
            sortBy = 'unit_price';
            order = 'DESC';
            break;
          case 4: // Price low to high
            sortBy = 'unit_price';
            order = 'ASC';
            break;
          case 5: // Most sold
            sortBy = 'total_sale';
            order = 'DESC';
            break;
          case 6: // Least sold
            sortBy = 'total_sale';
            order = 'ASC';
            break;
        }
      }

      final response = await _service.getData(
        key: key,
        sortBy: sortBy,
        order: order,
        type: categoryFilter,
        creator: creatorFilter,
      );

      _productData = response;
      _error = null;
    } catch (e) {
      _error = "Failed to load products";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Assuming ProductService has a delete method
      await _service.deleteProduct(id);
      // Update productData by removing the deleted product
      if (_productData != null && _productData?['data'] is List) {
        _productData!['data'] =
            (_productData!['data'] as List)
                .where((product) => product['id'] != id)
                .toList();
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to delete product.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
