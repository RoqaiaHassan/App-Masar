import 'phrases.dart';

const List<String> _arMonths = [
  'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
  'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
];

String monthName(int month) => _arMonths[month - 1];
String shortDate(DateTime d) => '${d.day} ${monthName(d.month)}';
String fullDate(DateTime d) => '${d.day} ${monthName(d.month)} ${d.year}';
String slashDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// عدد الأيام بين تاريخين (بدون تأثر بتغيير التوقيت الصيفي).
int daysBetween(DateTime from, DateTime to) {
  final a = DateTime.utc(from.year, from.month, from.day);
  final b = DateTime.utc(to.year, to.month, to.day);
  return b.difference(a).inDays;
}

String greeting() => DateTime.now().hour < 12 ? 'صباح الخير' : 'مساء الخير';

String remainingLabel(int days) {
  if (days < 0) return 'انتهت المدة';
  if (days == 0) return 'ينتهي اليوم';
  if (days == 1) return 'باقي يوم واحد';
  if (days == 2) return 'باقي يومان';
  if (days <= 10) return 'باقي $days أيام';
  return 'باقي $days يوماً';
}

/// عبارة بطاقة "مستوى التقدم" في تفاصيل الهدف. [seed] مثل: '${goal.id}|${goal.doneSteps}'.
String progressMessage({required double progress, required String seed}) {
  final List<String> pool;
  if (progress >= 1) {
    pool = Phrases.goalDone;
  } else if (progress >= .5) {
    pool = Phrases.goalHigh;
  } else if (progress > 0) {
    pool = Phrases.goalLow;
  } else {
    pool = Phrases.goalStart;
  }
  return Phrases.pick(pool, seed);
}

/// عبارة البطاقة الزرقاء في الشاشة الرئيسية.
String heroMessage({required int total, required int completed, required double progress}) {
  final List<String> pool;
  if (total == 0) {
    pool = Phrases.heroEmpty;
  } else if (progress >= 1) {
    pool = Phrases.heroDone;
  } else if (progress > 0) {
    pool = Phrases.heroProgress;
  } else {
    pool = Phrases.heroStart;
  }
  final now = DateTime.now();
  return Phrases.pick(pool, '${now.year}-${now.month}-${now.day}|$completed/$total');
}
