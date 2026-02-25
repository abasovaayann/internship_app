import 'package:flutter/material.dart';

import '../../database/app_database.dart';
import '../../models/activity_stats.dart';
import '../../models/login_history_model.dart';
import '../../repositories/diary_repository.dart';
import '../../services/auth_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  // Unified green theme (matching diary page)
  static const primary = Color(0xFF13EC5B);
  static const backgroundDark = Color(0xFF102216);
  static const surfaceDark = Color(0xFF1A2E22);
  static const borderGreen = Color(0xFF326744);
  static const textMuted = Color(0xFF92C9A4);

  late TabController _tabController;

  bool _loading = true;
  List<LoginHistoryModel> _loginHistory = const [];
  ActivityStats _activityStats = ActivityStats.empty;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final user = AuthService.currentUser;
    if (user == null) {
      if (!mounted) return;
      setState(() => _loading = false);
      return;
    }

    if (mounted) setState(() => _loading = true);

    // Load both data sources in parallel
    final results = await Future.wait([
      AuthService.loginHistoryRepository.getHistory(user.id, limit: 50),
      DiaryRepository(AppDatabase.instance).getActivityStats(user.id),
    ]);

    if (!mounted) return;
    setState(() {
      _loginHistory = results[0] as List<LoginHistoryModel>;
      _activityStats = results[1] as ActivityStats;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        backgroundColor: backgroundDark,
        elevation: 0,
        title: const Text(
          'History & Analytics',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primary,
          labelColor: primary,
          unselectedLabelColor: textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'Login History', icon: Icon(Icons.history)),
            Tab(text: 'Activity Stats', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: primary))
          : TabBarView(
              controller: _tabController,
              children: [_buildLoginHistoryTab(), _buildActivityStatsTab()],
            ),
    );
  }

  Widget _buildLoginHistoryTab() {
    if (_loginHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No login history yet',
              style: TextStyle(
                color: textMuted,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: primary,
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _loginHistory.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final login = _loginHistory[i];
          final isFirst = i == 0;
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isFirst ? primary.withValues(alpha: 0.15) : surfaceDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isFirst ? primary : borderGreen,
                width: isFirst ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isFirst ? primary : borderGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFirst ? Icons.login : Icons.history,
                    color: isFirst ? backgroundDark : textMuted,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isFirst ? 'Current Session' : login.relativeTime,
                        style: TextStyle(
                          color: isFirst ? primary : Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        login.formattedTime,
                        style: const TextStyle(color: textMuted, fontSize: 13),
                      ),
                      if (login.deviceInfo != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          login.deviceInfo!,
                          style: TextStyle(
                            color: textMuted.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivityStatsTab() {
    if (_activityStats.totalEntries == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics,
              size: 64,
              color: textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No diary entries yet',
              style: TextStyle(
                color: textMuted,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start writing to see your activity stats!',
              style: TextStyle(color: textMuted, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          _buildSummaryCards(),
          const SizedBox(height: 24),

          // Most Active Day
          _buildSectionTitle('Most Active Day'),
          const SizedBox(height: 12),
          _buildDayOfWeekChart(),
          const SizedBox(height: 24),

          // Most Active Time
          _buildSectionTitle('Most Active Time'),
          const SizedBox(height: 12),
          _buildHourChart(),
          const SizedBox(height: 24),

          // Streak info
          _buildSectionTitle('Writing Streaks'),
          const SizedBox(height: 12),
          _buildStreakCards(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.article,
            label: 'Total Entries',
            value: '${_activityStats.totalEntries}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.local_fire_department,
            label: 'Current Streak',
            value: '${_activityStats.currentStreak} days',
            highlight: _activityStats.currentStreak > 0,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildDayOfWeekChart() {
    final maxCount = _activityStats.entriesByDayOfWeek.values.fold(
      0,
      (a, b) => a > b ? a : b,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGreen),
      ),
      child: Column(
        children: [
          if (_activityStats.mostActiveDay != null) ...[
            Row(
              children: [
                const Icon(Icons.emoji_events, color: primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _activityStats.mostActiveDayDescription ?? '',
                    style: const TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final count = _activityStats.entriesByDayOfWeek[i] ?? 0;
              final fraction = maxCount > 0 ? count / maxCount : 0.0;
              final isActive = i == _activityStats.mostActiveDay;

              return _DayBar(
                day: ActivityStats.dayNameShort(i),
                count: count,
                fraction: fraction,
                isHighlighted: isActive,
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHourChart() {
    // Group hours into 6 time periods
    final periods = <String, int>{
      'Night\n12-5AM': 0,
      'Early\n5-8AM': 0,
      'Morning\n8-12PM': 0,
      'Afternoon\n12-5PM': 0,
      'Evening\n5-9PM': 0,
      'Night\n9-12AM': 0,
    };

    for (final entry in _activityStats.entriesByHour.entries) {
      final hour = entry.key;
      final count = entry.value;
      if (hour >= 0 && hour < 5) {
        periods['Night\n12-5AM'] = periods['Night\n12-5AM']! + count;
      } else if (hour >= 5 && hour < 8) {
        periods['Early\n5-8AM'] = periods['Early\n5-8AM']! + count;
      } else if (hour >= 8 && hour < 12) {
        periods['Morning\n8-12PM'] = periods['Morning\n8-12PM']! + count;
      } else if (hour >= 12 && hour < 17) {
        periods['Afternoon\n12-5PM'] = periods['Afternoon\n12-5PM']! + count;
      } else if (hour >= 17 && hour < 21) {
        periods['Evening\n5-9PM'] = periods['Evening\n5-9PM']! + count;
      } else {
        periods['Night\n9-12AM'] = periods['Night\n9-12AM']! + count;
      }
    }

    final maxCount = periods.values.fold(0, (a, b) => a > b ? a : b);
    String? mostActivePeriod;
    int maxPeriodCount = 0;
    for (final entry in periods.entries) {
      if (entry.value > maxPeriodCount) {
        maxPeriodCount = entry.value;
        mostActivePeriod = entry.key;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGreen),
      ),
      child: Column(
        children: [
          if (_activityStats.mostActiveHour != null) ...[
            Row(
              children: [
                const Icon(Icons.schedule, color: primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _activityStats.mostActiveTimeDescription ?? '',
                    style: const TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: periods.entries.map((entry) {
              final fraction = maxCount > 0 ? entry.value / maxCount : 0.0;
              return _DayBar(
                day: entry.key,
                count: entry.value,
                fraction: fraction,
                isHighlighted: entry.key == mostActivePeriod && entry.value > 0,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCards() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.local_fire_department,
            label: 'Current Streak',
            value: '${_activityStats.currentStreak}',
            subtitle: 'consecutive days',
            highlight: _activityStats.currentStreak > 0,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.emoji_events,
            label: 'Longest Streak',
            value: '${_activityStats.longestStreak}',
            subtitle: 'your personal best',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final bool highlight;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    this.highlight = false,
  });

  static const primary = Color(0xFF13EC5B);
  static const surfaceDark = Color(0xFF1A2E22);
  static const borderGreen = Color(0xFF326744);
  static const textMuted = Color(0xFF92C9A4);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight ? primary.withValues(alpha: 0.15) : surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight ? primary : borderGreen,
          width: highlight ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: highlight ? primary : textMuted, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: highlight ? primary : Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                color: textMuted.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  final String day;
  final int count;
  final double fraction;
  final bool isHighlighted;

  const _DayBar({
    required this.day,
    required this.count,
    required this.fraction,
    this.isHighlighted = false,
  });

  static const primary = Color(0xFF13EC5B);
  static const borderGreen = Color(0xFF326744);
  static const textMuted = Color(0xFF92C9A4);
  static const backgroundDark = Color(0xFF102216);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            color: isHighlighted ? primary : textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 32,
          height: 80,
          decoration: BoxDecoration(
            color: backgroundDark,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 32,
              height: 80 * fraction.clamp(0.05, 1.0),
              decoration: BoxDecoration(
                color: isHighlighted ? primary : borderGreen,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          day,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isHighlighted ? primary : textMuted,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
