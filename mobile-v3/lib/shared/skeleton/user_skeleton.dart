import 'package:flutter/material.dart';
import 'package:calendar/shared/entity/helper/colors.dart';

class UserSkeleton extends StatelessWidget {
  const UserSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // User list skeleton
        Expanded(
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: 10,
            itemBuilder: (context, index) {
              return _buildUserItemSkeleton();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserItemSkeleton() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: HColors.darkgrey.withOpacity(0.2),
            width: 1.0,
          ),
        ),
      ),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar skeleton
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: HColors.grey.withOpacity(0.1),
                ),
              ),
              const SizedBox(width: 12),
              // Name + Phone skeleton
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 150,
                      height: 16,
                      color: HColors.grey.withOpacity(0.1),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 100,
                      height: 14,
                      color: HColors.grey.withOpacity(0.1),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Orders + Sales skeleton
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        color: HColors.grey.withOpacity(0.1),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 30,
                        height: 14,
                        color: HColors.grey.withOpacity(0.1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 60,
                    height: 14,
                    color: HColors.grey.withOpacity(0.1),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}