import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/settings_provider.dart';
import '../../core/theme/app_colors.dart';
// import '../../services/notification_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader(context, 'Notifications'),
          _buildSwitchTile(
            context,
            icon: LucideIcons.bellRing,
            title: 'Morning Summary',
            subtitle: 'Get a daily digest at 7:00 AM',
            value: settings.morningSummaryEnabled,
            onChanged: (val) => notifier.updateSettings(
              settings.copyWith(morningSummaryEnabled: val),
            ),
          ),
          _buildListTile(
            context,
            icon: LucideIcons.clock,
            title: 'Summary Time',
            trailing: Text(
              '${settings.morningSummaryHour}:${settings.morningSummaryMinute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(
                  hour: settings.morningSummaryHour,
                  minute: settings.morningSummaryMinute,
                ),
              );
              if (picked != null) {
                notifier.updateSettings(
                  settings.copyWith(
                    morningSummaryHour: picked.hour,
                    morningSummaryMinute: picked.minute,
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'App Preferences'),
          _buildSwitchTile(
            context,
            icon: LucideIcons.activity,
            title: 'Ongoing Notification',
            subtitle: 'Show notification for active tasks',
            value: settings.ongoingNotificationEnabled,
            onChanged: (val) => notifier.updateSettings(
              settings.copyWith(ongoingNotificationEnabled: val),
            ),
          ),
          _buildSwitchTile(
            context,
            icon: LucideIcons.zap,
            title: 'Haptic Feedback',
            subtitle: 'Vibrate on task completion',
            value: settings.hapticFeedbackEnabled,
            onChanged: (val) => notifier.updateSettings(
              settings.copyWith(hapticFeedbackEnabled: val),
            ),
          ),
          _buildSwitchTile(
            context,
            icon: LucideIcons.moon,
            title: 'Dark Mode',
            subtitle: settings.darkMode
                ? 'Dark theme enabled'
                : 'Light theme enabled',
            value: settings.darkMode,
            onChanged: (val) =>
                notifier.updateSettings(settings.copyWith(darkMode: val)),
          ),
          // _buildTestNotificationButton(context),
          const SizedBox(height: 40),
          Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium?.color,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: AppColors.primary, size: 20),
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 13,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.accent, size: 20),
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  // Widget _buildTestNotificationButton(BuildContext context) {
  //   return Container(
  //     margin: const EdgeInsets.only(top: 12, bottom: 12),
  //     decoration: BoxDecoration(
  //       gradient: const LinearGradient(
  //         colors: [AppColors.primary, AppColors.accent],
  //       ),
  //       borderRadius: BorderRadius.circular(16),
  //     ),
  //     child: Material(
  //       color: Colors.transparent,
  //       child: InkWell(
  //         borderRadius: BorderRadius.circular(16),
  //         onTap: () async {
  //           await NotificationService().showTestNotification();
  //           if (context.mounted) {
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               const SnackBar(
  //                 content: Text('Test notification sent!'),
  //                 duration: Duration(seconds: 2),
  //                 behavior: SnackBarBehavior.floating,
  //               ),
  //             );
  //           }
  //         },
  //         child: const Padding(
  //           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               Icon(Icons.notifications_active, color: Colors.white, size: 20),
  //               SizedBox(width: 10),
  //               Text(
  //                 'Send Test Notification',
  //                 style: TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 15,
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
