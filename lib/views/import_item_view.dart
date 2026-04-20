import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo_ui/data/item_model.dart';
import 'package:flutter_demo_ui/services/srd_api_service.dart';
import 'package:flutter_demo_ui/views/create_item_view.dart';

class ImportItemView extends StatefulWidget {
  const ImportItemView({super.key});

  @override
  State<ImportItemView> createState() => _ImportItemViewState();
}

class _ImportItemViewState extends State<ImportItemView> {
  final _service = SrdApiService();
  final _searchController = TextEditingController();
  final List<dynamic> _allItems = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await _service.fetchMagicItems();
      if (!mounted) {
        return;
      }
      setState(() {
        _allItems
          ..clear()
          ..addAll(items);
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Could not load SRD items.\n$e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<dynamic> get _filteredItems {
    if (_query.trim().isEmpty) {
      return _allItems;
    }

    return _allItems.where((item) {
      final name = (item as Map<String, dynamic>)['name'] as String? ?? '';
      return name.toLowerCase().contains(_query.trim().toLowerCase());
    }).toList();
  }

  Future<void> _importItem(Map<String, dynamic> rawItem) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be signed in to import items.')),
      );
      return;
    }

    final index = rawItem['index'] as String?;
    if (index == null || index.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This SRD item has no valid index.')),
      );
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final detail = await _service.fetchItemDetail(index);
      final importedItem = _service.mapDetailToItem(
        detail: detail,
        ownerUid: user.uid,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context);
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateItemView(initialItem: importedItem),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to import item: $e')),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import From SRD'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search SRD items',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (_isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (_errorMessage != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: _loadItems,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (filteredItems.isEmpty) {
                    return const Center(
                      child: Text('No SRD items matched your search.'),
                    );
                  }

                  return ListView.separated(
                    itemCount: filteredItems.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = filteredItems[index] as Map<String, dynamic>;
                      final name = item['name'] as String? ?? 'Unnamed SRD Item';

                      return ListTile(
                        title: Text(name),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => _importItem(item),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
