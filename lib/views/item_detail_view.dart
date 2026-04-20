import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo_ui/data/user_directory_helper.dart';
import 'package:flutter_demo_ui/views/edit_item_view.dart';
import 'package:flutter_demo_ui/widgets/item_card_widget.dart';
import 'package:intl/intl.dart';

class ItemDetailView extends StatefulWidget {
  const ItemDetailView({
    super.key,
    required this.itemId,
    required this.name,
    required this.description,
    required this.rarity,
    required this.ownerUid,
    required this.createdAt,
  });

  final String itemId;
  final String name;
  final String description;
  final String rarity;
  final String ownerUid;
  final Timestamp? createdAt;

  @override
  State<ItemDetailView> createState() => _ItemDetailViewState();
}

class _ItemDetailViewState extends State<ItemDetailView> {
  late String _name;
  late String _description;
  late String _rarity;
  late String _ownerUid;
  late Timestamp? _createdAt;

  @override
  void initState() {
    super.initState();
    _name = widget.name;
    _description = widget.description;
    _rarity = widget.rarity;
    _ownerUid = widget.ownerUid;
    _createdAt = widget.createdAt;
  }

  bool get _isOwner => FirebaseAuth.instance.currentUser?.uid == _ownerUid;

  String _formattedCreatedAt() {
    if (_createdAt == null) {
      return 'Not available yet';
    }

    return DateFormat('dd.MM.yyyy HH:mm').format(_createdAt!.toDate());
  }

  Future<void> _editItem() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => EditItemView(
          itemId: widget.itemId,
          name: _name,
          description: _description,
          rarity: _rarity,
        ),
      ),
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _name = result['name'] as String? ?? _name;
      _description = result['description'] as String? ?? _description;
      _rarity = result['rarity'] as String? ?? _rarity;
    });
  }

  Future<void> _deleteItem() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) {
      return;
    }

    await FirebaseFirestore.instance
        .collection('items')
        .doc(widget.itemId)
        .delete();

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
  }

  Future<void> _shareItem() async {
    final controller = TextEditingController();

    try {
      final lookupValue = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Share Item'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Enter user UID or email',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Share'),
            ),
          ],
        ),
      );

      if (lookupValue == null || lookupValue.trim().isEmpty) {
        return;
      }

      final toUserUid = await UserDirectoryHelper.resolveUserUid(lookupValue);
      final authUid = FirebaseAuth.instance.currentUser?.uid;

      if (toUserUid == null) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found for that UID or email.')),
        );
        return;
      }

      if (authUid == null) {
        return;
      }

      if (toUserUid == authUid) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You already own this item.')),
        );
        return;
      }

      await FirebaseFirestore.instance
          .collection('shared_items')
          .doc('${toUserUid}_${widget.itemId}')
          .set({
        'itemId': widget.itemId,
        'fromUserUid': authUid,
        'toUserUid': toUserUid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item shared successfully.')),
      );
    } finally {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
        actions: _isOwner
            ? [
                IconButton(
                  onPressed: _editItem,
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: _shareItem,
                  icon: const Icon(Icons.share_outlined),
                  tooltip: 'Share',
                ),
                IconButton(
                  onPressed: _deleteItem,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                ),
              ]
            : null,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ItemCardWidget(
            name: _name,
            description: _description,
            rarity: _rarity,
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Item Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Name: $_name'),
                  const SizedBox(height: 8),
                  Text('Rarity: $_rarity'),
                  const SizedBox(height: 8),
                  Text('Description: $_description'),
                  const SizedBox(height: 8),
                  Text('Created: ${_formattedCreatedAt()}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
