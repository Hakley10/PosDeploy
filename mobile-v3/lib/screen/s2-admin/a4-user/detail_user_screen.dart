// =======================>> Flutter Core
import 'package:flutter/material.dart';

// =======================>> Third-party Packages
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// =======================>> Providers Components
import 'package:calendar/providers/local/user/detail_user_provider.dart';

// =======================>> Shared Components
import 'package:calendar/shared/entity/helper/colors.dart';

class DetailUserScreen extends StatefulWidget {
  final String id;

  const DetailUserScreen({super.key, required this.id});

  @override
  State<DetailUserScreen> createState() => _DetailUserScreenState();
}

class _DetailUserScreenState extends State<DetailUserScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Helper method to format date with time
  String _formatDateTime(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString).toLocal();
      return DateFormat('dd-MM-yyyy hh:mm a').format(date);
    } catch (e) {
      return 'N/A';
    }
  }

  // Helper method to format date without time
  String _formatDateOnly(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString).toLocal();
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      return 'N/A';
    }
  }

  // Helper method to format currency
  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###');
    return '${formatter.format(amount)} ៛';
  }

  // Helper method to format roles
  String _formatRoles(List<dynamic>? roles) {
    if (roles == null || roles.isEmpty) return 'N/A';
    return roles.map((role) => role['role']['name'] as String).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DetailUserProvider(id: widget.id),
      child: Consumer<DetailUserProvider>(
        builder: (context, provider, child) {
          // Get user data from provider
          final userData = provider.detailUser;

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(userData?['name'] ?? 'User Details'),
              centerTitle: true,
              backgroundColor: Colors.white,
              elevation: 0,
              actions: [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: IconButton(
                    onPressed: () {
                      context.push('/user-update/${widget.id}');
                    },
                    icon: Icon(Icons.edit_outlined, color: HColors.darkgrey),
                  ),
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                tabs: [Tab(text: 'ទូទៅ'), Tab(text: 'ការលក់')],
                labelColor: Colors.blueAccent,
                labelStyle: TextStyle(
                  fontSize: 16,
                  fontFamily: 'KantumruyPro',
                  fontWeight: FontWeight.w400,
                ),
                unselectedLabelColor: HColors.darkgrey,
                indicatorColor: Colors.blueAccent,
                dividerHeight: 1,
                dividerColor: HColors.darkgrey.withOpacity(0.5),
              ),
            ),
            body:
                provider.isLoading
                    ? Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 60,
                            width: 60,
                            child: CircularProgressIndicator(strokeWidth: 2.0),
                          ),
                          Text(
                            'សូមរងចាំ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    )
                    : provider.error != null
                    ? Center(child: Text('Something went wrong'))
                    : SafeArea(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // First Tab - User Details
                          Column(
                            children: [
                              // User Image Section
                              Container(
                                width: double.infinity,
                                color: Colors.white,
                                padding: EdgeInsets.only(top: 40, bottom: 20),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // User Avatar
                                    Container(
                                      width: 124,
                                      height: 124,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.green,
                                          width: 3,
                                        ),
                                      ),
                                      child: ClipOval(
                                        child:
                                            userData?['avatar'] != null
                                                ? Image.network(
                                                  'https://pos-v2-file.uat.camcyber.com/${userData?['avatar']}',
                                                  width: 120,
                                                  height: 120,
                                                  fit: BoxFit.cover,
                                                )
                                                : Container(
                                                  width: 120,
                                                  height: 120,
                                                  color: Colors.grey.shade200,
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.person,
                                                      size: 42,
                                                      color: HColors.darkgrey,
                                                    ),
                                                  ),
                                                ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Key Information Section
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 0,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      // Left - Blue Box (Total Orders)
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Color(0xFFDFE9F9),
                                                ),
                                                child: const Icon(
                                                  Icons.shopping_cart,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    userData?['totalOrders']
                                                            ?.toString() ??
                                                        '0',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2),
                                                  Text(
                                                    "បញ្ចូលការលក់",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: HColors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Right - Green Box (Total Sales)
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 36,
                                                height: 36,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Color(0xFFDBEDE8),
                                                ),
                                                child: const Icon(
                                                  Icons.attach_money,
                                                  color: HColors.greenData,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    _formatCurrency(
                                                      userData?['totalSales']
                                                              ?.toDouble() ??
                                                          0.0,
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2),
                                                  Text(
                                                    "តម្លៃសរុប (រៀល)",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: HColors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 20, top: 5),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'ព័ត៌មានផ្លាល់ខ្លួន',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),

                              // User Details Card
                              Card(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 0,
                                ),
                                elevation: 0,
                                child: Container(
                                  padding: EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    children: [
                                      // User Name
                                      _buildDetailRow(
                                        icon: Icons.person,
                                        label: 'ឈ្មោះ',
                                        text: userData?['name'] ?? 'N/A',
                                        hasArrow: false,
                                      ),

                                      // Phone
                                      _buildDetailRow(
                                        icon: Icons.phone_android,
                                        label: 'លេខទូរស័ព្ទ',
                                        text: userData?['phone'] ?? 'N/A',
                                        hasArrow: false,
                                      ),

                                      // Email
                                      _buildDetailRow(
                                        icon: Icons.email,
                                        label: 'អ៊ីមែល',
                                        text: userData?['email'] ?? 'N/A',
                                        hasArrow: false,
                                      ),

                                      // Role (can be more than one)
                                      _buildDetailRow(
                                        icon: Icons.star,
                                        label: 'តួនាទីក្នុងប្រព័ន្ធ',
                                        text: _formatRoles(userData?['role']),
                                        hasArrow: false,
                                      ),

                                      // last_login
                                      _buildDetailRow(
                                        icon: Icons.history_outlined,
                                        label: 'សកម្មភាពចុងក្រោយ',
                                        text: _formatDateTime(
                                          userData?['last_login'],
                                        ),
                                        hasArrow: false,
                                      ),

                                      // created_at
                                      _buildDetailRow(
                                        icon: Icons.calendar_today_rounded,
                                        label: 'កាលបរិច្ឆេទបង្កើត',
                                        text: _formatDateOnly(
                                          userData?['created_at'],
                                        ),
                                        hasArrow: false,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Second Tab - Sales History
                          SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: RefreshIndicator(
                              key: GlobalKey<RefreshIndicatorState>(),
                              color: Colors.blue[800],
                              backgroundColor: Colors.white,
                              onRefresh:
                                  () async => await provider.getUserDetails(
                                    id: widget.id,
                                  ),
                              child:
                                  provider.isLoading
                                      ? Center(
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            SizedBox(
                                              height: 60,
                                              width: 60,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.0,
                                              ),
                                            ),
                                            Text(
                                              'សូមរងចាំ',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                      : provider.error != null
                                      ? Center(
                                        child: Text('Something went wrong'),
                                      )
                                      : SafeArea(
                                        child: Column(
                                          children: [
                                            // Total Sales Section
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(20),
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                border: Border(
                                                  bottom: BorderSide(
                                                    color: Color(0xFFE5E5E5),
                                                    width: 1,
                                                  ),
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'ការលក់សរុប',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: HColors.darkgrey,
                                                    ),
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    NumberFormat(
                                                      "#,##0",
                                                    ).format(
                                                      userData?['totalSales']
                                                              ?.toDouble() ??
                                                          0.0,
                                                    ),
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontFamily:
                                                          'KantumruyPro',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Sales History List
                                            ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              itemCount:
                                                  provider
                                                      .groupedTransactions
                                                      .length,
                                              itemBuilder: (context, index) {
                                                final group =
                                                    provider
                                                        .groupedTransactions[index];
                                                return Column(
                                                  children: [
                                                    _buildDateHeader(
                                                      group['date'],
                                                    ),
                                                    ...group['transactions'].asMap().entries.map((
                                                      entry,
                                                    ) {
                                                      final transaction =
                                                          entry.value;
                                                      final String avatarUrl =
                                                          transaction['cashier']['avatar'] !=
                                                                  null
                                                              ? 'https://pos-v2-file.uat.camcyber.com/${transaction['cashier']['avatar']}'
                                                              : '';
                                                      return _buildSalesItem(
                                                        transaction['receipt_number'] ??
                                                            'N/A',
                                                        NumberFormat(
                                                          "#,##0 ៛",
                                                        ).format(
                                                          transaction['total_price']
                                                                  ?.toDouble() ??
                                                              0.0,
                                                        ),
                                                        avatarUrl,
                                                        transaction['id'],
                                                        provider,
                                                        transaction['cashier']?['name'] ??
                                                            'Unknown',
                                                      );
                                                    }).toList(),
                                                  ],
                                                );
                                              },
                                            ),
                                            SizedBox(height: 20),
                                          ],
                                        ),
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String text,
    bool hasArrow = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Box
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(icon, color: HColors.darkgrey),
          ),
          const SizedBox(width: 12),

          // Text Box
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: HColors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (hasArrow) ...[
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: HColors.darkgrey),
          ],
        ],
      ),
    );
  }

  Widget _buildDateHeader(String date) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: const Color(0xFFF0F2F5),
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

  Widget _buildSalesItem(
    String order,
    String amount,
    String avatarUrl,
    int id,
    DetailUserProvider provider,
    String cashierName,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1)),
      ),
      child: Row(
        children: [
          // Transaction icon
          SizedBox(
            width: 40,
            height: 40,
            child: const Icon(
              Icons.receipt_long,
              color: HColors.darkgrey,
              size: 20,
            ),
          ),
          // Transaction ID and Cashier Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: HColors.darkgrey,
                  ),
                ),
                Text(
                  cashierName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: HColors.darkgrey,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          // Amount
          Text(
            amount,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: HColors.green,
            ),
          ),
          const SizedBox(width: 8),

          // User avatar
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: ClipOval(
              child:
                  avatarUrl.isNotEmpty
                      ? Image.network(
                        avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Color(0xFFFF9800),
                            child: const Icon(
                              Icons.person,
                              size: 14,
                              color: Colors.white,
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Color(0xFFE5E5E5),
                            child: const Center(
                              child: SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          );
                        },
                      )
                      : Container(
                        color: Color(0xFFFF9800),
                        child: const Icon(
                          Icons.person,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
