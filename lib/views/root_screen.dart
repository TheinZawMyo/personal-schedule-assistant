import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'home/home_screen.dart';
import 'stats/stats_screen.dart';
import 'challenges/challenges_screen.dart';
import 'settings/settings_screen.dart';
import '../core/theme/app_colors.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ChallengesScreen(),
    const StatsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.surface,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Theme.of(context).textTheme.bodySmall?.color,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.layoutGrid),
              activeIcon: Icon(
                LucideIcons.layoutGrid,
                color: AppColors.primary,
              ),
              label: 'Daily',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.trophy),
              activeIcon: Icon(LucideIcons.trophy, color: AppColors.primary),
              label: 'Challenges',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.barChart3),
              activeIcon: Icon(LucideIcons.barChart3, color: AppColors.primary),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.settings),
              activeIcon: Icon(LucideIcons.settings, color: AppColors.primary),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
