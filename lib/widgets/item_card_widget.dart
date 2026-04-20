import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Color getRarityColor(String rarity) {
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

class ItemCardWidget extends StatelessWidget {
  const ItemCardWidget({
    super.key,
    required this.name,
    required this.type,
    required this.description,
    required this.rarity,
    this.attunement = false,
    this.charges,
    this.flavorText,
  });

  final String name;
  final String type;
  final String description;
  final String rarity;
  final bool attunement;
  final int? charges;
  final String? flavorText;

  @override
  Widget build(BuildContext context) {
    final rarityColor = getRarityColor(rarity);
    final hasFlavorText = flavorText != null && flavorText!.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5E6C8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF8A6A3D),
          width: 1.5,
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
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4A3215),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  type,
                  style: GoogleFonts.cinzel(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6B4F2A),
                  ),
                ),
                Text(
                  rarity,
                  style: GoogleFonts.cinzelDecorative(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: rarityColor,
                  ),
                ),
              ],
            ),
            if (attunement) ...[
              const SizedBox(height: 8),
              Text(
                'Requires Attunement',
                style: GoogleFonts.ebGaramond(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF5E3D22),
                ),
              ),
            ],
            if (charges != null) ...[
              const SizedBox(height: 8),
              Text(
                'Charges: $charges',
                style: GoogleFonts.ebGaramond(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4A3215),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Text(
              description,
              style: GoogleFonts.ebGaramond(
                fontSize: 18,
                height: 1.3,
                color: const Color(0xFF3E2C1C),
              ),
            ),
            if (hasFlavorText) ...[
              const SizedBox(height: 14),
              Text(
                '"${flavorText!.trim()}"',
                style: GoogleFonts.ebGaramond(
                  fontSize: 16,
                  height: 1.25,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFF6A5846),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
