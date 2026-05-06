import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:calendar/app_routes.dart';

void showOtherMenuBottomSheet(BuildContext parentContext) {
  showModalBottomSheet(
    context: parentContext,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
    ),
    backgroundColor: Colors.white,
    builder: (BuildContext sheetContext) {
      return Container(
        padding: const EdgeInsets.only(top: 10.0, bottom: 30.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              // margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Menu options in a row - aligned to match bottom navbar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
              ), // Align with bottom navbar
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMenuCard(
                    icon: Icons.category_rounded,
                    label: 'ប្រភេទផលិតផល',
                    color: const Color(0xFF1E3A8A), // Dark blue
                    onTap: () {
                      Navigator.pop(sheetContext);
                      parentContext.push(AppRoutes.productType);
                    },
                  ),
                  _buildMenuCard(
                    icon: Icons.people_alt,
                    label: 'អ្នកប្រើប្រាស់',
                    color: const Color(0xFF1E3A8A), // Dark blue
                    onTap: () {
                      Navigator.pop(sheetContext);
                      parentContext.push(AppRoutes.users);
                      // context.push(AppRoutes.profile);
                    },
                  ),

                  _buildMenuCard(
                    icon: Icons.person,
                    label: 'គណនី',
                    color: const Color(0xFF1E3A8A), // Dark blue
                    onTap: () {
                      Navigator.pop(sheetContext);
                      parentContext.push(AppRoutes.profile);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}

Widget _buildMenuCard({
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  return Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 8),
            // Label
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ),
  );
}
