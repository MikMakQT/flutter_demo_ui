import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo_ui/data/item_model.dart';
import 'package:flutter_demo_ui/data/user_directory_helper.dart';
import 'package:flutter_demo_ui/views/import_item_view.dart';
import 'package:flutter_demo_ui/views/item_detail_view.dart';
import 'package:flutter_demo_ui/widgets/item_card_widget.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    UserDirectoryHelper.ensureCurrentUserProfile();
  }

  CollectionReference<Map<String, dynamic>> _itemsRef() {
    return FirebaseFirestore.instance.collection('items');
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DnD Item Maker'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/shared_items');
            },
            icon: const Icon(Icons.group_outlined),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/create_item');
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Item'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ImportItemView(),
                    ),
                  );
                },
                icon: const Icon(Icons.download_outlined),
                label: const Text('Import from SRD'),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _itemsRef()
                  .where('ownerUid', isEqualTo: user?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Something went wrong while loading your items.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = [...(snapshot.data?.docs ?? [])]
            ..sort((a, b) {
              final aTimestamp = a.data()['createdAt'] as Timestamp?;
              final bTimestamp = b.data()['createdAt'] as Timestamp?;
              final aMillis = aTimestamp?.millisecondsSinceEpoch ?? 0;
              final bMillis = bTimestamp?.millisecondsSinceEpoch ?? 0;
              return bMillis.compareTo(aMillis);
            });

          if (docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, size: 56),
                    const SizedBox(height: 16),
                    const Text(
                      'No items yet',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Signed in as ${user?.email ?? 'unknown user'}. Create your first DnD item and it will be stored in Firestore.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ImportItemView(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.download_outlined),
                      label: const Text('Import from SRD'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: docs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = ItemModel.fromDocument(docs[index]);

              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemDetailView(item: item),
                    ),
                  );
                },
                child: ItemCardWidget(
                  name: item.name,
                  type: item.type,
                  description: item.description,
                  rarity: item.rarity,
                  attunement: item.attunement,
                  charges: item.charges,
                  flavorText: item.flavorText,
                ),
              );
            },
          );
              },
            ),
          ),
        ],
      ),
    );
  }
}
