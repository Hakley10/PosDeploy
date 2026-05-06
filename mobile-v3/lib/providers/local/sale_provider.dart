// =======================>> Flutter Core
import 'package:flutter/material.dart';

// =======================>> Third-party Packages
import 'package:intl/intl.dart';

// =======================>> Local Services
import 'package:calendar/services/sale_service.dart';

class SaleProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _saleData;
  List<Map<String, dynamic>> _groupedTransactions = [];
  double _totalSales = 0.0;
  int _currentPage = 1;
  int _totalPages = 1;
  String? _currentSort;

  final SaleService _saleService = SaleService();

  bool get isLoading => _isLoading;
  bool _disposed = false;
  String? get error => _error;
  Map<String, dynamic>? get saleData => _saleData;
  List<Map<String, dynamic>> get groupedTransactions => _groupedTransactions;
  double get totalSales => _totalSales;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  String? get currentSort => _currentSort;

  SaleProvider() {
    getDataCashier(sort: 'ordered_at', order: 'DESC');
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void safeNotify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> getDataCashier({
    String? cashier,
    String? platform,
    String? sort,
    String? order,
    String? key,
    String? startDate,
    String? endDate,
    bool loadMore = false,
  }) async {
    _isLoading = true;
    _error = null;
    if (!loadMore) {
      _currentPage = 1;
      _groupedTransactions.clear();
      _currentSort = sort;
    }
    safeNotify();

    try {
      print(
        'Fetching data with params: platform=$platform, sort=$sort, order=$order, startDate=$startDate, endDate=$endDate, page=$_currentPage',
      );
      final response = await _saleService.getDataCashier(
        cashier: cashier,
        platform: platform,
        sort: sort,
        order: order,
        key: key,
        limit: '20',
        startDate: startDate,
        endDate: endDate,
        page: _currentPage.toString(),
      );
      print('API Response: ${response['data'].length} transactions');
      _saleData = response;
      final pagination = response['pagination'] ?? {};
      _currentPage = pagination['page'] ?? 1;
      _totalPages = pagination['totalPage'] ?? 1;

      _processSaleData(
        loadMore: loadMore,
        sort: sort,
        order: order,
        platform: platform,
      );
    } catch (e) {
      _error = e.toString();
      print('Error fetching data: $_error');
    } finally {
      _isLoading = false;
      safeNotify();
    }
  }

  Future<void> getHome({
    String? from,
    String? to,
    String? cashier,
    String? platform,
    String? sort,
    String? order,
    String? key,
  }) async {
    _isLoading = true;
    _error = null;
    _currentPage = 1;
    safeNotify();

    try {
      print(
        'Fetching home data with params: platform=$platform, sort=$sort, order=$order',
      );
      final response = await _saleService.getData(
        cashier: cashier,
        platform: platform,
        sort: sort,
        order: order,
        key: key,
        limit: '20',
        page: '1',
      );
      _saleData = response;
      _currentPage = response['pagination']['page'] as int;
      _totalPages = response['pagination']['totalPage'] as int;
      _currentSort = sort;
      _processSaleData(sort: sort, order: order, platform: platform);
    } catch (e) {
      _error = e.toString();
      print('Error fetching home data: $_error');
    } finally {
      _isLoading = false;
      safeNotify();
    }
  }

  void _processSaleData({
    bool loadMore = false,
    String? sort,
    String? order,
    String? platform,
  }) {
    if (_saleData == null || _saleData!['data'] == null) {
      print('No data to process');
      return;
    }

    _totalSales = 0.0;
    Map<String, List<Map<String, dynamic>>> groupedByDate = {};

    if (loadMore && sort != 'total_price') {
      for (var group in _groupedTransactions) {
        groupedByDate[group['date'] as String] =
            group['transactions'] as List<Map<String, dynamic>>;
      }
    }

    final transactions = (_saleData?['data'] as List?) ?? [];
    print('Processing ${transactions.length} transactions');

    if (sort == 'total_price') {
      // For total_price sort, group transactions into batches of 50 with empty date
      List<Map<String, dynamic>> flatTransactions = [];
      for (var transaction in transactions) {
        final transactionMap = transaction as Map<String, dynamic>;
        if (platform != null && transactionMap['platform'] != platform) {
          print(
            'Skipping transaction with platform: ${transactionMap['platform']}',
          );
          continue;
        }

        final totalPrice =
            (transactionMap['total_price'] as num?)?.toDouble() ?? 0.0;
        _totalSales += totalPrice;

        final orderedAt = transactionMap['ordered_at'];
        if (orderedAt is! String) {
          print('Skipping transaction with invalid ordered_at: $orderedAt');
          continue;
        }

        flatTransactions.add({
          ...transactionMap,
          'formatted_date': DateFormat(
            'dd-MM-yyyy',
          ).format(DateTime.parse(orderedAt).toLocal()),
          'formatted_time': DateFormat(
            'hh:mm a',
          ).format(DateTime.parse(orderedAt).toLocal()),
          'formatted_price': NumberFormat("#,##0 ៛").format(totalPrice),
        });
      }

      // Sort flat transactions by total_price
      flatTransactions.sort((a, b) {
        final priceA = (a['total_price'] as num?)?.toDouble() ?? 0.0;
        final priceB = (b['total_price'] as num?)?.toDouble() ?? 0.0;
        return order == 'ASC'
            ? priceA.compareTo(priceB)
            : priceB.compareTo(priceA);
      });

      // Group into batches of 50 with empty date
      const batchSize = 50;
      List<Map<String, dynamic>> groupedBatches = [];
      for (var i = 0; i < flatTransactions.length; i += batchSize) {
        final batch = flatTransactions.sublist(
          i,
          i + batchSize > flatTransactions.length
              ? flatTransactions.length
              : i + batchSize,
        );
        groupedBatches.add({
          'date': '', // Empty date to skip header rendering
          'transactions': batch,
        });
      }

      if (loadMore) {
        _groupedTransactions.addAll(groupedBatches);
      } else {
        _groupedTransactions = groupedBatches;
      }
    } else {
      // For ordered_at sort, group by date
      for (var transaction in transactions) {
        final transactionMap = transaction as Map<String, dynamic>;
        if (platform != null && transactionMap['platform'] != platform) {
          print(
            'Skipping transaction with platform: ${transactionMap['platform']}',
          );
          continue;
        }

        final totalPrice =
            (transactionMap['total_price'] as num?)?.toDouble() ?? 0.0;
        _totalSales += totalPrice;

        final orderedAt = transactionMap['ordered_at'];
        if (orderedAt is! String) {
          print('Skipping transaction with invalid ordered_at: $orderedAt');
          continue;
        }

        try {
          String date = DateFormat(
            'MMMM d',
          ).format(DateTime.parse(orderedAt).toLocal());
          if (!groupedByDate.containsKey(date)) {
            groupedByDate[date] = [];
          }
          groupedByDate[date]!.add({
            ...transactionMap,
            'formatted_date': DateFormat(
              'dd-MM-yyyy',
            ).format(DateTime.parse(orderedAt).toLocal()),
            'formatted_time': DateFormat(
              'hh:mm a',
            ).format(DateTime.parse(orderedAt).toLocal()),
            'formatted_price': NumberFormat("#,##0 ៛").format(totalPrice),
          });
        } catch (e) {
          print('Error parsing date for transaction: $e');
          continue;
        }
      }

      // Sort transactions within each date group by ordered_at
      for (var date in groupedByDate.keys) {
        groupedByDate[date]!.sort((a, b) {
          final dateA = DateTime.parse(a['ordered_at'] as String);
          final dateB = DateTime.parse(b['ordered_at'] as String);
          return order == 'ASC'
              ? dateA.compareTo(dateB)
              : dateB.compareTo(dateA);
        });
      }

      // Sort date groups
      _groupedTransactions =
          groupedByDate.entries
              .map((entry) => {'date': entry.key, 'transactions': entry.value})
              .toList()
            ..sort((a, b) {
              final dateA = DateFormat('MMMM d').parse(a['date'] as String);
              final dateB = DateFormat('MMMM d').parse(b['date'] as String);
              return order == 'ASC'
                  ? dateA.compareTo(dateB)
                  : dateB.compareTo(dateA);
            });
    }

    print('Grouped transactions: ${_groupedTransactions.length} groups');
    safeNotify();
  }

  Future<void> loadMoreData({
    String? startDate,
    String? endDate,
    String? from,
    String? to,
    String? cashier,
    String? platform,
    String? sort,
    String? order,
    String? key,
  }) async {
    if (_currentPage >= _totalPages) {
      print('No more pages to load');
      return;
    }
    _currentPage++;
    print(
      'Loading more data with platform=$platform, sort=$sort, order=$order, page=$_currentPage',
    );
    await getDataCashier(
      startDate: startDate,
      endDate: endDate,
      cashier: cashier,
      platform: platform,
      sort: sort,
      order: order,
      key: key,
      loadMore: true,
    );
  }

  Future<void> deleteSale(int id) async {
    _isLoading = true;
    _error = null;
    safeNotify();

    try {
      await _saleService.deleteSale(id);
      if (_saleData != null && _saleData!['data'] is List) {
        _saleData!['data'] =
            (_saleData!['data'] as List)
                .where((transaction) => transaction['id'] != id)
                .toList();
        _processSaleData(sort: _currentSort);
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to delete sale: ${e.toString()}';
      print('Error deleting sale: $_error');
    } finally {
      _isLoading = false;
      safeNotify();
    }
  }
}
