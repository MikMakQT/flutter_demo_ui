import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo_ui/data/item_model.dart';
import 'package:flutter_demo_ui/data/user_directory_helper.dart';
import 'package:flutter_demo_ui/views/edit_item_view.dart';
import 'package:flutter_demo_ui/services/pdf_service.dart';
import 'package:flutter_demo_ui/widgets/item_card_widget.dart';
import 'package:intl/intl.dart';

class ItemDetailView extends StatefulWidget {
  const ItemDetailView({
    super.key,
    required this.item,
  });

  final ItemModel item;

  @override
  State<ItemDetailView> createState() => _ItemDetailViewState();
}

class _ItemDetailViewState extends State<ItemDetailView> {
  final _pdfService = PdfService();
  late ItemModel _item;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  bool get _isOwner => FirebaseAuth.instance.currentUser?.uid == _item.ownerUid;

  String _formattedCreatedAt() {
    return DateFormat('dd.MM.yyyy HH:mm').format(_item.createdAt.toDate());
  }

  Future<void> _editItem() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => EditItemView(
          itemId: _item.id ?? '',
          name: _item.name,
          description: _item.description,
          rarity: _item.rarity,
        ),
      ),
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _item = _item.copyWith(
        name: result['name'] as String? ?? _item.name,
        description: result['description'] as String? ?? _item.description,
        rarity: result['rarity'] as String? ?? _item.rarity,
      );
    });
  }

  Future<void> _deleteItem() async {
    final itemId = _item.id;
    if (itemId == null || itemId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This item cannot be deleted right now.')),
      );
      return;
    }

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
        .doc(itemId)
        .delete();

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
  }

  Future<void> _shareItem() async {
    final itemId = _item.id;
    if (itemId == null || itemId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This item cannot be shared right now.')),
      );
      return;
    }

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
          .doc('${toUserUid}_$itemId')
          .set({
        'itemId': itemId,
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

  Future<void> _printItem() async {
    try {
      await _pdfService.printItem(_item);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to print item: $e')),
      );
    }
  }

  Future<void> _saveAsPdf() async {
    try {
      await _pdfService.saveItemPdf(_item);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ownerActions = _isOwner
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
        : const <Widget>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
        actions: [
          IconButton(
            onPressed: _printItem,
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Print Item',
          ),
          IconButton(
            onPressed: _saveAsPdf,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Save as PDF',
          ),
          ...ownerActions,
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ItemCardWidget(
            name: _item.name,
            type: _item.type,
            description: _item.description,
            rarity: _item.rarity,
            attunement: _item.attunement,
            charges: _item.charges,
            flavorText: _item.flavorText,
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
                  Text('Name: ${_item.name}'),
                  const SizedBox(height: 8),
                  Text('Type: ${_item.type}'),
                  const SizedBox(height: 8),
                  Text('Rarity: ${_item.rarity}'),
                  const SizedBox(height: 8),
                  Text('Description: ${_item.description}'),
                  const SizedBox(height: 8),
                  Text(
                    'Attunement: ${_item.attunement ? 'Required' : 'Not required'}',
                  ),
                  if (_item.charges != null) ...[
                    const SizedBox(height: 8),
                    Text('Charges: ${_item.charges}'),
                  ],
                  if (_item.flavorText != null &&
                      _item.flavorText!.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('Flavor Text: ${_item.flavorText}'),
                  ],
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
