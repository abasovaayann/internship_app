// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Unified dark-green theme (same as login/settings)
  static const primary = Color(0xFF13EC5B);
  static const backgroundDark = Color(0xFF102216);
  static const surfaceDark = Color(0xFF1A2E22);
  static const borderGreen = Color(0xFF326744);
  static const textMuted = Color(0xFF92C9A4);

  int selectedIndex = 0;

  // Check-in state (0.0 to 1.0)
  // TODO: Future work - persist check-in data to a `check_ins` table so values
  // are not lost when the app is closed. For now, these are in-memory only.
  double _moodLevel = 0.70;
  double _sleepQuality = 0.85;
  double _energyLevel = 0.45;

  String _formatDay(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  void _showCheckInDialog() {
    // Temp values for the dialog
    double tempMood = _moodLevel;
    double tempSleep = _sleepQuality;
    double tempEnergy = _energyLevel;
    final today = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: surfaceDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: borderGreen),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daily Check-in',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDay(today),
                    style: TextStyle(
                      color: textMuted,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _CheckInSlider(
                      icon: Icons.sentiment_satisfied,
                      label: 'Mood Level',
                      value: tempMood,
                      onChanged: (v) => setDialogState(() => tempMood = v),
                    ),
                    const SizedBox(height: 20),
                    _CheckInSlider(
                      icon: Icons.nights_stay,
                      label: 'Sleep Quality',
                      value: tempSleep,
                      onChanged: (v) => setDialogState(() => tempSleep = v),
                    ),
                    const SizedBox(height: 20),
                    _CheckInSlider(
                      icon: Icons.bolt,
                      label: 'Energy Level',
                      value: tempEnergy,
                      onChanged: (v) => setDialogState(() => tempEnergy = v),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _moodLevel = tempMood;
                      _sleepQuality = tempSleep;
                      _energyLevel = tempEnergy;
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(content: Text('Check-in updated!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: backgroundDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    // Safety: if user is not logged in, send to login
    if (user == null) {
      // Delay navigation so build finishes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/login');
      });
      return const Scaffold(backgroundColor: backgroundDark);
    }

    return Scaffold(
      backgroundColor: backgroundDark,

      appBar: AppBar(
        backgroundColor: backgroundDark,
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: primary),
          onPressed: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Menu (mock)')));
          },
        ),
        actions: [
          IconButton(
            onPressed: () => context.go('/settings'),
            icon: const Icon(Icons.account_circle, color: primary, size: 30),
          ),
          const SizedBox(width: 6),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primary,
        foregroundColor: backgroundDark,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('New Diary Entry (mock)')),
          );
        },
        icon: const Icon(Icons.edit_square),
        label: const Text(
          'New Diary Entry',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      bottomNavigationBar: _BottomNav(
        index: selectedIndex,
        onTap: (i) {
          setState(() => selectedIndex = i);

          // Navigate to sub-pages
          if (i == 1) context.push('/diary');
          if (i == 2) context.push('/history');
          if (i == 3) context.push('/settings');
        },
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
          children: [
            const SizedBox(height: 6),

            Text(
              'Hello, ${user.name}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'How are you feeling today?',
              style: TextStyle(color: textMuted, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 18),

            // AI Insight card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceDark,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderGreen),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderGreen),
                    ),
                    child: const Icon(Icons.auto_awesome, color: primary),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Insight',
                          style: TextStyle(
                            color: Color(0xFF92C9A4),
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          '“Your sleep quality improved this week. Keep a consistent bedtime routine.”',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daily Check-in',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Flexible(
                  child: Text(
                    _formatDay(DateTime.now()),
                    style: TextStyle(
                      color: textMuted,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            _CheckInCard(
              items: [
                _Metric(
                  icon: Icons.sentiment_satisfied,
                  label: 'Mood Level',
                  value: _moodLevel,
                ),
                _Metric(
                  icon: Icons.nights_stay,
                  label: 'Sleep Quality',
                  value: _sleepQuality,
                ),
                _Metric(
                  icon: Icons.bolt,
                  label: 'Energy Level',
                  value: _energyLevel,
                ),
              ],
              onUpdate: _showCheckInDialog,
            ),

            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Weekly Trends',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Mood score',
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            _TrendsCard(
              values: const [0.40, 0.60, 0.55, 0.85, 0.70, 0.50, 0.45],
              labels: const ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- UI widgets ----------------

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.index, required this.onTap});
  final int index;
  final ValueChanged<int> onTap;

  static const primary = Color(0xFF13EC5B);
  static const backgroundDark = Color(0xFF102216);
  static const borderGreen = Color(0xFF326744);
  static const textMuted = Color(0xFF92C9A4);

  @override
  Widget build(BuildContext context) {
    Widget item({
      required int i,
      required IconData icon,
      required String label,
    }) {
      final selected = i == index;
      return InkWell(
        onTap: () => onTap(i),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: selected ? primary : textMuted),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: selected ? primary : textMuted,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 74,
      decoration: BoxDecoration(
        color: backgroundDark,
        border: const Border(top: BorderSide(color: borderGreen, width: 0.8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          item(i: 0, icon: Icons.grid_view, label: 'Dashboard'),
          item(i: 1, icon: Icons.menu_book, label: 'Diary'),
          item(i: 2, icon: Icons.analytics, label: 'History'),
          item(i: 3, icon: Icons.settings, label: 'Settings'),
        ],
      ),
    );
  }
}

class _CheckInCard extends StatelessWidget {
  const _CheckInCard({required this.items, required this.onUpdate});
  final List<_Metric> items;
  final VoidCallback onUpdate;

  static const surfaceDark = Color(0xFF1A2E22);
  static const borderGreen = Color(0xFF326744);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderGreen),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _MetricRow(metric: items[i]),
            if (i != items.length - 1) const SizedBox(height: 14),
          ],
          const SizedBox(height: 18),
          SizedBox(
            height: 46,
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onUpdate,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: borderGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Update Check-in',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric {
  final IconData icon;
  final String label;
  final double value; // 0..1
  const _Metric({required this.icon, required this.label, required this.value});
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.metric});
  final _Metric metric;

  static const primary = Color(0xFF13EC5B);
  static const borderGreen = Color(0xFF326744);

  @override
  Widget build(BuildContext context) {
    final pct = (metric.value * 100).round();

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderGreen),
              ),
              child: Icon(metric.icon, color: primary, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                metric.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderGreen),
              ),
              child: Text(
                '$pct%',
                style: const TextStyle(
                  color: primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: metric.value,
            minHeight: 8,
            backgroundColor: borderGreen.withOpacity(0.35),
            valueColor: const AlwaysStoppedAnimation(primary),
          ),
        ),
      ],
    );
  }
}

