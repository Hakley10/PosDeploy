// =======================>> Flutter Core
import 'package:flutter/material.dart';

// =======================>> Third-Party Packages
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// =======================>> State Management
import 'package:calendar/providers/local/sale_provider.dart';

// =======================>> Screens
import 'package:calendar/screen/s3-cashier/c2-sale/detail_sale_screen.dart';

// =======================>> Shared Components
import 'package:calendar/shared/component/show_bottom_sheet.dart';
import 'package:calendar/shared/skeleton/c_sale_skeleton.dart';

// =======================>> Shared Entities/Helpers
import 'package:calendar/shared/entity/helper/colors.dart';

// ::: Class-p1 > CashierSaleScreen (StatefulWidget)
class CashierSaleScreen extends StatefulWidget {
  const CashierSaleScreen({super.key});

  @override
  State<CashierSaleScreen> createState() => _CashierSaleScreenState();
}

// ::: Class-sp1 > _CashierSaleScreenState (State<CashierSaleScreen>)
class _CashierSaleScreenState extends State<CashierSaleScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final ScrollController _scrollController = ScrollController();
  bool _isFilterRowVisible = false;
  String? _searchQuery;
  String? _platform;
  String? _startDate;
  String? _endDate;
  int _sortValue = 1;
  int _selectedDateFilter = 1;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoadingMore = false;
  bool _hasReachedMax = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoadingMore &&
        !_hasReachedMax) {
      _loadMoreData();
    }
  }

  Future<void> _loadMoreData() async {
    final provider = Provider.of<SaleProvider>(context, listen: false);
    if (provider.currentPage >= provider.totalPages) {
      setState(() {
        _hasReachedMax = true;
      });
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    String sortField;
    String order;

    switch (_sortValue) {
      case 1:
        sortField = 'ordered_at';
        order = 'DESC';
        break;
      case 2:
        sortField = 'ordered_at';
        order = 'ASC';
        break;
      case 3:
        sortField = 'total_price';
        order = 'DESC';
        break;
      case 4:
        sortField = 'total_price';
        order = 'ASC';
        break;
      default:
        sortField = 'ordered_at';
        order = 'DESC';
    }

    await provider.loadMoreData(
      startDate: _startDate,
      endDate: _endDate,
      platform: _platform,
      key: _searchQuery,
      sort: sortField,
      order: order,
    );

    setState(() {
      _isLoadingMore = false;
      if (provider.currentPage >= provider.totalPages) {
        _hasReachedMax = true;
      }
    });
  }

  Future<void> _refreshData(SaleProvider provider) async {
    String sortField;
    String order;

    switch (_sortValue) {
      case 1:
        sortField = 'ordered_at';
        order = 'DESC';
        break;
      case 2:
        sortField = 'ordered_at';
        order = 'ASC';
        break;
      case 3:
        sortField = 'total_price';
        order = 'DESC';
        break;
      case 4:
        sortField = 'total_price';
        order = 'ASC';
        break;
      default:
        sortField = 'ordered_at';
        order = 'DESC';
    }
    print(
      'Refreshing data with platform=$_platform, sort=$sortField, order=$order, startDate=$_startDate, endDate=$_endDate, searchQuery=$_searchQuery',
    );
    setState(() {
      _hasReachedMax = false;
    });
    await provider.getDataCashier(
      startDate: _startDate,
      endDate: _endDate,
      platform: _platform,
      key: _searchQuery,
      sort: sortField,
      order: order,
    );
  }

  Future<void> _setDateRange(int value) async {
    final now = DateTime.now();
    String? start;
    String? end;

    if (value == 7) {
      // Show date range picker without preset range
      final DateTimeRange? picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: now,
        // Removed the initialDateRange preset
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: HColors.blue,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: HColors.darkgrey,
              ),
              dialogBackgroundColor: Colors.white,
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        start = DateFormat('yyyy-MM-dd').format(picked.start);
        end = DateFormat('yyyy-MM-dd').format(picked.end);
        if (mounted) Navigator.of(context, rootNavigator: true).pop();
      } else {
        return; // Don't change anything if user cancels
      }
    } else {
      switch (value) {
        case 1:
          start = null;
          end = null;
          break;
        case 2:
          start = DateFormat('yyyy-MM-dd').format(now);
          end = start;
          break;
        case 3:
          start = DateFormat(
            'yyyy-MM-dd',
          ).format(now.subtract(Duration(days: now.weekday - 1)));
          end = DateFormat('yyyy-MM-dd').format(now);
          break;
        case 4:
          start = DateFormat(
            'yyyy-MM-dd',
          ).format(DateTime(now.year, now.month, 1));
          end = DateFormat('yyyy-MM-dd').format(now);
          break;
        case 5:
          start = DateFormat(
            'yyyy-MM-dd',
          ).format(DateTime(now.year, now.month - 3, 1));
          end = DateFormat('yyyy-MM-dd').format(now);
          break;
        case 6:
          start = DateFormat(
            'yyyy-MM-dd',
          ).format(DateTime(now.year, now.month - 6, 1));
          end = DateFormat('yyyy-MM-dd').format(now);
          break;
      }
    }

    setState(() {
      _startDate = start;
      _endDate = end;
      _selectedDateFilter = value;
    });
    _refreshData(Provider.of<SaleProvider>(context, listen: false));
  }

  String _getDateFilterLabel() {
    if (_selectedDateFilter == 7 && _startDate != null && _endDate != null) {
      final DateFormat displayFormat = DateFormat('dd,MMM,yyyy');
      final start = displayFormat.format(
        DateFormat('yyyy-MM-dd').parse(_startDate!),
      );
      final end = displayFormat.format(
        DateFormat('yyyy-MM-dd').parse(_endDate!),
      );
      return '$start - $end';
    }
    switch (_selectedDateFilter) {
      case 1:
        return 'ទាំងអស់';
      case 2:
        return 'ថ្ងៃនេះ';
      case 3:
        return 'សប្តាហ៍នេះ';
      case 4:
        return 'ខែនេះ';
      case 5:
        return '3 ខែមុន';
      case 6:
        return '6 ខែមុន';
      case 7:
        return 'ជ្រើសរើសអំឡុងពេល';
      default:
        return 'កាលបរិច្ឆេទ';
    }
  }

  void _showTransactionDetails(
    BuildContext context,
    Map<String, dynamic> transaction,
  ) {
    showCustomBottomSheet(
      context: context,
      builder: (context) => TransactionDetailModal(transaction: transaction),
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.4),
      backgroundColor: Colors.black.withOpacity(0.0),
      useRootNavigator: true,
      enableDrag: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
    );
  }

  Widget _buildFilterButton(
    String label,
    VoidCallback onTap, {
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color:
              isActive
                  ? const Color(0xFF1A73E8).withOpacity(0.1)
                  : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border:
              isActive
                  ? null
                  : Border.all(
                    color: const Color(0xFF5F6368).withOpacity(0.4),
                    width: 1.0,
                  ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isActive ? HColors.blue : Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: isActive ? HColors.blue : HColors.darkgrey,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SaleProvider>(
      builder: (context, provider, child) {
        return SafeArea(
          bottom: true,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: HColors.grey.withOpacity(0.2),
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: HColors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                height: 50,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.search_outlined,
                                      color: HColors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: _searchController,
                                        decoration: const InputDecoration(
                                          hintText: 'ស្វែងរក',
                                          hintStyle: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: HColors.darkgrey,
                                            fontSize: 16,
                                          ),
                                          border: InputBorder.none,
                                          isCollapsed: true,
                                        ),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w400,
                                          color: HColors.darkgrey,
                                          fontSize: 16,
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            _searchQuery =
                                                value.isEmpty ? null : value;
                                          });
                                          _refreshData(provider);
                                        },
                                      ),
                                    ),
                                    if (_searchQuery != null &&
                                        _searchQuery!.isNotEmpty)
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _searchQuery = null;
                                            _searchController.clear();
                                          });
                                          _refreshData(provider);
                                        },
                                        // clear text search
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 4,
                                          ),
                                          child: Container(
                                            width: 18,
                                            height: 18,
                                            decoration: const BoxDecoration(
                                              color: HColors.grey,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.clear,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // toggle filter
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isFilterRowVisible = !_isFilterRowVisible;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Icon(
                                  _isFilterRowVisible
                                      ? Icons.filter_list_off
                                      : Icons.filter_list_sharp,
                                  color: HColors.grey,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Visibility(
                          visible: _isFilterRowVisible,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  _buildFilterButton(
                                    _sortValue == 1
                                        ? 'ថ្ងៃបញ្ជាទិញ: ចុងក្រោយ'
                                        : _sortValue == 2
                                        ? 'ថ្ងៃបញ្ជាទិញ: ដំបូង'
                                        : _sortValue == 3
                                        ? 'តម្លៃលក់: ខ្ពស់បំផុត'
                                        : 'តម្លៃលក់: ទាបបំផុត',
                                    () {
                                      showCustomBottomSheet(
                                        context: context,
                                        builder:
                                            (context) => SortOptionsSheet(
                                              headerTitle: 'តម្រៀបដោយ',
                                              options: [
                                                SortOption(
                                                  label:
                                                      'ថ្ងៃបញ្ជាទិញ: ចុងក្រោយ',
                                                  icon:
                                                      Icons
                                                          .calendar_today_outlined,
                                                  value: 1,
                                                ),
                                                SortOption(
                                                  label: 'ថ្ងៃបញ្ជាទិញ: ដំបូង',
                                                  icon:
                                                      Icons
                                                          .calendar_today_outlined,
                                                  value: 2,
                                                ),
                                                SortOption(
                                                  label: 'តម្លៃលក់: ខ្ពស់បំផុត',
                                                  icon: Icons.money_outlined,
                                                  value: 3,
                                                ),
                                                SortOption(
                                                  label: 'តម្លៃលក់: ទាបបំផុត',
                                                  icon: Icons.money_outlined,
                                                  value: 4,
                                                ),
                                              ],
                                              initialSelectedValue: _sortValue,
                                              onOptionSelected: (value) {
                                                setState(() {
                                                  _sortValue = value;
                                                });
                                                _refreshData(provider);
                                              },
                                            ),
                                        useRootNavigator: true,
                                      );
                                    },
                                    isActive: _sortValue != 1,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildFilterButton(
                                    _platform == null
                                        ? 'ឧបករណ៍'
                                        : _platform == 'Web'
                                        ? 'តាមរយៈកុំព្យូទ័រ'
                                        : 'តាមរយៈទូរស័ព្ទ',
                                    () {
                                      showCustomBottomSheet(
                                        context: context,
                                        builder:
                                            (context) => SortOptionsSheet(
                                              headerTitle: 'ឧបករណ៍',
                                              options: [
                                                SortOption(
                                                  label: 'ទាំងអស់',
                                                  icon: Icons.devices,
                                                  value: 1,
                                                ),
                                                SortOption(
                                                  label: 'តាមរយៈកុំព្យូទ័រ',
                                                  icon: Icons.monitor,
                                                  value: 2,
                                                ),
                                                SortOption(
                                                  label: 'តាមរយៈទូរស័ព្ទ',
                                                  icon: Icons.phone_android,
                                                  value: 3,
                                                ),
                                              ],
                                              initialSelectedValue:
                                                  _platform == null
                                                      ? 1
                                                      : _platform == 'Web'
                                                      ? 2
                                                      : 3,
                                              onOptionSelected: (value) {
                                                setState(() {
                                                  _platform =
                                                      value == 2
                                                          ? 'Web'
                                                          : value == 3
                                                          ? 'Mobile'
                                                          : null;
                                                });
                                                _refreshData(provider);
                                              },
                                            ),
                                        useRootNavigator: true,
                                      );
                                    },
                                    isActive: _platform != null,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildFilterButton(
                                    _selectedDateFilter == 1
                                        ? 'កាលបរិច្ឆេទ'
                                        : _getDateFilterLabel(),
                                    () {
                                      showCustomBottomSheet(
                                        context: context,
                                        builder:
                                            (context) => DateFilterOptionsSheet(
                                              headerTitle: 'កាលបរិច្ឆេទ',
                                              options: [
                                                SortOption(
                                                  label: 'ទាំងអស់',
                                                  icon: Icons.event,
                                                  value: 1,
                                                ),
                                                SortOption(
                                                  label: 'ថ្ងៃនេះ',
                                                  icon: Icons.today,
                                                  value: 2,
                                                ),
                                                SortOption(
                                                  label: 'សប្តាហ៍នេះ',
                                                  icon: Icons.today,
                                                  value: 3,
                                                ),
                                                SortOption(
                                                  label: 'ខែនេះ',
                                                  icon: Icons.today,
                                                  value: 4,
                                                ),
                                                SortOption(
                                                  label: '3 ខែមុន',
                                                  icon: Icons.today,
                                                  value: 5,
                                                ),
                                                SortOption(
                                                  label: '6 ខែមុន',
                                                  icon: Icons.today,
                                                  value: 6,
                                                ),
                                                SortOption(
                                                  label: 'ជ្រើសរើសអំឡុងពេល',
                                                  icon: Icons.today,
                                                  value: 7,
                                                ),
                                              ],
                                              initialSelectedValue:
                                                  _selectedDateFilter,
                                              onOptionSelected: (value) {
                                                setState(() {
                                                  _selectedDateFilter = value;
                                                });
                                                _setDateRange(
                                                  _selectedDateFilter,
                                                );
                                              },
                                            ),
                                        useRootNavigator: true,
                                      );
                                    },
                                    isActive: _selectedDateFilter != 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      key: _refreshIndicatorKey,
                      color: Colors.blue[800],
                      backgroundColor: Colors.white,
                      onRefresh: () => _refreshData(provider),
                      child:
                          provider.isLoading &&
                                  provider.groupedTransactions.isEmpty
                              ? const CSaleSkeleton()
                              : provider.error != null
                              ? const Center(
                                child: Text('Something went wrong'),
                              )
                              : provider.groupedTransactions.isEmpty
                              ? _buildEmptyState()
                              : ListView.separated(
                                controller: _scrollController,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount:
                                    provider.groupedTransactions.length +
                                    (_isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index ==
                                          provider.groupedTransactions.length &&
                                      _isLoadingMore) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: HColors.blue,
                                        ),
                                      ),
                                    );
                                  }
                                  final group =
                                      provider.groupedTransactions[index];
                                  return Column(
                                    children: [
                                      if (group['date'] != '')
                                        _buildDateHeader(group['date']),
                                      ...group['transactions']
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                            final transaction = entry.value;
                                            return _buildTransactionItem(
                                              '#${transaction['receipt_number']}',
                                              transaction['formatted_date'],
                                              transaction['formatted_time'],
                                              transaction['formatted_price'],
                                              transaction['platform'],
                                              transaction['id'],
                                              transaction,
                                              provider,
                                            );
                                          })
                                          .toList(),
                                    ],
                                  );
                                },
                                separatorBuilder:
                                    (context, index) =>
                                        const SizedBox(height: 8),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 48,
            color: HColors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'គ្មានវិក្ក័យបត្រទេ',
            style: TextStyle(
              fontSize: 16,
              color: HColors.darkgrey.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(String date) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Text(
        date,
        style: const TextStyle(
          fontSize: 14,
          color: HColors.darkgrey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    String transactionId,
    String date,
    String time,
    String amount,
    String platform,
    int id,
    Map<String, dynamic> fullTransaction,
    SaleProvider provider,
  ) {
    return Dismissible(
      key: Key(id.toString()),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('លុបការវិក្ក័យបត្រ'),
                    content: const Text('តើអ្នកប្រាកដថាចង់លុបមែនទេ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('បិត'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text(
                          'បាទ/ចាស',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
            ) ??
            false;
      },
      onDismissed: (direction) async {
        await provider.deleteSale(id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('បានលុប $transactionId')));
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () {
          _showTransactionDetails(context, fullTransaction);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.receipt_long,
                      color: HColors.grey,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transactionId,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$date • $time',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    amount,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: HColors.greenData,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      platform == 'Mobile'
                          ? Icons.phone_android_outlined
                          : Icons.monitor,
                      color: HColors.grey,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Padding(
                padding: EdgeInsets.only(left: 40),
                child: Divider(
                  thickness: 1,
                  color: Color(0xFFE5E5E5),
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ::: Class-c1 > SortOptionsSheet (StatefulWidget)
class SortOptionsSheet extends StatefulWidget {
  final String headerTitle;
  final List<SortOption> options;
  final int initialSelectedValue;
  final Function(int) onOptionSelected;

  const SortOptionsSheet({
    super.key,
    required this.headerTitle,
    required this.options,
    required this.initialSelectedValue,
    required this.onOptionSelected,
  });

  @override
  State<SortOptionsSheet> createState() => _SortOptionsSheetState();
}

// ::: Class-sc1 > _SortOptionsSheetState (State<SortOptionsSheet>)
class _SortOptionsSheetState extends State<SortOptionsSheet> {
  late int _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialSelectedValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              widget.headerTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          ...widget.options.map((option) {
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: Icon(option.icon, color: HColors.darkgrey),
              title: Text(option.label),
              trailing:
                  _selectedValue == option.value
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
              onTap: () {
                setState(() {
                  _selectedValue =
                      _selectedValue == option.value && option.value != 1
                          ? 1
                          : option.value;
                });
                widget.onOptionSelected(_selectedValue);
                Navigator.pop(context);
              },
            );
          }),
        ],
      ),
    );
  }
}

// ::: Class-c2 > DateFilterOptionsSheet (StatefulWidget)
class DateFilterOptionsSheet extends StatefulWidget {
  final String headerTitle;
  final List<SortOption> options;
  final int initialSelectedValue;
  final Function(int) onOptionSelected;

  const DateFilterOptionsSheet({
    super.key,
    required this.headerTitle,
    required this.options,
    required this.initialSelectedValue,
    required this.onOptionSelected,
  });

  @override
  State<DateFilterOptionsSheet> createState() => _DateFilterOptionsSheetState();
}

// ::: Class-sc2 > _DateFilterOptionsSheetState (State<DateFilterOptionsSheet>)
class _DateFilterOptionsSheetState extends State<DateFilterOptionsSheet> {
  late int _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialSelectedValue;
  }

  String getDateRange(int value) {
    final now = DateTime.now();
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    String? start;
    String? end;

    switch (value) {
      case 1:
        return '';
      case 2:
        start = dateFormat.format(now);
        end = start;
        return start;
      case 3:
        start = dateFormat.format(
          now.subtract(Duration(days: now.weekday - 1)),
        );
        end = dateFormat.format(now);
        return '$start - $end';
      case 4:
        start = dateFormat.format(DateTime(now.year, now.month, 1));
        end = dateFormat.format(now);
        return '$start - $end';
      case 5:
        start = dateFormat.format(DateTime(now.year, now.month - 3, 1));
        end = dateFormat.format(now);
        return '$start - $end';
      case 6:
        start = dateFormat.format(DateTime(now.year, now.month - 6, 1));
        end = dateFormat.format(now);
        return '$start - $end';
      case 7:
        return 'ជ្រើសរើសអំឡុងពេល';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              widget.headerTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          ...widget.options.map((option) {
            final dateRange = getDateRange(option.value);
            final isOption7 = option.value == 7;
            final isSelected = _selectedValue == option.value;

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: Icon(
                option.icon,
                color: isOption7 ? HColors.bluegrey : HColors.darkgrey,
              ),
              title: Text(
                option.label,
                style: TextStyle(color: isOption7 ? HColors.bluegrey : null),
              ),
              subtitle:
                  dateRange.isNotEmpty && option.value != 7
                      ? Text(dateRange)
                      : null,
              trailing:
                  isSelected
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
              onTap: () {
                setState(() {
                  _selectedValue = option.value;
                });
                widget.onOptionSelected(_selectedValue);
                if (option.value != 7) {
                  Navigator.pop(context);
                }
              },
            );
          }),
        ],
      ),
    );
  }
}

// ::: Class-c3 > SortOption
class SortOption {
  final String label;
  final IconData icon;
  final int value;

  SortOption({required this.label, required this.icon, required this.value});
}
