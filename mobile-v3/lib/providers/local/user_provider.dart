import 'package:flutter/material.dart';
import 'package:calendar/services/user_service.dart';

class UserProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoadingRoles => false;
  String? _error;
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _roles = [];

  final UserService _service = UserService();

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get userData => _userData;

  List<Map<String, dynamic>> get roles => _roles;
  UserProvider() {
    getHome();
    _loadRoles();
  }

  // In UserProvider's _loadRoles
  Future<void> _loadRoles() async {
    try {
      _isLoading = true;
      notifyListeners();

      _roles = await _service.getRoles();
      _roles.insert(0, {'id': 0, 'name': 'ទាំងអស់'});
      _error = null;
    } catch (e) {
      _error = 'Failed to load roles: ${e.toString()}';
      // Optionally keep some default roles if needed
      _roles = [
        {'id': 0, 'name': 'ទាំងអស់'},
        {'id': 1, 'name': 'អភិបាលប្រព័ន្ធ'},
        {'id': 2, 'name': 'អ្នកគិតប្រាក់'},
      ];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // In user_provider.dart, modify the getHome method
  Future<void> getHome({String? key, int? sortValue, int? roleFilter}) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? sortBy;
      String? order;

      if (sortValue != null) {
        switch (sortValue) {
          case 1: // Last Active
            sortBy = 'last_login';
            order = 'DESC';
            break;
          case 2: // Most Sales (count)
            sortBy = 'totalOrders';
            order = 'DESC';
            break;
          case 3: // Least Sales (count)
            sortBy = 'totalOrders';
            order = 'ASC';
            break;
          case 4: // Most Sales (amount)
            sortBy = 'totalSales';
            order = 'DESC';
            break;
          case 5: // Least Sales (amount)
            sortBy = 'totalSales';
            order = 'ASC';
            break;
          default: // No sorting
            sortBy = null;
            order = null;
        }
      }

      // Skip role filter if it's 0 (All)
      final int? effectiveRole = (roleFilter == 0) ? null : roleFilter;

      final response = await _service.getData(
        key: key,
        sortBy: sortBy,
        order: order,
        role: effectiveRole,
      );

      _userData = response;
      _error = null;
    } catch (e) {
      _error = 'Error: ${e.toString()}';
      print('Provider Error: $_error'); // Debug print
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
