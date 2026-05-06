// =======================>> Flutter Core
import 'package:calendar/shared/skeleton/product_skeleton.dart';
import 'package:flutter/material.dart';

// =======================>> Routing
import 'package:go_router/go_router.dart';

// =======================>> Providers Components
import 'package:calendar/providers/local/product_provider.dart';
import 'package:provider/provider.dart';

// =======================>> Shared Components
import 'package:calendar/shared/component/show_bottom_sheet.dart';
import 'package:calendar/shared/entity/helper/colors.dart';

class ProductScreen2 extends StatefulWidget {
  const ProductScreen2({super.key});

  @override
  State<ProductScreen2> createState() => _ProductScreen2State();
}

class _ProductScreen2State extends State<ProductScreen2> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  bool _isFilterRowVisible = false;
  String? _searchQuery;
  int _sortValue = 1;
  int _selectedCategoryFilter = 0; // Use 0 for "All" consistently
  int _selectedCreatorFilter = 1;
  List<Map<String, dynamic>> _creators = [];
  List<Map<String, dynamic>> _productTypes = [];

  @override
  void initState() {
    super.initState();
    _loadSetupData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSetupData() async {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    try {
      final setupData = await provider.service.dataSetup();
      setState(() {
        _creators = (setupData['users'] as List).cast<Map<String, dynamic>>();
        _productTypes =
            (setupData['productTypes'] as List).cast<Map<String, dynamic>>();
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _refreshData(ProductProvider provider) async {
    int? categoryId;
    if (_selectedCategoryFilter != 0 && _productTypes.isNotEmpty) {
      // Find the selected category in _productTypes
      final selectedCategory = _productTypes.firstWhere(
        (type) => type['id'] == _selectedCategoryFilter,
        orElse: () => {'id': null},
      );
      categoryId = selectedCategory['id'] as int?;
    }

    int? creatorId;
    if (_selectedCreatorFilter != 1 && _creators.isNotEmpty) {
      final creatorIndex = _selectedCreatorFilter - 2; // -2 because 1 is "All"
      if (creatorIndex >= 0 && creatorIndex < _creators.length) {
        creatorId = _creators[creatorIndex]['id'] as int?;
      }
    }

    await provider.getHome(
      key: _searchQuery,
      sortValue: _sortValue,
      categoryFilter: categoryId, // Pass null for "All"
      creatorFilter: creatorId,
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
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        final List<String> categories = [
          'ទាំងអស់', // "All" is always the first option
          ..._productTypes
              .map((type) => type['name'] as String)
              .where((name) => name != 'ទាំងអស់'),
        ];

        // Map API data to products
        final List<Map<String, dynamic>> products =
            (provider.productData != null &&
                    provider.productData?['data'] is List)
                ? (provider.productData!['data'] as List).map((item) {
                  final String rawPrice = item['unit_price']?.toString() ?? '0';
                  // Handle null total_sale by defaulting to '0'
                  final String rawQty = item['total_sale']?.toString() ?? '0';

                  // Clean and parse
                  final int price =
                      int.tryParse(rawPrice.replaceAll(',', '')) ?? 0;
                  final int qty = int.tryParse(rawQty.replaceAll(',', '')) ?? 0;

                  // Calculate total price
                  final int total = price * qty;

                  // Format total price with commas
                  final String formattedTotalPrice =
                      '${total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ៛';

                  return {
                    'id': item['id'],
                    'category': item['type']?['name'] ?? 'Unknown',
                    'typeId': item['type']?['id'],
                    'code': item['code'] ?? '',
                    'name': item['name'] ?? '',
                    'price':
                        item['unit_price'] != null
                            ? '${item['unit_price'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} ៛'
                            : '0 ៛',
                    'image': item['image'] ?? '',
                    'qty': rawQty, // Use the rawQty which already handles null
                    'total_price': formattedTotalPrice,
                    'creatorId': item['creator']?['id'],
                    'creatorName': item['creator']?['name'] ?? '',
                    'creatorAvatar': item['creator']?['avatar'] ?? '',
                    'created_at': item['created_at'] ?? '',
                  };
                }).toList()
                : [];

        return SafeArea(
          child: ScaffoldMessenger(
            key: scaffoldMessengerKey,
            child: Scaffold(
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
                                    // Sort filter button
                                    _buildFilterButton(
                                      _sortValue == 1
                                          ? 'តម្រៀបដោយ'
                                          : _sortValue == 2
                                          ? 'ទំនិញដំបូង'
                                          : _sortValue == 3
                                          ? 'តម្លៃទំនិញ: ខ្ពស់បំផុត'
                                          : _sortValue == 4
                                          ? 'តម្លៃទំនិញ: ទាបបំផុត'
                                          : _sortValue == 5
                                          ? 'ការលក់ទំនិញ: ដាច់បំផុត'
                                          : _sortValue == 6
                                          ? 'ការលក់ទំនិញ: តិចបំផុត'
                                          : _sortValue == 7
                                          ? 'តម្លៃលក់សរុប: ខ្ពស់បំផុត'
                                          : _sortValue == 8
                                          ? 'តម្លៃលក់សរុប: ទាបបំផុត'
                                          : 'តម្រៀបដោយ',
                                      () {
                                        showCustomBottomSheet(
                                          context: context,
                                          builder:
                                              (context) => SortOptionsSheet(
                                                headerTitle: 'តម្រៀបដោយ',
                                                options: [
                                                  SortOption(
                                                    label: 'ទំនិញចុងក្រោយ',
                                                    icon:
                                                        Icons
                                                            .calendar_today_outlined,
                                                    value: 1,
                                                  ),
                                                  SortOption(
                                                    label: 'ទំនិញដំបូង',
                                                    icon:
                                                        Icons
                                                            .calendar_today_outlined,
                                                    value: 2,
                                                  ),
                                                  SortOption(
                                                    label:
                                                        'តម្លៃទំនិញ: ខ្ពស់បំផុត',
                                                    icon:
                                                        Icons
                                                            .check_box_outline_blank,
                                                    value: 3,
                                                  ),
                                                  SortOption(
                                                    label:
                                                        'តម្លៃទំនិញ: ទាបបំផុត',
                                                    icon:
                                                        Icons
                                                            .check_box_outline_blank,
                                                    value: 4,
                                                  ),
                                                  SortOption(
                                                    label:
                                                        'ការលក់ទំនិញ: ដាច់បំផុត',
                                                    icon:
                                                        Icons
                                                            .shopping_cart_outlined,
                                                    value: 5,
                                                  ),
                                                  SortOption(
                                                    label:
                                                        'ការលក់ទំនិញ: តិចបំផុត',
                                                    icon:
                                                        Icons
                                                            .shopping_cart_outlined,
                                                    value: 6,
                                                  ),
                                                  SortOption(
                                                    label:
                                                        'តម្លៃលក់សរុប: ខ្ពស់បំផុត',
                                                    icon: Icons.money_outlined,
                                                    value: 7,
                                                  ),
                                                  SortOption(
                                                    label:
                                                        'តម្លៃលក់សរុប: ទាបបំផុត',
                                                    icon: Icons.money_outlined,
                                                    value: 8,
                                                  ),
                                                ],
                                                initialSelectedValue:
                                                    _sortValue,
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
                                    // Category filter button
                                    _buildFilterButton(
                                      _selectedCategoryFilter == 0
                                          ? 'ប្រភេទ'
                                          : _productTypes.firstWhere(
                                            (type) =>
                                                type['id'] ==
                                                _selectedCategoryFilter,
                                            orElse: () => {'name': 'ប្រភេទ'},
                                          )['name'],
                                      () {
                                        if (_productTypes.isEmpty) return;
                                        showCustomBottomSheet(
                                          context: context,
                                          builder:
                                              (
                                                context,
                                              ) => CategoryFilterOptionsSheet(
                                                headerTitle: 'ប្រភេទ',
                                                options: [
                                                  SortOption(
                                                    label: 'ទាំងអស់',
                                                    icon:
                                                        Icons.category_outlined,
                                                    value: 0, // "All" category
                                                  ),
                                                  ..._productTypes.map(
                                                    (type) => SortOption(
                                                      label: type['name'],
                                                      icon:
                                                          Icons
                                                              .category_outlined,
                                                      value: type['id'],
                                                    ),
                                                  ),
                                                ],
                                                initialSelectedValue:
                                                    _selectedCategoryFilter,
                                                onOptionSelected: (value) {
                                                  setState(() {
                                                    _selectedCategoryFilter =
                                                        value;
                                                  });
                                                  _refreshData(provider);
                                                },
                                              ),
                                          useRootNavigator: true,
                                        );
                                      },
                                      isActive: _selectedCategoryFilter != 0,
                                    ),
                                    const SizedBox(width: 8),
                                    // Creator filter button
                                    _buildFilterButton(
                                      _selectedCreatorFilter == 1
                                          ? 'អ្នកបញ្ចូលទិន្នន័យ'
                                          : _creators.isNotEmpty &&
                                              _selectedCreatorFilter - 1 <
                                                  _creators.length
                                          ? _creators[_selectedCreatorFilter -
                                              1]['name']
                                          : 'អ្នកបញ្ចូលទិន្នន័យ',
                                      () {
                                        showCustomBottomSheet(
                                          context: context,
                                          builder:
                                              (
                                                context,
                                              ) => CreatorFilterOptionsSheet(
                                                headerTitle:
                                                    'អ្នកបញ្ចូលទិន្នន័យ',
                                                options: [
                                                  SortOption(
                                                    label: 'ទាំងអស់',
                                                    icon: Icons.person_outline,
                                                    value: 1,
                                                  ),
                                                  ..._creators.asMap().entries.map(
                                                    (entry) => SortOption(
                                                      label:
                                                          entry.value['name'],
                                                      icon:
                                                          Icons.person_outline,
                                                      value: entry.key + 2,
                                                      imageUrl:
                                                          entry.value['avatar'],
                                                    ),
                                                  ),
                                                ],
                                                initialSelectedValue:
                                                    _selectedCreatorFilter,
                                                onOptionSelected: (value) {
                                                  setState(() {
                                                    _selectedCreatorFilter =
                                                        value;
                                                  });
                                                  _refreshData(provider);
                                                },
                                              ),
                                          useRootNavigator: true,
                                        );
                                      },
                                      isActive: _selectedCreatorFilter != 1,
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
                            provider.isLoading
                                ? const ProductSkeleton()
                                : provider.error != null
                                ? const Center(
                                  child: Text('Something went wrong'),
                                )
                                : _filteredProducts(
                                  products,
                                  categories,
                                ).isEmpty
                                ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text('គ្មានទិន្នន័យ'),
                                  ),
                                )
                                : ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemCount:
                                      _filteredProducts(
                                        products,
                                        categories,
                                      ).length,
                                  itemBuilder: (context, index) {
                                    final product =
                                        _filteredProducts(
                                          products,
                                          categories,
                                        )[index];

                                    return Dismissible(
                                      key: Key(product['id'].toString()),
                                      direction: DismissDirection.endToStart,
                                      confirmDismiss: (direction) async {
                                        return await showDialog<bool>(
                                              context: context,
                                              builder:
                                                  (context) => AlertDialog(
                                                    title: const Text(
                                                      'លុបផលិតផល',
                                                    ),
                                                    content: const Text(
                                                      'តើអ្នកប្រាកដថាចង់លុបផលិតផលនេះមែនទេ?',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed:
                                                            () => Navigator.of(
                                                              context,
                                                            ).pop(false),
                                                        child: const Text(
                                                          'បិត',
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed:
                                                            () => Navigator.of(
                                                              context,
                                                            ).pop(true),
                                                        child: const Text(
                                                          'បាទ/ចាស',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                            ) ??
                                            false;
                                      },
                                      onDismissed: (direction) async {
                                        final provider =
                                            Provider.of<ProductProvider>(
                                              context,
                                              listen: false,
                                            );
                                        final messenger = ScaffoldMessenger.of(
                                          context,
                                        ); // <-- cache before await
                                        final productName =
                                            product['name']; // cache values if needed

                                        await provider.deleteProduct(
                                          product['id'],
                                        );

                                        if (mounted) {
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'បានលុបផលិតផល $productName',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      background: Container(
                                        color: Colors.red,
                                        alignment: Alignment.centerRight,
                                        padding: const EdgeInsets.only(
                                          right: 20,
                                        ),
                                        child: const Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                        ),
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          context.push(
                                            '/product-detail/${product['id']}',
                                          );
                                        },
                                        child: ProductItem(
                                          category:
                                              '${product['category']} | ${product['code']}',
                                          name: product['name'],
                                          price: product['price'],
                                          image: product['image'],
                                          qty: product['qty'],
                                          totalPrice: product['total_price'],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _filteredProducts(
    List<Map<String, dynamic>> products,
    List<String> categories,
  ) {
    List<Map<String, dynamic>> filtered = products;

    // Category filter using actual typeId
    if (_selectedCategoryFilter != 0 && _productTypes.isNotEmpty) {
      filtered =
          filtered
              .where((product) => product['typeId'] == _selectedCategoryFilter)
              .toList();
    }

    // Client-side sorting for total_price if needed
    if (_sortValue == 7 || _sortValue == 8) {
      filtered.sort((a, b) {
        final aPrice =
            int.tryParse(a['price'].replaceAll(',', '').replaceAll(' ៛', '')) ??
            0;
        final aQty = int.tryParse(a['qty'].toString()) ?? 0;
        final aTotal = aPrice * aQty;

        final bPrice =
            int.tryParse(b['price'].replaceAll(',', '').replaceAll(' ៛', '')) ??
            0;
        final bQty = int.tryParse(b['qty'].toString()) ?? 0;
        final bTotal = bPrice * bQty;

        return _sortValue == 7
            ? bTotal.compareTo(aTotal)
            : aTotal.compareTo(bTotal);
      });
    }

    // For sorting by total_sale (cases 5 and 6)
    if (_sortValue == 5 || _sortValue == 6) {
      filtered.sort((a, b) {
        final aQty = int.tryParse(a['qty'].toString()) ?? 0;
        final bQty = int.tryParse(b['qty'].toString()) ?? 0;

        return _sortValue == 5
            ? bQty.compareTo(aQty) // Most sold (DESC)
            : aQty.compareTo(bQty); // Least sold (ASC)
      });
    }

    return filtered;
  }
}

class ProductItem extends StatelessWidget {
  final String category;
  final String name;
  final String price;
  final String image;
  final String qty;

  final String totalPrice;

  const ProductItem({
    super.key,
    required this.category,
    required this.name,
    required this.price,
    required this.image,
    required this.qty,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: HColors.darkgrey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              'https://pos-v2-file.uat.camcyber.com/$image',
              width: 65,
              height: 65,
              fit: BoxFit.contain,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    width: 65,
                    height: 65,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error, color: Colors.red),
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: const TextStyle(fontSize: 13, color: HColors.darkgrey),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 18,
                    color: HColors.darkgrey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    qty.toString(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: HColors.darkgrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                totalPrice,
                style: const TextStyle(
                  fontSize: 13,
                  color: HColors.darkgrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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

class CategoryFilterOptionsSheet extends StatefulWidget {
  final String headerTitle;
  final List<SortOption> options;
  final int initialSelectedValue;
  final Function(int) onOptionSelected;

  const CategoryFilterOptionsSheet({
    super.key,
    required this.headerTitle,
    required this.options,
    required this.initialSelectedValue,
    required this.onOptionSelected,
  });

  @override
  State<CategoryFilterOptionsSheet> createState() =>
      _CategoryFilterOptionsSheetState();
}

class _CategoryFilterOptionsSheetState
    extends State<CategoryFilterOptionsSheet> {
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
                  _selectedValue = option.value;
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

class SortOption {
  final String label;
  final IconData icon;
  final int value;
  final String? imageUrl;

  SortOption({
    required this.label,
    required this.icon,
    required this.value,
    this.imageUrl,
  });
}

class CreatorFilterOptionsSheet extends StatefulWidget {
  final String headerTitle;
  final List<SortOption> options;
  final int initialSelectedValue;
  final Function(int) onOptionSelected;

  const CreatorFilterOptionsSheet({
    super.key,
    required this.headerTitle,
    required this.options,
    required this.initialSelectedValue,
    required this.onOptionSelected,
  });

  @override
  State<CreatorFilterOptionsSheet> createState() =>
      _CreatorFilterOptionsSheetState();
}

class _CreatorFilterOptionsSheetState extends State<CreatorFilterOptionsSheet> {
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
              leading:
                  option.imageUrl != null
                      ? CircleAvatar(
                        backgroundImage: NetworkImage(option.imageUrl!),
                        radius: 16,
                      )
                      : Icon(option.icon, color: HColors.darkgrey),
              title: Text(option.label),
              trailing:
                  _selectedValue == option.value
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
              onTap: () {
                setState(() {
                  _selectedValue = option.value;
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
