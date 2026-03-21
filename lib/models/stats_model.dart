class MonthlyStat {
  final String month;
  final int year;
  final double total;

  const MonthlyStat({
    required this.month,
    required this.year,
    required this.total,
  });

  factory MonthlyStat.fromJson(Map<String, dynamic> j) => MonthlyStat(
        month: j['month'],
        year:  j['year'],
        total: (j['total'] as num).toDouble(),
      );
}

class CategoryStat {
  final String category;
  final double total;
  final double percentage;

  const CategoryStat({
    required this.category,
    required this.total,
    required this.percentage,
  });

  factory CategoryStat.fromJson(Map<String, dynamic> j) => CategoryStat(
        category:   j['category'],
        total:      (j['total'] as num).toDouble(),
        percentage: (j['percentage'] as num).toDouble(),
      );
}

class TopExpense {
  final String title;
  final double amount;
  final String source; // "note" | "project"

  const TopExpense({
    required this.title,
    required this.amount,
    required this.source,
  });

  factory TopExpense.fromJson(Map<String, dynamic> j) => TopExpense(
        title:  j['title'],
        amount: (j['amount'] as num).toDouble(),
        source: j['source'] ?? 'project',
      );
}

class StatsSummary {
  final double totalInvested;
  final double totalNotesValue;
  final double grandTotal;
  final List<MonthlyStat> monthly;
  final List<CategoryStat> byCategory;
  final List<TopExpense> topExpenses;

  const StatsSummary({
    required this.totalInvested,
    required this.totalNotesValue,
    required this.grandTotal,
    required this.monthly,
    required this.byCategory,
    required this.topExpenses,
  });

  factory StatsSummary.fromJson(Map<String, dynamic> j) => StatsSummary(
        totalInvested:   (j['total_invested'] as num).toDouble(),
        totalNotesValue: (j['total_notes_value'] as num).toDouble(),
        grandTotal:      (j['grand_total'] as num).toDouble(),
        monthly:     (j['monthly'] as List).map((e) => MonthlyStat.fromJson(e)).toList(),
        byCategory:  (j['by_category'] as List).map((e) => CategoryStat.fromJson(e)).toList(),
        topExpenses: (j['top_expenses'] as List).map((e) => TopExpense.fromJson(e)).toList(),
      );
}