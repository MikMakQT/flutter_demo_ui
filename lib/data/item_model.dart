import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  const ItemModel({
    this.id,
    required this.name,
    required this.type,
    required this.rarity,
    required this.description,
    required this.attunement,
    required this.ownerUid,
    required this.createdAt,
    this.charges,
    this.flavorText,
  });

  final String? id;
  final String name;
  final String type;
  final String rarity;
  final String description;
  final bool attunement;
  final int? charges;
  final String? flavorText;
  final String ownerUid;
  final Timestamp createdAt;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'rarity': rarity,
      'description': description,
      'attunement': attunement,
      'charges': charges,
      'flavorText': flavorText,
      'ownerUid': ownerUid,
      'createdAt': createdAt,
    };
  }

  ItemModel copyWith({
    String? id,
    String? name,
    String? type,
    String? rarity,
    String? description,
    bool? attunement,
    int? charges,
    String? flavorText,
    String? ownerUid,
    Timestamp? createdAt,
  }) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      rarity: rarity ?? this.rarity,
      description: description ?? this.description,
      attunement: attunement ?? this.attunement,
      charges: charges ?? this.charges,
      flavorText: flavorText ?? this.flavorText,
      ownerUid: ownerUid ?? this.ownerUid,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ItemModel.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return ItemModel(
      id: doc.id,
      name: data['name'] as String? ?? 'Unnamed Item',
      type: data['type'] as String? ?? 'Wondrous Item',
      rarity: data['rarity'] as String? ?? 'Common',
      description: data['description'] as String? ?? '',
      attunement: data['attunement'] as bool? ?? false,
      charges: data['charges'] as int?,
      flavorText: data['flavorText'] as String?,
      ownerUid: data['ownerUid'] as String? ?? '',
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }
}
