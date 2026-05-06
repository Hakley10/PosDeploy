import 'package:flutter/material.dart';
import 'package:calendar/shared/entity/helper/colors.dart';

class ProductSkeleton extends StatelessWidget {
  const ProductSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Product list skeleton
        Expanded(
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: 10,
            itemBuilder: (context, index) {
              return _buildProductItemSkeleton();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductItemSkeleton() {
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
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: HColors.grey.withOpacity(0.1),
            ),
          ),
          const SizedBox(width: 12),
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
                  height: 13,
                  color: HColors.grey.withOpacity(0.1),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 80,
                  height: 14,
                  color: HColors.grey.withOpacity(0.1),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    color: HColors.grey.withOpacity(0.1),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 30,
                    height: 13,
                    color: HColors.grey.withOpacity(0.1),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                width: 60,
                height: 13,
                color: HColors.grey.withOpacity(0.1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}