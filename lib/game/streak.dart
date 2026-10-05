library;

/// Consecutive win streak (not calendar-based).
int nextWinStreak({required bool won, required int streak}) {
  if (!won) return 0;
  return streak + 1;
}
