import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo_ui/data/user_directory_helper.dart';
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
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _itemsRef().where('ownerUid', isEqualTo: user?.uid).snapshots(),
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
              final data = docs[index].data();
              final itemId = docs[index].id;
              final name = data['name'] as String? ?? 'Untitled item';
              final description =
                  data['description'] as String? ?? 'No description';
              final rarity = data['rarity'] as String? ?? 'Unknown rarity';
              final ownerUid = data['ownerUid'] as String? ?? '';
              final createdAt = data['createdAt'] as Timestamp?;

              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItemDetailView(
                        itemId: itemId,
                        name: name,
                        description: description,
                        rarity: rarity,
                        ownerUid: ownerUid,
                        createdAt: createdAt,
                      ),
                    ),
                  );
                },
                child: ItemCardWidget(
                  name: name,
                  description: description,
                  rarity: rarity,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
