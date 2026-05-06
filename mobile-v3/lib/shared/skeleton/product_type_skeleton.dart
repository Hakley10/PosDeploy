import 'package:flutter/material.dart';
import 'package:calendar/shared/entity/helper/colors.dart';

class ProductTypeSkeleton extends StatelessWidget {
  const ProductTypeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Product type list skeleton
        Expanded(
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: 10, // Display 10 placeholder items
            itemBuilder: (context, index) {
              return _buildProductTypeItemSkeleton();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductTypeItemSkeleton() {
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
        margin: const EdgeInsets.only(bottom: 0),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: HColors.darkgrey.withOpacity(0.1),
            child: Container(
              width: 25,
              height: 25,
              color: HColors.grey.withOpacity(0.1),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Container(
                  width: 150,
                  height: 16,
                  color: HColors.grey.withOpacity(0.1),
                ),
              ),
              const SizedBox(width: 70),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    color: HColors.grey.withOpacity(0.1),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 24,
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