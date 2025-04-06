import 'package:flutter/material.dart';
import 'package:commutify/Themes/app_theme.dart';

class SeatingCapacitySelection extends StatelessWidget {
  final int selectedCapacity;
  final Function(int) updateSelectedCapacity;

  const SeatingCapacitySelection({
    Key? key,
    required this.selectedCapacity,
    required this.updateSelectedCapacity,
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.people_alt_outlined,
                size: 18,
                color: Colors.black54,
              ),
              const SizedBox(width: 8),
              const Text(
                'Passenger capacity',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              const Spacer(),
              Text(
                '$selectedCapacity ${selectedCapacity == 1 ? 'seat' : 'seats'}',
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Apptheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCapacitySelector(),
        ],
      ),
    );
  }

  Widget _buildCapacitySelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(5, (index) {
        final capacity = index + 1;
        final isSelected = capacity == selectedCapacity;
        
        return GestureDetector(
          onTap: () => updateSelectedCapacity(capacity),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isSelected 
                  ? Apptheme.primary
                  : Apptheme.mist,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                    ? Apptheme.primary
                    : Colors.grey.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: Apptheme.primary.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  capacity.toString(),
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  'seat${capacity > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: isSelected ? Colors.white.withOpacity(0.8) : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
