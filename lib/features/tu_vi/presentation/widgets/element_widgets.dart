import 'package:flutter/material.dart';
import '../../data/models/tu_vi_star.dart';

/// Widget to display element with color coding
class ElementChip extends StatelessWidget {
  final String element;
  final bool isSmall;

  const ElementChip({
    super.key,
    required this.element,
    this.isSmall = false,
  });

  Color _getElementColor(String element) {
    switch (element) {
      case 'Kim':
        return const Color(0xFFFFD700); // Gold
      case 'Mộc':
        return const Color(0xFF4CAF50); // Green
      case 'Thủy':
        return const Color(0xFF2196F3); // Blue
      case 'Hỏa':
        return const Color(0xFFF44336); // Red
      case 'Thổ':
        return const Color(0xFF795548); // Brown
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 8,
        vertical: isSmall ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: _getElementColor(element).withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: _getElementColor(element),
          width: 1,
        ),
      ),
      child: Text(
        element,
        style: TextStyle(
          color: _getElementColor(element).withOpacity(0.9),
          fontSize: isSmall ? 10 : 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Widget to display a star with its information
class StarChipWidget extends StatelessWidget {
  final TuViStar star;
  final bool showDetails;

  const StarChipWidget({
    super.key,
    required this.star,
    this.showDetails = true,
  });

  Color _getElementColor(String element) {
    switch (element) {
      case 'K':
        return const Color(0xFFFFD700); // Gold
      case 'M':
        return const Color(0xFF4CAF50); // Green
      case 'T':
        return const Color(0xFF2196F3); // Blue
      case 'H':
        return const Color(0xFFF44336); // Red
      case 'O':
        return const Color(0xFF795548); // Brown
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getElementColor(star.element);
    final isMainStar = star.category == 1;

    return Container(
      margin: const EdgeInsets.only(right: 6, bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color,
          width: isMainStar ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isMainStar)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                Icons.star,
                size: 14,
                color: color,
              ),
            ),
          Text(
            star.name,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 13,
              fontWeight: isMainStar ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (star.strength != null && showDetails) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                star.strength!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget to display strength badge
class StrengthBadge extends StatelessWidget {
  final String? strength;

  const StrengthBadge({super.key, this.strength});

  Color _getStrengthColor(String? strength) {
    switch (strength) {
      case 'V':
        return Colors.purple;
      case 'M':
        return Colors.blue;
      case 'H':
        return Colors.green;
      case 'Đ':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStrengthName(String? strength) {
    switch (strength) {
      case 'V':
        return 'Vượng';
      case 'M':
        return 'Miếu';
      case 'H':
        return 'Hòa';
      case 'Đ':
        return 'Đắc địa';
      default:
        return 'Bình thường';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (strength == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getStrengthColor(strength),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _getStrengthName(strength),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
