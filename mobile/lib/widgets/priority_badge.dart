import 'package:flutter/material.dart';

/// Consolidates the priority color/label switch that used to be
/// duplicated across HomeScreen, TodoListPage, and AddTodoPage.
enum TodoPriority {
  trivial(0, 'Trivial', Color(0xFF94A3B8)),
  low(1, 'Low', Color(0xFF60A5FA)),
  neutral(2, 'Neutral', Color(0xFFFBBF24)),
  high(3, 'High', Color(0xFFFB923C)),
  critical(4, 'Critical', Color(0xFFEF4444));

  const TodoPriority(this.value, this.label, this.color);

  final int value;
  final String label;
  final Color color;

  static TodoPriority fromValue(int value) => TodoPriority.values.firstWhere(
        (p) => p.value == value,
        orElse: () => TodoPriority.trivial,
      );
}

/// A plain colored dot — matches the design reference's priority indicator
/// (`h-1.5 w-1.5 rounded-full`) exactly, rather than an icon-in-a-pill.
class PriorityBadge extends StatelessWidget {
  const PriorityBadge({super.key, required this.priority, this.compact = false});

  final int priority;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final p = TodoPriority.fromValue(priority);
    final dot = Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: p.color, shape: BoxShape.circle),
    );

    if (compact) return dot;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        dot,
        const SizedBox(width: 6),
        Text(
          p.label,
          style: TextStyle(color: p.color, fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ],
    );
  }
}
