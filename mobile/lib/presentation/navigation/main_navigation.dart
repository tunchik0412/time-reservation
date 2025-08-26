import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import '../pages/personal/personal_page.dart';
import '../pages/calendar/calendar_page.dart';
import '../pages/settings/settings_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 1; // Start with Calendar tab (middle tab)

  final List<Widget> _pages = [
    const PersonalPage(),
    const CalendarPage(),
    const SettingsPage(),
  ];

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Personal',
    ),
    NavigationItem(
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month,
      label: 'Calendar',
    ),
    NavigationItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Platform.isIOS
          ? _buildCupertinoTabBar()
          : _buildMaterialBottomNav(),
    );
  }

  Widget _buildMaterialBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _onTabTapped,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      elevation: 8,
      items: _navigationItems.map((item) {
        final index = _navigationItems.indexOf(item);
        final isSelected = index == _currentIndex;
        
        return BottomNavigationBarItem(
          icon: Icon(
            isSelected ? item.activeIcon : item.icon,
            size: 24,
          ),
          label: item.label,
        );
      }).toList(),
    );
  }

  Widget _buildCupertinoTabBar() {
    return CupertinoTabBar(
      currentIndex: _currentIndex,
      onTap: _onTabTapped,
      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.9),
      activeColor: Theme.of(context).colorScheme.primary,
      inactiveColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      height: 60,
      items: _navigationItems.map((item) {
        final index = _navigationItems.indexOf(item);
        final isSelected = index == _currentIndex;
        
        return BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? item.activeIcon : item.icon,
                  size: 24,
                ),
                const SizedBox(height: 2),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Add haptic feedback for iOS
    if (Platform.isIOS) {
      // Note: Would need haptic_feedback package for actual haptic feedback
      // HapticFeedback.selectionClick();
    }
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
