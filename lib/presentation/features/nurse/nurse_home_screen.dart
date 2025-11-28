import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/themes/app_theme.dart';
import '../profile/profile_screen.dart';
import 'nurse_sessions_screen.dart'; // ⬅️ pastikan file ini ADA

import '../../providers/auth_provider.dart';

class NurseHomeScreen extends ConsumerStatefulWidget {
  const NurseHomeScreen({super.key});

  @override
  ConsumerState<NurseHomeScreen> createState() => _NurseHomeScreenState();
}

class _NurseHomeScreenState extends ConsumerState<NurseHomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _tab.addListener(() {
      if (!_tab.indexIsChanging) {
        setState(() => _currentIndex = _tab.index);
      }
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      body: TabBarView(
        controller: _tab,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          NurseSessionsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [AppShadows.medium],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: TabBar(
            controller: _tab,
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primaryColor,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            unselectedLabelStyle:
            const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            tabs: const [
              Tab(icon: Icon(Icons.inbox_rounded), text: 'Assigned Chats'),
              Tab(icon: Icon(Icons.person_rounded), text: 'Profil'),
            ],
          ),
        ),
      ),
    );
  }
}
