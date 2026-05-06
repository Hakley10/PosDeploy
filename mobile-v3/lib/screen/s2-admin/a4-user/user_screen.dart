// =======================>> Flutter Core
import 'package:calendar/app_routes.dart';
import 'package:calendar/providers/local/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// =======================>> Routing
import 'package:intl/intl.dart';

// =======================>> Providers Components
import 'package:provider/provider.dart';

// =======================>> Shared Components
import 'package:calendar/shared/component/show_bottom_sheet.dart';
import 'package:calendar/shared/entity/helper/colors.dart';
import 'package:calendar/shared/skeleton/user_skeleton.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final TextEditingController _searchController = TextEditingController();
  String? _searchQuery;
  int _sortValue = 1;
  int _selectedRoleFilter = 0;
  bool _isFilterRowVisible = false;

  Future<void> _refreshData(UserProvider provider) async {
    await provider.getHome(
      key: _searchQuery,
      sortValue: _sortValue,
      roleFilter: _selectedRoleFilter == 0 ? null : _selectedRoleFilter,
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: Consumer<UserProvider>(
        builder: (context, provider, child) {
          final roles =
              provider.roles.isNotEmpty
                  ? provider.roles
                  : [
                    {'id': 0, 'name': 'ទាំងអស់'},
                  ];
          final List<Map<String, dynamic>> users =
              (provider.userData != null && provider.userData?['data'] is List)
                  ? (provider.userData!['data'] as List).map((item) {
                    // Get the first role's name
                    final roleName =
                        item['role']?[0]?['role']?['name'] ?? 'No role';
                    // Get the role_id for filtering
                    final roleId = item['role']?[0]?['role_id'];

                    return {
                      'id': item['id'],
                      'name': item['name'] ?? 'Unknown',
                      'avatar': item['avatar'] ?? '',
                      'phone': item['phone'] ?? '',
                      'email': item['email'] ?? '',
                      'totalOrders': item['totalOrders']?.toString() ?? '0',
                      'totalSales': item['totalSales']?.toString() ?? '0',
                      'role': roleName,
                      'roleId': roleId, // Add this for filtering
                      'lastLogin': item['last_login'] ?? '',
                    };
                  }).toList()
                  : [];

          return SafeArea(
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
                              child: Align(
                                alignment:
                                    Alignment
                                        .centerLeft, // 👈 Force align to the left
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      _buildFilterButton(
                                        _sortValue == 1
                                            ? 'សកម្មភាពចុងក្រោយ'
                                            : _sortValue == 2
                                            ? 'ការលក់: ច្រើនបំផុត'
                                            : _sortValue == 3
                                            ? 'ការលក់: តិចបំផុត'
                                            : _sortValue == 4
                                            ? 'តម្លៃលក់សរុប: ខ្ពស់បំផុត'
                                            : 'តម្លៃលក់សរុប: ទាបបំផុត',
                                        () {
                                          showCustomBottomSheet(
                                            context: context,
                                            builder:
                                                (context) => SortOptionsSheet(
                                                  headerTitle: 'តាំរៀបដោយ',
                                                  options: [
                                                    SortOption(
                                                      label: 'សកម្មភាពចុងក្រោយ',
                                                      icon:
                                                          Icons
                                                              .calendar_today_outlined,
                                                      value: 1,
                                                    ),
                                                    SortOption(
                                                      label:
                                                          'ការលក់: ច្រើនបំផុត',
                                                      icon:
                                                          Icons
                                                              .shopping_cart_outlined,
                                                      value: 2,
                                                    ),
                                                    SortOption(
                                                      label: 'ការលក់: តិចបំផុត',
                                                      icon:
                                                          Icons
                                                              .shopping_cart_outlined,
                                                      value: 3,
                                                    ),
                                                    SortOption(
                                                      label:
                                                          'តម្លៃលក់សរុប: ខ្ពស់បំផុត',
                                                      icon:
                                                          Icons.money_outlined,
                                                      value: 4,
                                                    ),
                                                    SortOption(
                                                      label:
                                                          'តម្លៃលក់សរុប: ទាបបំផុត',
                                                      icon:
                                                          Icons.money_outlined,
                                                      value: 5,
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
                                      _buildFilterButton(
                                        _selectedRoleFilter == 0
                                            ? 'តួនាទី'
                                            : roles.firstWhere(
                                              (role) =>
                                                  role['id'] ==
                                                  _selectedRoleFilter,
                                              orElse: () => {'name': 'តួនាទី'},
                                            )['name'],
                                        () {
                                          showCustomBottomSheet(
                                            context: context,
                                            builder:
                                                (
                                                  context,
                                                ) => RoleFilterOptionsSheet(
                                                  headerTitle: 'តួនាទី',
                                                  options:
                                                      roles
                                                          .map(
                                                            (
                                                              role,
                                                            ) => SortOption(
                                                              label:
                                                                  role['name'],
                                                              icon:
                                                                  Icons
                                                                      .person_outline,
                                                              value: role['id'],
                                                            ),
                                                          )
                                                          .toList(),
                                                  initialSelectedValue:
                                                      _selectedRoleFilter,
                                                  onOptionSelected: (value) {
                                                    setState(() {
                                                      _selectedRoleFilter =
                                                          value;
                                                    });
                                                    _refreshData(provider);
                                                  },
                                                ),
                                            useRootNavigator: true,
                                          );
                                        },
                                        isActive: _selectedRoleFilter != 0,
                                      ),
                                    ],
                                  ),
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
                                ? const UserSkeleton() // Use UserSkeleton here
                                : provider.error != null
                                ? Center(child: Text(provider.error!))
                                : users.isEmpty
                                ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.people_outline,
                                          size: 64,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'គ្មានទិន្នន័យ',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                : ListView.builder(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemCount: users.length,
                                  itemBuilder: (context, index) {
                                    final user = users[index];
                                    return InkWell(
                                      onTap: () {
                                        context.push(
                                          '${AppRoutes.userDetail}/${user['id']}',
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: HColors.darkgrey
                                                  .withOpacity(0.2),
                                              width: 1.0,
                                            ),
                                          ),
                                        ),
                                        child: Card(
                                          margin: EdgeInsets.zero,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0,
                                              vertical: 10,
                                            ),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Avatar
                                                Stack(
                                                  children: [
                                                    Container(
                                                      width: 45,
                                                      height: 45,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: Colors.green,
                                                          width: 2,
                                                        ),
                                                      ),
                                                      child: ClipOval(
                                                        child:
                                                            user['avatar'] !=
                                                                    null
                                                                ? Image.network(
                                                                  'https://pos-v2-file.uat.camcyber.com/${user['avatar']}',
                                                                  fit:
                                                                      BoxFit
                                                                          .cover,
                                                                  width: 45,
                                                                  height: 45,
                                                                )
                                                                : Container(
                                                                  color: HColors
                                                                      .darkgrey
                                                                      .withOpacity(
                                                                        0.1,
                                                                      ),
                                                                  child: const Icon(
                                                                    Icons
                                                                        .person_outline,
                                                                    color:
                                                                        HColors
                                                                            .darkgrey,
                                                                  ),
                                                                ),
                                                      ),
                                                    ),
                                                    // Show star only if roleId is 1 (Admin)
                                                    if (user['roleId'] ==
                                                        1) // Check if user is admin
                                                      Positioned(
                                                        bottom: 0,
                                                        right: 0,
                                                        child: Container(
                                                          width: 20,
                                                          height: 20,
                                                          decoration: BoxDecoration(
                                                            color:
                                                                HColors.yellow,
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                              color:
                                                                  Colors.white,
                                                              width: 2,
                                                            ),
                                                          ),
                                                          child: const Icon(
                                                            Icons.star,
                                                            color: Colors.white,
                                                            size: 12,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),

                                                const SizedBox(width: 12),
                                                // Name + Phone
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        user['name'],
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 16,
                                                        ),
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        user['phone'],
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: HColors.grey,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                // Orders + Sales
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.receipt_long,
                                                          size: 16,
                                                          color:
                                                              HColors.darkgrey,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          user['totalOrders'],
                                                          style: TextStyle(
                                                            color:
                                                                HColors
                                                                    .darkgrey,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      "${NumberFormat('#,###').format(int.tryParse(user['totalSales'] ?? '0'))} ៛",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: HColors.darkgrey,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
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
          );
        },
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

class RoleFilterOptionsSheet extends StatefulWidget {
  final String headerTitle;
  final List<SortOption> options;
  final int initialSelectedValue;
  final Function(int) onOptionSelected;

  const RoleFilterOptionsSheet({
    super.key,
    required this.headerTitle,
    required this.options,
    required this.initialSelectedValue,
    required this.onOptionSelected,
  });

  @override
  State<RoleFilterOptionsSheet> createState() => _RoleFilterOptionsSheetState();
}

class _RoleFilterOptionsSheetState extends State<RoleFilterOptionsSheet> {
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

  SortOption({required this.label, required this.icon, required this.value});
}
