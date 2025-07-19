import 'package:flutter/material.dart';

import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_stylings.dart';

class CustomersTab extends StatelessWidget {
  const CustomersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Customers',
                style: AppStyling.bold18Black,
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Handle add customer
                },
                icon: const Icon(Icons.person_add),
                label: const Text('Add Customer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.whiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.lightGrey),
            ),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search customers...',
                border: InputBorder.none,
                icon: Icon(Icons.search),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Customers List
          Expanded(
            child: ListView.builder(
              itemCount: 15,
              itemBuilder: (context, index) {
                return _CustomerListItem(
                  customerName: 'Customer ${index + 1}',
                  email: 'customer${index + 1}@example.com',
                  phone: '+1 (555) ${100 + index}-${1000 + index}',
                  totalSpent: 150.0 + (index * 25.5),
                  lastVisit: DateTime.now().subtract(Duration(days: index * 3)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerListItem extends StatelessWidget {
  final String customerName;
  final String email;
  final String phone;
  final double totalSpent;
  final DateTime lastVisit;

  const _CustomerListItem({
    required this.customerName,
    required this.email,
    required this.phone,
    required this.totalSpent,
    required this.lastVisit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Row(
        children: [
          // Customer Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.person,
              color: AppColors.primaryColor,
              size: 32,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Customer Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerName,
                  style: AppStyling.semi14Black,
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: AppStyling.regular12Grey,
                ),
                const SizedBox(height: 4),
                Text(
                  phone,
                  style: AppStyling.regular12Grey,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Total: \$${totalSpent.toStringAsFixed(2)}',
                      style: AppStyling.semi12Black.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Last: ${_formatDate(lastVisit)}',
                      style: AppStyling.regular10Grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Actions
          PopupMenuButton<String>(
            onSelected: (value) {
              // Handle menu actions
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 16),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'history',
                child: Row(
                  children: [
                    Icon(Icons.history, size: 16),
                    SizedBox(width: 8),
                    Text('Purchase History'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 16, color: AppColors.errorColor),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
            child: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
} 