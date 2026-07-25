import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Consolidates the priority icon/color/label switch that used to be
/// duplicated across HomeScreen, TodoListPage, and AddTodoPage.
enum TodoPriority {
  trivial(0, 'Trivial', FontAwesomeIcons.spinner, Colors.blueGrey),
  low(1, 'Low', FontAwesomeIcons.anglesDown, Colors.blue),
  neutral(2, 'Neutral', FontAwesomeIcons.equals, Colors.amber),
  high(3, 'High', FontAwesomeIcons.anglesUp, Colors.orange),
  critical(4, 'Critical', FontAwesomeIcons.triangleExclamation, Colors.red);

  const TodoPriority(this.value, this.label, this.icon, this.color);

  final int value;
  final String label;
  final FaIconData icon;
  final Color color;

  static TodoPriority fromValue(int value) => TodoPriority.values.firstWhere(
        (p) => p.value == value,
        orElse: () => TodoPriority.trivial,
      );
}

class PriorityBadge extends StatelessWidget {
  const PriorityBadge({super.key, required this.priority, this.compact = false});

  final int priority;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final p = TodoPriority.fromValue(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: p.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(p.icon, size: 12, color: p.color),
          if (!compact) ...[
            const SizedBox(width: 6),
            Text(
              p.label,
              style: TextStyle(
                color: p.color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
