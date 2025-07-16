import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SubscriptionCardWidget extends StatelessWidget {
  final Map<String, dynamic> subscriptionData;
  final VoidCallback onManageSubscription;

  const SubscriptionCardWidget({
    Key? key,
    required this.subscriptionData,
    required this.onManageSubscription,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isActive = subscriptionData["status"] == "Active";

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive
              ? [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                ]
              : [
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.05),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                : Theme.of(context).shadowColor.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.2)
                      : Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomIconWidget(
                  iconName: isActive ? 'star' : 'star_border',
                  color: isActive
                      ? Colors.white
                      : Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subscription',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: isActive
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '${subscriptionData["plan"] ?? "Free"} Plan',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isActive
                                ? Colors.white.withValues(alpha: 0.9)
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.2)
                      : Theme.of(context)
                          .colorScheme
                          .tertiary
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  subscriptionData["status"] ?? "Inactive",
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isActive
                            ? Colors.white
                            : Theme.of(context).colorScheme.tertiary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          if (isActive) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        subscriptionData["price"] ?? "\$2.00/week",
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Billing',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        subscriptionData["renewalDate"] ?? "N/A",
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onManageSubscription,
              style: ElevatedButton.styleFrom(
                backgroundColor: isActive
                    ? Colors.white
                    : Theme.of(context).colorScheme.primary,
                foregroundColor: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Colors.white,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                isActive ? 'Manage Subscription' : 'Upgrade to Premium',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
