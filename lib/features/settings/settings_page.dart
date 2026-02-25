// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_service.dart';
import '../../models/app_user.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Green theme (unified with login/register)
  static const primary = Color(0xFF13EC5B);
  static const backgroundDark = Color(0xFF102216);
  static const surfaceDark = Color(0xFF1A2E22);
  static const borderGreen = Color(0xFF326744);
  static const textMuted = Color(0xFF92C9A4);

  int selectedNav = 0;

  late final TextEditingController nameCtrl;
  late final TextEditingController emailCtrl;
  late final TextEditingController uniCtrl;

  bool dailyReminder = true;
  bool emailAlerts = false;
  bool darkMode = true;

  bool saving = false;

  @override
  void initState() {
    super.initState();
    final u = AuthService.currentUser;
    nameCtrl = TextEditingController(text: u?.name ?? '');
    emailCtrl = TextEditingController(text: u?.email ?? '');
    uniCtrl = TextEditingController(text: u?.university ?? '');
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    uniCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => saving = true);

    final ok = await AuthService.updateProfile(
      name: nameCtrl.text.trim(),
      email: emailCtrl.text.trim(),
      university: uniCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Saved successfully' : 'Save failed (email may be used)',
        ),
      ),
    );
  }

  void _logout() {
    AuthService.logout();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        backgroundColor: backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primary),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 760;

            return Row(
              children: [
                if (isWide)
                  _SideNav(
                    user: user,
                    selectedNav: selectedNav,
                    onNavSelected: (i) => setState(() => selectedNav = i),
                  ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      isWide ? 24 : 16,
                      16,
                      isWide ? 24 : 16,
                      24,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (!isWide)
                              _MobileSectionTabs(
                                selected: selectedNav,
                                onSelected: (i) =>
                                    setState(() => selectedNav = i),
                                primary: primary,
                                surface: surfaceDark,
                                border: borderGreen,
                                muted: textMuted,
                              ),

                            const SizedBox(height: 18),

                            if (selectedNav == 0) ...[
                              const _SectionTitle('Edit Profile'),
                              const SizedBox(height: 12),
                              _Input(label: 'Full Name', controller: nameCtrl),
                              const SizedBox(height: 12),
                              _Input(
                                label: 'Email Address',
                                controller: emailCtrl,
                              ),
                              const SizedBox(height: 12),
                              _Input(label: 'University', controller: uniCtrl),
                            ],

                            if (selectedNav == 1) ...[
                              const _SectionTitle('Notifications'),
                              const SizedBox(height: 12),
                              _Card(
                                child: Column(
                                  children: [
                                    _ToggleRow(
                                      title: 'Daily Check-in Reminder',
                                      subtitle:
                                          'Get a reminder to log your mood every morning',
                                      value: dailyReminder,
                                      onChanged: (v) =>
                                          setState(() => dailyReminder = v),
                                      primary: primary,
                                      muted: textMuted,
                                      divider: true,
                                    ),
                                    _ToggleRow(
                                      title: 'Email Alerts',
                                      subtitle:
                                          'Weekly summary and app updates',
                                      value: emailAlerts,
                                      onChanged: (v) =>
                                          setState(() => emailAlerts = v),
                                      primary: primary,
                                      muted: textMuted,
                                      divider: false,
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            if (selectedNav == 2) ...[
                              const _SectionTitle('Account Security'),
                              const SizedBox(height: 12),
                              _Card(
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.lock,
                                    color: primary,
                                  ),
                                  title: const Text(
                                    'Change Password',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  trailing: const Icon(
                                    Icons.chevron_right,
                                    color: textMuted,
                                  ),
                                  onTap: _showChangePasswordDialog,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const _Hint(
                                'Password change works using your local DB user table.',
                                muted: textMuted,
                              ),
                            ],

                            if (selectedNav == 3) ...[
                              const _SectionTitle('Preferences'),
                              const SizedBox(height: 12),
                              _Card(
                                child: _ToggleRow(
                                  title: 'Dark Mode',
                                  subtitle: 'Use dark theme (recommended)',
                                  value: darkMode,
                                  onChanged: (v) =>
                                      setState(() => darkMode = v),
                                  primary: primary,
                                  muted: textMuted,
                                  divider: false,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _Card(
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.info_outline,
                                    color: primary,
                                  ),
                                  title: const Text(
                                    'About',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  subtitle: const Text(
                                    'Version, build info, and credits',
                                    style: TextStyle(
                                      color: textMuted,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  onTap: _showAboutDialog,
                                ),
                              ),
                            ],

                            const SizedBox(height: 22),

                            SizedBox(
                              height: 54,
                              child: ElevatedButton(
                                onPressed: saving ? null : _save,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primary,
                                  foregroundColor: backgroundDark,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: saving
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Save All Changes',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            TextButton(
                              onPressed: _logout,
                              child: const Text(
                                'Log Out',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _showChangePasswordDialog() async {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    // ✅ capture messenger once (safe)
    final messenger = ScaffoldMessenger.of(context);

    final result = await showDialog<bool>(
      context: context,
      useRootNavigator: true, // ✅ Prevent context issues
      builder: (dialogCtx) {
        bool obscure1 = true;
        bool obscure2 = true;
        bool obscure3 = true;

        return StatefulBuilder(
          builder: (dialogCtx, setLocal) {
            return AlertDialog(
              backgroundColor: surfaceDark,
              title: const Text(
                'Change Password',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _pwField(
                      label: 'Current password',
                      controller: currentCtrl,
                      obscure: obscure1,
                      onToggle: () => setLocal(() => obscure1 = !obscure1),
                    ),
                    const SizedBox(height: 10),
                    _pwField(
                      label: 'New password',
                      controller: newCtrl,
                      obscure: obscure2,
                      onToggle: () => setLocal(() => obscure2 = !obscure2),
                    ),
                    const SizedBox(height: 10),
                    _pwField(
                      label: 'Confirm new password',
                      controller: confirmCtrl,
                      obscure: obscure3,
                      onToggle: () => setLocal(() => obscure3 = !obscure3),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: textMuted,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                TextButton(
                  // ✅ Just pop with result, no async inside!
                  onPressed: () => Navigator.of(dialogCtx).pop(true),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    // ✅ Handle result after dialog is fully closed
    if (result == true && mounted) {
      final err = await AuthService.changePassword(
        currentPassword: currentCtrl.text,
        newPassword: newCtrl.text,
        confirmNewPassword: confirmCtrl.text,
      );

      if (!mounted) return;

      if (err == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Password changed successfully')),
        );
      } else {
        messenger.showSnackBar(SnackBar(content: Text(err)));
      }
    }

    currentCtrl.dispose();
    newCtrl.dispose();
    confirmCtrl.dispose();
  }

  Widget _pwField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: backgroundDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderGreen),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              suffixIcon: IconButton(
                onPressed: onToggle,
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: textMuted,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showAboutDialog() async {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: surfaceDark,
        title: const Text(
          'About',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'Internship App\nSQLite Auth + UI Prototype\nVersion: 0.1.0',
          style: TextStyle(color: textMuted, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text(
              'OK',
              style: TextStyle(color: primary, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- Sidebar --------------------

class _SideNav extends StatelessWidget {
  const _SideNav({
    required this.user,
    required this.selectedNav,
    required this.onNavSelected,
  });
  final AppUser? user;
  final int selectedNav;
  final ValueChanged<int> onNavSelected;

  static const primary = Color(0xFF13EC5B);
  static const backgroundDark = Color(0xFF102216);
  static const surfaceDark = Color(0xFF1A2E22);
  static const borderGreen = Color(0xFF326744);
  static const textMuted = Color(0xFF92C9A4);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: backgroundDark,
        border: Border(right: BorderSide(color: borderGreen, width: 0.7)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: surfaceDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderGreen),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: primary,
                  child: Icon(Icons.person, color: backgroundDark),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? '—',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Student Account',
                        style: TextStyle(
                          color: textMuted,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _NavItem(
            icon: Icons.person,
            label: 'Profile',
            selected: selectedNav == 0,
            onTap: () => onNavSelected(0),
          ),
          _NavItem(
            icon: Icons.notifications,
            label: 'Notifications',
            selected: selectedNav == 1,
            onTap: () => onNavSelected(1),
          ),
          _NavItem(
            icon: Icons.security,
            label: 'Security',
            selected: selectedNav == 2,
            onTap: () => onNavSelected(2),
          ),
          _NavItem(
            icon: Icons.settings,
            label: 'Preferences',
            selected: selectedNav == 3,
            onTap: () => onNavSelected(3),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const primary = Color(0xFF13EC5B);
  static const surfaceDark = Color(0xFF1A2E22);
  static const borderGreen = Color(0xFF326744);
  static const textMuted = Color(0xFF92C9A4);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 48,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? primary.withOpacity(0.15) : surfaceDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? primary : borderGreen),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? primary : textMuted),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : textMuted,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------- Mobile tabs --------------------

class _MobileSectionTabs extends StatelessWidget {
  const _MobileSectionTabs({
    required this.selected,
    required this.onSelected,
    required this.primary,
    required this.surface,
    required this.border,
    required this.muted,
  });

  final int selected;
  final ValueChanged<int> onSelected;
  final Color primary, surface, border, muted;

  @override
  Widget build(BuildContext context) {
    final labels = ['Profile', 'Notifications', 'Security', 'Preferences'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(labels.length, (i) {
        final isSel = i == selected;
        return InkWell(
          onTap: () => onSelected(i),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSel ? primary.withOpacity(0.15) : surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: isSel ? primary : border),
            ),
            child: Text(
              labels[i],
              style: TextStyle(
                color: isSel ? Colors.white : muted,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// -------------------- Reusable UI --------------------

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  static const surfaceDark = Color(0xFF1A2E22);
  static const borderGreen = Color(0xFF326744);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGreen),
      ),
      child: child,
    );
  }
}

class _Input extends StatelessWidget {
  const _Input({required this.label, required this.controller});
  final String label;
  final TextEditingController controller;

  static const surfaceDark = Color(0xFF1A2E22);
  static const borderGreen = Color(0xFF326744);
  static const textMuted = Color(0xFF92C9A4);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderGreen),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              hintStyle: TextStyle(color: textMuted),
            ),
          ),
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.primary,
    required this.muted,
    required this.divider,
  });

  final String title, subtitle;
  final bool value, divider;
  final ValueChanged<bool> onChanged;
  final Color primary, muted;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: muted,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          trailing: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: primary,
          ),
        ),
        if (divider) const Divider(height: 1, color: Color(0xFF326744)),
      ],
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint(this.text, {required this.muted});
  final String text;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: muted, fontWeight: FontWeight.w600, height: 1.35),
    );
  }
}
