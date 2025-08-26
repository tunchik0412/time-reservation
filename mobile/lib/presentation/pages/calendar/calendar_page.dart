import 'package:flutter/material.dart';
import '../../../core/widgets/calendar_table.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CalendarTable(),
    );
  }
}
