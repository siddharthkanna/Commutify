import 'package:flutter/material.dart';
import 'package:commutify/Themes/app_theme.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: Apptheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                immediateMode ? Icons.bolt : Icons.calendar_month,
                color: immediateMode ? Apptheme.noir : Apptheme.primary,
                size: 22,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    immediateMode ? 'Immediate' : 'Scheduled',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: immediateMode ? Apptheme.noir : Apptheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    immediateMode ? 'Ride available now' : 'Set future date & time',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch.adaptive(
              value: scheduledMode,
              onChanged: (_) => toggleMode(),
              activeColor: Apptheme.primary,
              activeTrackColor: Apptheme.primary.withOpacity(0.3),
              inactiveThumbColor: Apptheme.noir,
              inactiveTrackColor: Apptheme.noir.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}
