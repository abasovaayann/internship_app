// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../database/app_database.dart';
import '../../models/diary_entry.dart';
import '../../repositories/diary_repository.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  // Unified green theme
  static const primary = Color(0xFF13EC5B);
  static const backgroundDark = Color(0xFF102216);
  static const surfaceDark = Color(0xFF1A2E22);
  static const borderGreen = Color(0xFF326744);
  static const textMuted = Color(0xFF92C9A4);

  final DiaryRepository _repo = DiaryRepository(AppDatabase.instance);

  bool _loading = true;
  List<DiaryEntry> _entries = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = AuthService.currentUser;
    if (user == null) {
      if (!mounted) return;
      setState(() {
        _entries = const [];
        _loading = false;
      });
      return;
    }

    if (mounted) setState(() => _loading = true);

    final data = await _repo.listByUser(user.id);

    if (!mounted) return;
    setState(() {
      _entries = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      backgroundColor: backgroundDark,
      appBar: AppBar(
        backgroundColor: backgroundDark,
        elevation: 0,
        title: const Text(
          'Diary',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primary,
        foregroundColor: backgroundDark,
        onPressed: user == null ? null : _openNewEntrySheet,
        icon: const Icon(Icons.edit_square),
        label: const Text(
          'New Entry',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: primary))
            : _entries.isEmpty
            ? _EmptyDiary(onCreate: user == null ? null : _openNewEntrySheet)
            : RefreshIndicator(
                color: primary,
                onRefresh: _load,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                  itemCount: _entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final e = _entries[i];
                    return InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => _openEntryDialog(e),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: surfaceDark,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: borderGreen),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    e.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Edit',
                                  onPressed: () => _openEditEntrySheet(e),
                                  icon: const Icon(Icons.edit, color: primary),
                                ),
                                IconButton(
                                  tooltip: 'Delete',
                                  onPressed: () => _confirmDelete(e),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDate(e.createdAt),
                              style: const TextStyle(
                                color: textMuted,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              e.content,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  // ---------- Create entry (Bottom Sheet) ----------

  Future<void> _openNewEntrySheet() async {
    final user = AuthService.currentUser;

    // ✅ capture messenger early (safe even after awaits)
    final messenger = ScaffoldMessenger.of(context);

    if (user == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please log in first.')),
      );
      return;
    }

    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();

    final result = await showModalBottomSheet<bool?>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true, // ✅ Prevent context issues
      backgroundColor: surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetCtx) {
        return _NewEntrySheetContent(
          titleCtrl: titleCtrl,
          contentCtrl: contentCtrl,
        );
      },
    );

    // ✅ Handle validation failure (null means empty content)
    if (result == null && mounted) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please write something first.')),
      );
      titleCtrl.dispose();
      contentCtrl.dispose();
      return;
    }

    // ✅ Handle result after sheet is fully closed
    if (result == true && mounted) {
      try {
        await _repo.add(
          userId: user.id,
          title: titleCtrl.text.trim().isEmpty
              ? 'Untitled'
              : titleCtrl.text.trim(),
          content: contentCtrl.text.trim(),
        );

        if (!mounted) return;

        await _load();
        if (!mounted) return;

        messenger.showSnackBar(
          const SnackBar(content: Text('Diary entry saved')),
        );
      } catch (e) {
        if (!mounted) return;
        messenger.showSnackBar(SnackBar(content: Text('Failed to save: $e')));
      }
    }

    titleCtrl.dispose();
    contentCtrl.dispose();
  }

  // ---------- View entry dialog ----------

  Future<void> _openEntryDialog(DiaryEntry e) async {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: surfaceDark,
        title: Text(
          e.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDate(e.createdAt),
                style: const TextStyle(
                  color: textMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                e.content,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text(
              'Close',
              style: TextStyle(color: primary, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Edit entry (Bottom Sheet) ----------

  Future<void> _openEditEntrySheet(DiaryEntry entry) async {
    final messenger = ScaffoldMessenger.of(context);

    final titleCtrl = TextEditingController(text: entry.title);
    final contentCtrl = TextEditingController(text: entry.content);

    final result = await showModalBottomSheet<bool?>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetCtx) {
        return _EditEntrySheetContent(
          titleCtrl: titleCtrl,
          contentCtrl: contentCtrl,
        );
      },
    );

    if (result == null && mounted) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please write something first.')),
      );
      titleCtrl.dispose();
      contentCtrl.dispose();
      return;
    }

    if (result == true && mounted) {
      try {
        await _repo.update(
          id: entry.id,
          title: titleCtrl.text.trim().isEmpty
              ? 'Untitled'
              : titleCtrl.text.trim(),
          content: contentCtrl.text.trim(),
        );

        if (!mounted) return;

        await _load();
        if (!mounted) return;

        messenger.showSnackBar(const SnackBar(content: Text('Entry updated')));
      } catch (e) {
        if (!mounted) return;
        messenger.showSnackBar(SnackBar(content: Text('Failed to update: $e')));
      }
    }

    titleCtrl.dispose();
    contentCtrl.dispose();
  }

  // ---------- Delete ----------

  Future<void> _confirmDelete(DiaryEntry e) async {
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: true, // ✅ Prevent context issues
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: surfaceDark,
        title: const Text(
          'Delete entry?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'This action cannot be undone.',
          style: TextStyle(color: textMuted, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: textMuted, fontWeight: FontWeight.w900),
            ),
          ),
          TextButton(
            // ✅ Just pop with result, no async inside!
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );

    // ✅ Handle result after dialog is fully closed
    if (confirmed == true && mounted) {
      try {
        await _repo.delete(e.id);

        if (!mounted) return;

        await _load();
        if (!mounted) return;

        messenger.showSnackBar(const SnackBar(content: Text('Entry deleted')));
      } catch (ex) {
        if (!mounted) return;
        messenger.showSnackBar(SnackBar(content: Text('Delete failed: $ex')));
      }
    }
  }

  // ---------- Helpers ----------

  String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}  ${two(d.hour)}:${two(d.minute)}';
  }
}

