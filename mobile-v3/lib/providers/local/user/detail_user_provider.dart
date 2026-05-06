import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:calendar/services/user_service.dart';

class DetailUserProvider extends ChangeNotifier {
  // Fields
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _detailUser;
  List<dynamic> _saleData = [];
  List<Map<String, dynamic>> _groupedTransactions = [];
  double _totalSales = 0.0;

  // Services
  final UserService _service = UserService();

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get detailUser => _detailUser;
  List<dynamic> get saleData => _saleData;
  List<Map<String, dynamic>> get groupedTransactions => _groupedTransactions;
  double get totalSales => _totalSales;

  // Initialize
  DetailUserProvider({required String id}) {
    getUserDetails(id: id);
  }

  // Functions
  Future<void> getUserDetails({required String id}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _service.getUserDetail(id: id);
      _detailUser = response['data'];
      _saleData = (response['sale'] as List<dynamic>?) ?? [];
      _processSaleData();
    } catch (e) {
      _error = "Failed to load user details.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _processSaleData() {
    _totalSales = 0.0;
    Map<String, List<Map<String, dynamic>>> groupedByDate = {};

    for (var transaction in _saleData) {
      final transactionMap = transaction as Map<String, dynamic>;
      final totalPrice = 
          (transactionMap['total_price'] as num?)?.toDouble() ?? 0.0;
      _totalSales += totalPrice;

      final orderedAt = transactionMap['ordered_at'];
      if (orderedAt is! String) {
        continue; // Skip if ordered_at is not a String
      }

      try {
        String date = DateFormat('MMMM d').format(DateTime.parse(orderedAt));
        if (!groupedByDate.containsKey(date)) {
          groupedByDate[date] = [];
        }
        groupedByDate[date]!.add(transactionMap);
      } catch (e) {
        // Skip transactions with invalid date formats
        continue;
      }
    }

    _groupedTransactions = groupedByDate.entries
        .map((entry) => {'date': entry.key, 'transactions': entry.value})
        .toList()
      ..sort(
        (a, b) => DateFormat('MMMM d')
            .parse(b['date'] as String)
            .compareTo(DateFormat('MMMM d').parse(a['date'] as String)),
      );
  }
}