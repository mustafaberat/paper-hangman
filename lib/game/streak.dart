library;

({int streak, String? lastWinDay}) nextStreak({
  required bool won,
  required String today,
  required String? lastWinDay,
  required int streak,
}) {
  if (!won) {
    return (streak: 0, lastWinDay: lastWinDay);
  }
  if (lastWinDay == today) {
    return (streak: streak <= 0 ? 1 : streak, lastWinDay: today);
  }
  if (lastWinDay != null && _isYesterday(lastWinDay, today)) {
    return (streak: streak + 1, lastWinDay: today);
  }
  return (streak: 1, lastWinDay: today);
}

bool _isYesterday(String earlier, String later) {
  final a = DateTime.tryParse(earlier);
  final b = DateTime.tryParse(later);
  if (a == null || b == null) return false;
  return b.difference(a).inDays == 1;
}
