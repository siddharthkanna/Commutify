import 'package:flutter/material.dart';
import 'package:mlritpool/Themes/app_theme.dart';

class ModeSwitch extends StatelessWidget {
  final bool immediateMode;
  final bool scheduledMode;
  final Function() toggleMode;

  const ModeSwitch({
    Key? key,
    required this.immediateMode,
    required this.scheduledMode,
    required this.toggleMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 120,
          height: 30,
          decoration: BoxDecoration(
            color: scheduledMode ? Apptheme.button : Apptheme.primaryColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: SizedBox(
            child: Center(
              child: Text(
                scheduledMode ? 'SCHEDULED' : 'IMMEDIATE',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.white),
              ),
            ),
          ),
        ),
        Switch(
          value: scheduledMode,
          onChanged: (value) {
            toggleMode();
          },
          activeColor: Apptheme.button,
          inactiveThumbColor: Apptheme.primaryColor,
        ),
      ],
    );
  }
}
