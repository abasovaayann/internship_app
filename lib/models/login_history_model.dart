class LoginHistoryModel {
  final int id;
  final int userId;
  final DateTime loginTime;
  final String? deviceInfo;
  final String? ipAddress;

  const LoginHistoryModel({
    required this.id,
    required this.userId,
    required this.loginTime,
    this.deviceInfo,
    this.ipAddress,
  });

  /// Format the login time for display (e.g., "Feb 25, 2026 at 3:45 PM")
  String get formattedTime {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = loginTime.hour > 12 ? loginTime.hour - 12 : loginTime.hour;
    final period = loginTime.hour >= 12 ? 'PM' : 'AM';
    final minute = loginTime.minute.toString().padLeft(2, '0');
    return '${months[loginTime.month - 1]} ${loginTime.day}, ${loginTime.year} at $hour:$minute $period';
  }

  /// Returns how long ago the login was (e.g., "2 hours ago", "Yesterday")
  String get relativeTime {
    final now = DateTime.now();
    final diff = now.difference(loginTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    return formattedTime;
  }
}
