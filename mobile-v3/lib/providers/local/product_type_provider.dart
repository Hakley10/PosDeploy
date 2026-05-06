// =======================>> Flutter Core
import 'package:flutter/material.dart';

// =======================>> Third-party Packages
import 'package:dio/dio.dart';

// =======================>> Local Services
import 'package:calendar/services/product_type_service.dart';

class ProductTypeProvider extends ChangeNotifier {
  // Feilds
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _productType;

  // Services
  final ProductTypeService _service = ProductTypeService();
  // final CreateRequestService _createRequestService = CreateRequestService();

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  // Map<String, dynamic>? get productData => _productType;
  Map<String, dynamic>? get productType => _productType;

  // Setters

  // Initialize
  ProductTypeProvider() {
    getHome();
  }

  // Functions
  Future<void> getHome() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _service.getData();
      // Ensure the response has the expected structure
      if (response.containsKey('data') && response['data'] is List) {
        _productType = response;
        _error = null;
      } else {
        _error = "Invalid data structure from server";
        _productType = null;
      }
    } catch (e) {
      _error = e.toString(); // Show actual error for debugging
      _productType = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProduct(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.deleteProductType(id);
      // Instead of modifying local state, refresh from server
      await getHome();
      return true;
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Failed to delete product.';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
