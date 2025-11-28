import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glucoheart_flutter/presentation/features/education/education_list_screen.dart';
import 'package:glucoheart_flutter/presentation/features/education/widgets/home_recent_articles.dart';
import 'package:glucoheart_flutter/presentation/features/examination/examination_history_screen.dart';
import 'package:glucoheart_flutter/presentation/features/profile/profile_screen.dart';
import 'package:glucoheart_flutter/presentation/providers/examination_provider.dart';
import '../../../config/themes/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../chat/chat_screen.dart';
import 'widgets/feature_card.dart';
import 'widgets/health_metric_card.dart';
import 'widgets/home_header.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _tabController;
  final GlobalKey<EducationListScreenState> _educationScreenKey = GlobalKey<EducationListScreenState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToEducationAndFocusSearch() {
    _tabController.animateTo(2); // Index 2 untuk tab Edukasi
    // Delay sedikit untuk memastikan screen sudah terbuild
    Future.delayed(const Duration(milliseconds: 300), () {
      _educationScreenKey.currentState?.focusSearchBar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(), // Disable swiping
        children: [
          _HomePage(
            onProfileTap: () {
              // Langsung akses TabController di sini untuk navigasi
              _tabController.animateTo(3); // Index 3 untuk tab Profil
            },
            onExaminationTap: () {
              _tabController.animateTo(1); // Index 1 untuk tab Pemeriksaan
            },
            onEducationTap: () {
              _tabController.animateTo(2);
            },
            onSearchTap: _navigateToEducationAndFocusSearch,
          ),
          const ExaminationHistoryScreen(),
          EducationListScreen(key: _educationScreenKey),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [AppShadows.medium],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primaryColor,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primaryColor,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
            tabs: const [
              Tab(
                icon: Icon(Icons.home_rounded),
                text: 'Beranda',
              ),
              Tab(
                icon: Icon(Icons.monitor_heart_rounded),
                text: 'Pemeriksaan',
              ),
              Tab(
                icon: Icon(Icons.school_rounded),
                text: 'Edukasi',
              ),
              Tab(
                icon: Icon(Icons.person_rounded),
                text: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomePage extends ConsumerWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onExaminationTap;
  final VoidCallback onEducationTap;
  final VoidCallback onSearchTap;

  const _HomePage({
    super.key,
    required this.onProfileTap,
    required this.onExaminationTap,
    required this.onEducationTap,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeHeader(
              userName: user?.name ?? 'Pengguna',
              profilePicture: user?.profilePicture ?? '',
              onNotificationTap: () {
                // Handle notification tap
              },
              onSearchTap: onSearchTap, // Menggunakan callback baru
              onProfileTap: onProfileTap,
            ),
            const SizedBox(height: 24),

            // Main features grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fitur Utama',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Responsive grid layout
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          SizedBox(
                            width: (constraints.maxWidth - 16) / 2,
                            child: FeatureCard(
                              title: 'Pemeriksaan',
                              description: 'Rekam gula darah & tekanan darah',
                              icon: Icons.monitor_heart_rounded,
                              gradient: AppGradients.examGradient,
                              onTap: onExaminationTap,
                            ),
                          ),
                          SizedBox(
                            width: (constraints.maxWidth - 16) / 2,
                            child: FeatureCard(
                              title: 'Edukasi',
                              description: 'Pelajari tentang kesehatan Anda',
                              icon: Icons.school_rounded,
                              gradient: AppGradients.educationGradient,
                              onTap: onEducationTap, // <= arahkan ke tab Edukasi
                            ),
                          ),
                          SizedBox(
                            width: (constraints.maxWidth - 16) / 2,
                            child: FeatureCard(
                              title: 'Chat Nakes',
                              description: 'Konsultasi dengan ahli Tenaga Kesehatan',
                              icon: Icons.chat_rounded,
                              gradient: AppGradients.chatGradient,
                              onTap: () async {
                                try {
                                  // 1) Ambil instance API dari Riverpod
                                  final api = ref.read(chatApiProvider);

                                  // 2) Buat/ambil sesi 1:1 by role (ADMIN/SUPPORT)
                                  //    Sekarang method pakai positional arg dan return Map session
                                  final sessionJson = await api.createOrGetSessionByRole('ADMIN');

                                  // 3) Ambil sessionId dari Map
                                  final sessionId = (sessionJson['id'] as num).toInt();

                                  // 4) Navigate ke ChatScreen
                                  if (context.mounted) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => ChatScreen(sessionId: sessionId)),
                                    );
                                  }
                                } catch (e) {
                                  // optional: feedback ke user
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Gagal membuka chat: $e')),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            width: (constraints.maxWidth - 16) / 2,
                            child: FeatureCard(
                              title: 'Grup Diskusi',
                              description: 'Berbagi dengan sesama pengguna',
                              icon: Icons.people_rounded,
                              gradient: AppGradients.communityGradient,
                              onTap: () {
                                Navigator.pushNamed(context, '/discussion/rooms');
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Health status
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Status Kesehatan',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          onExaminationTap();
                        },
                        icon: const Icon(
                          Icons.show_chart_rounded,
                          size: 18,
                        ),
                        label: const Text('Lihat Detail'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Responsive health metrics layout
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          SizedBox(
                            width: (constraints.maxWidth - 16) / 2,
                            child: Consumer(
                              builder: (context, ref, _) {
                                final async = ref.watch(examinationNotifierProvider);
                                return async.when(
                                  loading: () => const HealthMetricCard(
                                    title: 'Gula Darah',
                                    value: '...',
                                    unit: 'mg/dL',
                                    isNormal: true,
                                    icon: Icons.water_drop_rounded,
                                    trend: 'down',
                                    trendValue: 0.0,
                                  ),
                                  error: (e, __) => const HealthMetricCard(
                                    title: 'Gula Darah',
                                    value: '-',
                                    unit: 'mg/dL',
                                    isNormal: true,
                                    icon: Icons.water_drop_rounded,
                                    trend: 'down',
                                    trendValue: 0.0,
                                  ),
                                  data: (list) {
                                    // Urutkan dari terbaru
                                    final data = [...list]..sort((a, b) => b.dateTime.compareTo(a.dateTime));

                                    // Pilih nilai gula darah dari pemeriksaan terbaru (prioritas: GDP -> GDS -> PP)
                                    double? pickGlu(x) => x.bloodGlucoseFasting ?? x.bloodGlucoseRandom ?? x.bloodGlucosePostprandial;
                                    String gluTypeOf(x) => x.bloodGlucoseFasting != null
                                        ? 'GDP'
                                        : (x.bloodGlucoseRandom != null ? 'GDS' : 'PP');

                                    double? latestGlu;
                                    String? gluType;
                                    for (final e in data) {
                                      final v = pickGlu(e);
                                      if (v != null) {
                                        latestGlu = v;
                                        gluType = gluTypeOf(e);
                                        break;
                                      }
                                    }

                                    // Cari pembanding sebelumnya
                                    double? prevGlu;
                                    if (latestGlu != null) {
                                      bool afterFirst = false;
                                      for (final e in data) {
                                        final v = pickGlu(e);
                                        if (v != null) {
                                          if (!afterFirst) {
                                            afterFirst = true; // skip yang terbaru
                                            continue;
                                          }
                                          prevGlu = v;
                                          break;
                                        }
                                      }
                                    }

                                    // Hitung trend
                                    String trend = 'down';
                                    double trendValue = 0.0;
                                    if (latestGlu != null && prevGlu != null && prevGlu > 0) {
                                      final diff = latestGlu - prevGlu;
                                      trend = diff >= 0 ? 'up' : 'down';
                                      trendValue = (diff.abs() / prevGlu) * 100.0;
                                    }

                                    // Normal range sesuai jenis
                                    bool isNormal = true;
                                    if (latestGlu != null) {
                                      if (gluType == 'GDP') {
                                        isNormal = latestGlu >= 70 && latestGlu <= 100;
                                      } else if (gluType == 'GDS') {
                                        isNormal = latestGlu >= 70 && latestGlu <= 140;
                                      } else {
                                        // PP
                                        isNormal = latestGlu < 140;
                                      }
                                    }

                                    return HealthMetricCard(
                                      title: gluType != null ? ' $gluType' : '',
                                      value: latestGlu?.toStringAsFixed(0) ?? '-',
                                      unit: 'mg/dL',
                                      isNormal: isNormal,
                                      icon: Icons.water_drop_rounded,
                                      trend: trend,
                                      trendValue: double.parse(trendValue.toStringAsFixed(1)),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            width: (constraints.maxWidth - 16) / 2,
                            child: Consumer(
                              builder: (context, ref, _) {
                                final async = ref.watch(examinationNotifierProvider);
                                return async.when(
                                  loading: () => const HealthMetricCard(
                                    title: 'Tekanan Darah',
                                    value: '...',
                                    unit: 'mmHg',
                                    isNormal: true,
                                    icon: Icons.favorite_rounded,
                                    trend: 'down',
                                    trendValue: 0.0,
                                  ),
                                  error: (e, __) => const HealthMetricCard(
                                    title: 'Tekanan Darah',
                                    value: '-',
                                    unit: 'mmHg',
                                    isNormal: true,
                                    icon: Icons.favorite_rounded,
                                    trend: 'down',
                                    trendValue: 0.0,
                                  ),
                                  data: (list) {
                                    final data = [...list]..sort((a, b) => b.dateTime.compareTo(a.dateTime));

                                    // Ambil BP terbaru valid "sys/dia"
                                    int? parseSys(String s) => int.tryParse(s.split('/').first);
                                    int? parseDia(String s) => int.tryParse(s.split('/').last);

                                    String? latestStr;
                                    int? latestSys, latestDia;
                                    for (final e in data) {
                                      if (e.bloodPressure.contains('/')) {
                                        latestStr = e.bloodPressure;
                                        latestSys = parseSys(e.bloodPressure);
                                        latestDia = parseDia(e.bloodPressure);
                                        if (latestSys != null && latestDia != null) break;
                                      }
                                    }

                                    // Cari pembanding sebelumnya
                                    int? prevSys;
                                    for (final e in data) {
                                      if (e.bloodPressure.contains('/')) {
                                        final s = parseSys(e.bloodPressure);
                                        final d = parseDia(e.bloodPressure);
                                        if (s != null && d != null) {
                                          if (e.bloodPressure == latestStr) {
                                            // skip pertama (terbaru)
                                            latestStr = ''; // flag skip only once
                                            continue;
                                          }
                                          prevSys = s;
                                          break;
                                        }
                                      }
                                    }

                                    // Trend berdasarkan systolic
                                    String trend = 'down';
                                    double trendValue = 0.0;
                                    if (latestSys != null && prevSys != null && prevSys > 0) {
                                      final diff = latestSys - prevSys;
                                      trend = diff >= 0 ? 'up' : 'down';
                                      trendValue = (diff.abs() / prevSys) * 100.0;
                                    }

                                    // Normal?
                                    final bool isNormal = (latestSys != null && latestDia != null)
                                        ? (latestSys < 120 && latestDia < 80)
                                        : true;

                                    return HealthMetricCard(
                                      title: 'Tekanan Darah',
                                      value: (latestSys != null && latestDia != null)
                                          ? '$latestSys/$latestDia'
                                          : '-',
                                      unit: 'mmHg',
                                      isNormal: isNormal,
                                      icon: Icons.favorite_rounded,
                                      trend: trend,
                                      trendValue: double.parse(trendValue.toStringAsFixed(1)),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Health tips section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: HomeRecentArticles(
                onSeeAll: onEducationTap,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}