class _TrendsCard extends StatelessWidget {
  const _TrendsCard({required this.values, required this.labels});
  final List<double> values; // 0..1
  final List<String> labels;

  static const primary = Color(0xFF13EC5B);
  static const surfaceDark = Color(0xFF1A2E22);
  static const borderGreen = Color(0xFF326744);
  static const textMuted = Color(0xFF92C9A4);

  @override
  Widget build(BuildContext context) {
    final maxH = 120.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderGreen),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(values.length, (i) {
          final isBest = values[i] == values.reduce((a, b) => a > b ? a : b);
          final h = (values[i].clamp(0.0, 1.0)) * maxH;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: maxH,
                    decoration: BoxDecoration(
                      color: borderGreen.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.bottomCenter,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: h,
                      decoration: BoxDecoration(
                        color: isBest ? primary : primary.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    labels[i],
                    style: TextStyle(
                      color: isBest ? primary : textMuted,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _CheckInSlider extends StatelessWidget {
  const _CheckInSlider({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  static const primary = Color(0xFF13EC5B);
  static const borderGreen = Color(0xFF326744);

  @override
  Widget build(BuildContext context) {
    final pct = (value * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderGreen),
              ),
              child: Icon(icon, color: primary, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderGreen),
              ),
              child: Text(
                '$pct%',
                style: const TextStyle(
                  color: primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: primary,
            inactiveTrackColor: borderGreen.withOpacity(0.4),
            thumbColor: primary,
            overlayColor: primary.withOpacity(0.2),
            trackHeight: 8,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(value: value, min: 0.0, max: 1.0, onChanged: onChanged),
        ),
      ],
    );
  }
}
