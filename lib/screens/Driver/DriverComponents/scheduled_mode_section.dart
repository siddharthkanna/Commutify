import 'package:flutter/material.dart';
import 'package:mlritpool/Themes/app_theme.dart';

class ScheduledModeSection extends StatelessWidget {
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final Function(BuildContext) selectDate;
  final Function(BuildContext) selectTime;

  const ScheduledModeSection({
    Key? key,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectDate,
    required this.selectTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Scheduled Date: ${selectedDate.toString().substring(0, 10)}',
            ),
            ElevatedButton(
              onPressed: () => selectDate(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Apptheme.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
              ),
              child: const Text('Select Date'),
            )
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Scheduled Time: ${selectedTime.format(context)}'),
            ElevatedButton(
              onPressed: () => selectTime(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Apptheme.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
              ),
              child: const Text('Select Time'),
            ),
          ],
        ),
      ],
    );
  }
}