class _EmptyDiary extends StatelessWidget {
  const _EmptyDiary({required this.onCreate});
  final VoidCallback? onCreate;

  static const primary = Color(0xFF13EC5B);
  static const surfaceDark = Color(0xFF1A2E22);
  static const borderGreen = Color(0xFF326744);
  static const textMuted = Color(0xFF92C9A4);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceDark,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderGreen),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.menu_book, color: primary, size: 36),
            const SizedBox(height: 12),
            const Text(
              'No diary entries yet',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Start by writing how you feel today.',
              style: TextStyle(color: textMuted, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 46,
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onCreate,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: borderGreen),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  onCreate == null
                      ? 'Log in to create entry'
                      : 'Create first entry',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ Separate widget for bottom sheet content - avoids context issues
class _NewEntrySheetContent extends StatelessWidget {
  const _NewEntrySheetContent({
    required this.titleCtrl,
    required this.contentCtrl,
  });

  final TextEditingController titleCtrl;
  final TextEditingController contentCtrl;

  static const primary = Color(0xFF13EC5B);
  static const backgroundDark = Color(0xFF102216);
  static const borderGreen = Color(0xFF326744);
  static const textMuted = Color(0xFF92C9A4);

  @override
  Widget build(BuildContext context) {
    // ✅ Fixed padding - keyboard handling done by isScrollControlled: true
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: borderGreen,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'New Diary Entry',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 14),
              _buildField(
                label: 'Title',
                controller: titleCtrl,
                hint: 'e.g., Today was...',
              ),
              const SizedBox(height: 12),
              _buildField(
                label: 'Your thoughts',
                controller: contentCtrl,
                hint: 'Write freely…',
                maxLines: 6,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: borderGreen),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (contentCtrl.text.trim().isEmpty) {
                          // ✅ Pop with null to indicate validation failed
                          Navigator.of(context).pop(null);
                          return;
                        }
                        // ✅ Just pop with result, no async inside!
                        Navigator.of(context).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: backgroundDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
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
            maxLines: maxLines,
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
              hintText: hint,
              hintStyle: const TextStyle(color: textMuted),
            ),
          ),
        ),
      ],
    );
  }
}

class _EditEntrySheetContent extends StatelessWidget {
  const _EditEntrySheetContent({
    required this.titleCtrl,
    required this.contentCtrl,
  });

  final TextEditingController titleCtrl;
  final TextEditingController contentCtrl;

  static const primary = Color(0xFF13EC5B);
  static const backgroundDark = Color(0xFF102216);
  static const borderGreen = Color(0xFF326744);
  static const textMuted = Color(0xFF92C9A4);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: borderGreen,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Edit Diary Entry',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 14),
              _buildField(
                label: 'Title',
                controller: titleCtrl,
                hint: 'e.g., Today was...',
              ),
              const SizedBox(height: 12),
              _buildField(
                label: 'Your thoughts',
                controller: contentCtrl,
                hint: 'Write freely…',
                maxLines: 6,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: borderGreen),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (contentCtrl.text.trim().isEmpty) {
                          Navigator.of(context).pop(null);
                          return;
                        }
                        Navigator.of(context).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: backgroundDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Update',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
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
            maxLines: maxLines,
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
              hintText: hint,
              hintStyle: const TextStyle(color: textMuted),
            ),
          ),
        ),
      ],
    );
  }
}
