import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_demo_ui/data/item_model.dart';
import 'package:http/http.dart' as http;

class SrdApiService {
  static const _baseUrl = 'https://www.dnd5eapi.co/api/magic-items';

  Future<List<dynamic>> fetchMagicItems() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to load SRD items (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['results'] as List<dynamic>? ?? [];
  }

  Future<Map<String, dynamic>> fetchItemDetail(String index) async {
    final response = await http.get(Uri.parse('$_baseUrl/$index'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load SRD item details (${response.statusCode})');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  ItemModel mapDetailToItem({
    required Map<String, dynamic> detail,
    required String ownerUid,
  }) {
    final description = _joinDescription(detail['desc']);
    final flavorText = _joinDescription(detail['entries']);
    final rarity = _extractName(detail['rarity'], fallback: 'Common');
    final type = _extractType(detail);
    final attunement = _extractAttunement(detail);
    final charges = _extractCharges(detail);

    return ItemModel(
      name: detail['name'] as String? ?? 'Imported Item',
      type: _normalizeType(type),
      rarity: _normalizeRarity(rarity),
      description:
          description.isEmpty ? 'No SRD description available.' : description,
      attunement: attunement,
      charges: charges,
      flavorText: flavorText.isEmpty ? null : flavorText,
      ownerUid: ownerUid,
      createdAt: Timestamp.now(),
    );
  }

  String _normalizeType(String type) {
    const allowedTypes = {
      'Weapon',
      'Armor',
      'Wondrous Item',
      'Potion',
      'Ring',
    };

    if (allowedTypes.contains(type)) {
      return type;
    }

    final lower = type.toLowerCase();
    if (lower.contains('weapon')) {
      return 'Weapon';
    }
    if (lower.contains('armor')) {
      return 'Armor';
    }
    if (lower.contains('potion')) {
      return 'Potion';
    }
    if (lower.contains('ring')) {
      return 'Ring';
    }
    return 'Wondrous Item';
  }

  String _normalizeRarity(String rarity) {
    const allowedRarities = {
      'Common',
      'Uncommon',
      'Rare',
      'Epic',
      'Legendary',
    };

    if (allowedRarities.contains(rarity)) {
      return rarity;
    }

    final lower = rarity.toLowerCase();
    if (lower.contains('legendary')) {
      return 'Legendary';
    }
    if (lower.contains('very rare') || lower.contains('epic')) {
      return 'Epic';
    }
    if (lower.contains('rare')) {
      return 'Rare';
    }
    if (lower.contains('uncommon')) {
      return 'Uncommon';
    }
    return 'Common';
  }

  String _extractType(Map<String, dynamic> detail) {
    final typeName = _extractName(detail['type'], fallback: '');
    if (typeName.isNotEmpty) {
      return typeName;
    }

    final equipmentCategory = _extractName(
      detail['equipment_category'],
      fallback: '',
    );
    if (equipmentCategory.isNotEmpty) {
      return equipmentCategory;
    }

    final variant = detail['variant'] as bool?;
    if (variant == true) {
      return 'Wondrous Item';
    }

    return 'Wondrous Item';
  }

  String _extractName(dynamic value, {required String fallback}) {
    if (value is Map<String, dynamic>) {
      return value['name'] as String? ?? fallback;
    }
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    return fallback;
  }

  bool _extractAttunement(Map<String, dynamic> detail) {
    final raw = detail['requires_attunement'];
    if (raw is bool) {
      return raw;
    }
    if (raw is String) {
      return raw.trim().isNotEmpty;
    }
    return false;
  }

  int? _extractCharges(Map<String, dynamic> detail) {
    final raw = detail['charges'];
    if (raw is int) {
      return raw;
    }
    if (raw is String) {
      return int.tryParse(raw);
    }
    return null;
  }

  String _joinDescription(dynamic raw) {
    if (raw is List) {
      return raw.whereType<String>().join('\n\n').trim();
    }
    if (raw is String) {
      return raw.trim();
    }
    return '';
  }
}
