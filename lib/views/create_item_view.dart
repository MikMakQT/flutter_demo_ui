import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo_ui/data/item_model.dart';
import 'package:flutter_demo_ui/widgets/item_card_widget.dart';

class CreateItemView extends StatefulWidget {
  const CreateItemView({
    super.key,
    this.initialItem,
  });

  final ItemModel? initialItem;

  @override
  State<CreateItemView> createState() => _CreateItemViewState();
}

class _CreateItemViewState extends State<CreateItemView> {
  static const _allowedTypes = [
    'Weapon',
    'Armor',
    'Wondrous Item',
    'Potion',
    'Ring',
  ];

  static const _allowedRarities = [
    'Common',
    'Uncommon',
    'Rare',
    'Epic',
    'Legendary',
  ];

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _chargesController = TextEditingController();
  final _flavorTextController = TextEditingController();
  String _name = '';
  String _type = 'Weapon';
  String _rarity = 'Common';
  String _description = '';
  bool _attunement = false;
  int? _charges;
  String? _flavorText;
  bool _isSaving = false;

  CollectionReference<Map<String, dynamic>> _itemsRef() {
    return FirebaseFirestore.instance.collection('items');
  }

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;
    if (item == null) {
      return;
    }

    _name = item.name;
    _type = _allowedTypes.contains(item.type) ? item.type : 'Wondrous Item';
    _rarity = _allowedRarities.contains(item.rarity) ? item.rarity : 'Common';
    _description = item.description;
    _attunement = item.attunement;
    _charges = item.charges;
    _flavorText = item.flavorText;
    _nameController.text = item.name;
    _descriptionController.text = item.description;
    _chargesController.text = item.charges?.toString() ?? '';
    _flavorTextController.text = item.flavorText ?? '';
  }

  void _handleChargesChanged(String value) {
    setState(() {
      _charges = int.tryParse(value.trim());
    });
  }

  ItemModel _previewItem(String ownerUid) {
    return ItemModel(
      name: _name.trim().isEmpty ? 'Unnamed Relic' : _name.trim(),
      type: _type,
      rarity: _rarity,
      description: _description.trim().isEmpty
          ? 'A mysterious artifact waiting for its story.'
          : _description.trim(),
      attunement: _attunement,
      charges: _charges,
      flavorText: _flavorText?.trim().isEmpty ?? true ? null : _flavorText?.trim(),
      ownerUid: ownerUid,
      createdAt: Timestamp.now(),
    );
  }

  Future<void> _saveItem() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be signed in to create an item.')),
      );
      return;
    }

    if (_name.trim().isEmpty || _description.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name and description are required before saving.'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final item = _previewItem(user.uid);
      await _itemsRef().add(item.toMap());

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item saved')),
      );
      Navigator.pop(context);
    } on FirebaseException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message == null
                ? 'Firebase error: ${e.code}'
                : 'Firebase error (${e.code}): ${e.message}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save item: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _chargesController.dispose();
    _flavorTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final previewItem =
        _previewItem(FirebaseAuth.instance.currentUser?.uid ?? 'preview-user');

    return Scaffold(
      backgroundColor: const Color(0xFF1E1B18),
      appBar: AppBar(title: const Text('Create DnD Item')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Item Details',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF5E6C8),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _name = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _type,
                dropdownColor: const Color(0xFF2B2723),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Weapon', child: Text('Weapon')),
                  DropdownMenuItem(value: 'Armor', child: Text('Armor')),
                  DropdownMenuItem(
                    value: 'Wondrous Item',
                    child: Text('Wondrous Item'),
                  ),
                  DropdownMenuItem(value: 'Potion', child: Text('Potion')),
                  DropdownMenuItem(value: 'Ring', child: Text('Ring')),
                ],
                onChanged: (value) {
                  setState(() {
                    _type = value ?? 'Weapon';
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _rarity,
                dropdownColor: const Color(0xFF2B2723),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Rarity',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Common', child: Text('Common')),
                  DropdownMenuItem(value: 'Uncommon', child: Text('Uncommon')),
                  DropdownMenuItem(value: 'Rare', child: Text('Rare')),
                  DropdownMenuItem(value: 'Epic', child: Text('Epic')),
                  DropdownMenuItem(value: 'Legendary', child: Text('Legendary')),
                ],
                onChanged: (value) {
                  setState(() {
                    _rarity = value ?? 'Common';
                  });
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                value: _attunement,
                contentPadding: EdgeInsets.zero,
                activeColor: Colors.orange.shade700,
                title: const Text(
                  'Requires Attunement',
                  style: TextStyle(color: Color(0xFFF5E6C8)),
                ),
                onChanged: (value) {
                  setState(() {
                    _attunement = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _chargesController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Charges (optional)',
                  border: OutlineInputBorder(),
                ),
                onChanged: _handleChargesChanged,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                style: const TextStyle(color: Colors.white),
                minLines: 4,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _description = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _flavorTextController,
                style: const TextStyle(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Flavor Text (optional)',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _flavorText = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isSaving ? null : _saveItem,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_upload_outlined),
                label: Text(_isSaving ? 'Saving...' : 'Save Item'),
              ),
              const SizedBox(height: 28),
              const Text(
                'Preview',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF5E6C8),
                ),
              ),
              const SizedBox(height: 16),
              ItemCardWidget(
                name: previewItem.name,
                type: previewItem.type,
                description: previewItem.description,
                rarity: previewItem.rarity,
                attunement: previewItem.attunement,
                charges: previewItem.charges,
                flavorText: previewItem.flavorText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
