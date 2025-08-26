import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../core/providers/reservation_provider.dart';
import '../../providers/auth_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Appearance Section
              _buildSectionHeader(context, 'Appearance'),
              _buildSettingCard(
                context,
                icon: Icons.dark_mode,
                title: 'Dark Mode',
                subtitle: 'Switch between light and dark theme',
                trailing: Platform.isIOS
                    ? CupertinoSwitch(
                        value: appProvider.isDarkMode,
                        onChanged: (value) => appProvider.toggleDarkMode(),
                      )
                    : Switch(
                        value: appProvider.isDarkMode,
                        onChanged: (value) => appProvider.toggleDarkMode(),
                      ),
              ),
              
              _buildSettingCard(
                context,
                icon: Icons.language,
                title: 'Language',
                subtitle: 'Change app language',
                trailing: DropdownButton<String>(
                  value: appProvider.selectedLanguage,
                  underline: Container(),
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'es', child: Text('Español')),
                    DropdownMenuItem(value: 'fr', child: Text('Français')),
                    DropdownMenuItem(value: 'de', child: Text('Deutsch')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      appProvider.setLanguage(value);
                    }
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Notifications Section
              _buildSectionHeader(context, 'Notifications'),
              _buildSettingCard(
                context,
                icon: Icons.notifications,
                title: 'Push Notifications',
                subtitle: 'Receive booking confirmations and reminders',
                trailing: Platform.isIOS
                    ? CupertinoSwitch(
                        value: appProvider.notificationsEnabled,
                        onChanged: (value) => appProvider.toggleNotifications(),
                      )
                    : Switch(
                        value: appProvider.notificationsEnabled,
                        onChanged: (value) => appProvider.toggleNotifications(),
                      ),
              ),

              _buildSettingCard(
                context,
                icon: Icons.schedule,
                title: 'Reminder Time',
                subtitle: 'When to send appointment reminders',
                trailing: const Text('1 hour before'),
                onTap: () => _showReminderTimePicker(context),
              ),

              const SizedBox(height: 24),

              // Account Section
              _buildSectionHeader(context, 'Account'),
              _buildSettingCard(
                context,
                icon: Icons.person,
                title: 'Edit Profile',
                subtitle: 'Update your personal information',
                onTap: () => _showEditProfileDialog(context),
              ),

              _buildSettingCard(
                context,
                icon: Icons.security,
                title: 'Privacy & Security',
                subtitle: 'Manage your privacy settings',
                onTap: () => _showPrivacySettings(context),
              ),

              _buildSettingCard(
                context,
                icon: Icons.backup,
                title: 'Backup & Sync',
                subtitle: 'Backup your reservations to cloud',
                onTap: () => _showBackupSettings(context),
              ),

              const SizedBox(height: 24),

              // Support Section
              _buildSectionHeader(context, 'Support'),
              _buildSettingCard(
                context,
                icon: Icons.help,
                title: 'Help & FAQ',
                subtitle: 'Get help and find answers',
                onTap: () => _showHelpDialog(context),
              ),

              _buildSettingCard(
                context,
                icon: Icons.feedback,
                title: 'Send Feedback',
                subtitle: 'Help us improve the app',
                onTap: () => _showFeedbackDialog(context),
              ),

              _buildSettingCard(
                context,
                icon: Icons.info,
                title: 'About',
                subtitle: 'App version and information',
                onTap: () => _showAboutDialog(context),
              ),

              const SizedBox(height: 24),

              // Danger Zone
              _buildSectionHeader(context, 'Danger Zone'),
              _buildSettingCard(
                context,
                icon: Icons.delete_forever,
                title: 'Clear All Data',
                subtitle: 'Remove all reservations and reset app',
                titleColor: Colors.red,
                onTap: () => _showClearDataDialog(context),
              ),

              _buildSettingCard(
                context,
                icon: Icons.logout,
                title: 'Sign Out',
                subtitle: 'Sign out of your account',
                titleColor: Colors.red,
                onTap: () => _showSignOutDialog(context),
              ),

              const SizedBox(height: 32),

              // App Info
              Center(
                child: Column(
                  children: [
                    Text(
                      'Time Reservation App',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Version 1.0.0',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: titleColor ?? Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: titleColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
        onTap: onTap,
      ),
    );
  }

  void _showReminderTimePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reminder Time'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('15 minutes before'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('30 minutes before'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('1 hour before'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('1 day before'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: const Text('Profile editing feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy & Security'),
        content: const Text('Privacy settings coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showBackupSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup & Sync'),
        content: const Text('Cloud backup feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & FAQ'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Q: How do I book an appointment?'),
              Text('A: Select a date on the calendar and tap "Quick Book".'),
              SizedBox(height: 16),
              Text('Q: Can I cancel my booking?'),
              Text('A: Yes, tap on your reservation and select cancel.'),
              SizedBox(height: 16),
              Text('Q: How do I change my profile?'),
              Text('A: Go to Personal tab and tap the edit icon.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Feedback'),
        content: const TextField(
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Tell us what you think...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feedback sent! Thank you.')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Time Reservation',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.calendar_month, size: 48),
      children: [
        const Text('A modern appointment booking app built with Flutter.'),
        const SizedBox(height: 16),
        const Text('Features:'),
        const Text('• Calendar view'),
        const Text('• Real-time booking'),
        const Text('• Platform-aware design'),
        const Text('• Dark mode support'),
      ],
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your reservations and reset the app. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Clear data logic here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data cleared')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return ElevatedButton(
                onPressed: authProvider.isLoading 
                    ? null 
                    : () async {
                        Navigator.pop(context); // Close dialog first
                        final success = await authProvider.logout(context);
                        
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Signed out successfully')),
                          );
                        } else if (!success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(authProvider.errorMessage ?? 'Sign out failed'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: authProvider.isLoading 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Sign Out'),
              );
            },
          ),
        ],
      ),
    );
  }
}
