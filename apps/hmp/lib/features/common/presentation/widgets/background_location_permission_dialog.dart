import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mobile/app/theme/theme.dart';
import 'package:mobile/features/common/presentation/widgets/hmp_custom_button.dart';
import 'package:mobile/generated/locale_keys.g.dart';

class BackgroundLocationPermissionDialog extends StatelessWidget {
  final VoidCallback onAllow;
  final VoidCallback onDeny;

  const BackgroundLocationPermissionDialog({
    super.key,
    required this.onAllow,
    required this.onDeny,
  });

  static Future<bool?> show(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackgroundLocationPermissionDialog(
        onAllow: () => Navigator.of(context).pop(true),
        onDeny: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: hmpBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on,
                size: 40,
                color: hmpBlue,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              LocaleKeys.permission_background_location_title.tr(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              LocaleKeys.permission_background_location_desc.tr(),
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Feature list
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFeatureItem(
                    icon: Icons.check_circle_outline,
                    title: LocaleKeys.permission_auto_checkin_title.tr(),
                    description: LocaleKeys.permission_auto_checkin_desc.tr(),
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(
                    icon: Icons.notifications_outlined,
                    title: LocaleKeys.permission_nearby_store_title.tr(),
                    description: LocaleKeys.permission_nearby_store_desc.tr(),
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(
                    icon: Icons.shield_outlined,
                    title: LocaleKeys.permission_privacy_title.tr(),
                    description: LocaleKeys.permission_privacy_desc.tr(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onDeny,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Text(
                      LocaleKeys.permission_later.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: HMPCustomButton(
                    onPressed: onAllow,
                    text: LocaleKeys.permission_allow.tr(),
                    height: 48,
                    bgColor: const Color(0xFF2CB3FF),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            Text(
              LocaleKeys.permission_settings_change.tr(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: hmpBlue,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}