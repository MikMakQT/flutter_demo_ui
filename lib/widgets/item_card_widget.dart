import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ItemCardWidget extends StatelessWidget {
  const ItemCardWidget({
    super.key,
    required this.name,
    required this.description,
    required this.rarity,
  });

  final String name;
  final String description;
  final String rarity;

  Color _rarityColor() {
    switch (rarity.toLowerCase()) {
      case 'common':
        return Colors.grey.shade700;
      case 'uncommon':
        return Colors.green.shade700;
      case 'rare':
        return Colors.blue.shade700;
      case 'epic':
      case 'very rare':
        return Colors.purple.shade700;
      case 'legendary':
        return Colors.orange.shade800;
      default:
        return Colors.brown.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rarityColor = _rarityColor();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF8A6A3D),
          width: 1.5,
        ),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF5E6C8),
            Color(0xFFE8D2A6),
          ],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: GoogleFonts.cinzel(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4A3215),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              rarity,
              style: GoogleFonts.cinzelDecorative(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: rarityColor,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              description,
              style: GoogleFonts.ebGaramond(
                fontSize: 18,
                height: 1.25,
                color: const Color(0xFF3E2C1C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
