import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo_ui/views/item_detail_view.dart';
import 'package:flutter_demo_ui/widgets/item_card_widget.dart';

class SharedItemsView extends StatelessWidget {
  const SharedItemsView({super.key});

  Stream<QuerySnapshot<Map<String, dynamic>>> _sharedItemsStream() {
    final user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('shared_items')
        .where('toUserUid', isEqualTo: user?.uid)
        .snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchItem(String itemId) {
    return FirebaseFirestore.instance.collection('items').doc(itemId).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shared With Me')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _sharedItemsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Something went wrong while loading shared items.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final sharedDocs = [...(snapshot.data?.docs ?? [])]
            ..sort((a, b) {
              final aTimestamp = a.data()['createdAt'] as Timestamp?;
              final bTimestamp = b.data()['createdAt'] as Timestamp?;
              final aMillis = aTimestamp?.millisecondsSinceEpoch ?? 0;
              final bMillis = bTimestamp?.millisecondsSinceEpoch ?? 0;
              return bMillis.compareTo(aMillis);
            });

          if (sharedDocs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No items have been shared with you yet.'),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: sharedDocs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final shareData = sharedDocs[index].data();
              final itemId = shareData['itemId'] as String? ?? '';

              return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: _fetchItem(itemId),
                builder: (context, itemSnapshot) {
                  if (itemSnapshot.connectionState == ConnectionState.waiting) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  if (itemSnapshot.hasError) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('Failed to load a shared item.'),
                      ),
                    );
                  }

                  final itemDoc = itemSnapshot.data;
                  if (itemDoc == null || !itemDoc.exists) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('This shared item is no longer available.'),
                      ),
                    );
                  }

                  final itemData = itemDoc.data() ?? {};
                  final name = itemData['name'] as String? ?? 'Untitled item';
                  final description =
                      itemData['description'] as String? ?? 'No description';
                  final rarity =
                      itemData['rarity'] as String? ?? 'Unknown rarity';
                  final ownerUid = itemData['ownerUid'] as String? ?? '';
                  final createdAt = itemData['createdAt'] as Timestamp?;

                  return InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ItemDetailView(
                            itemId: itemDoc.id,
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
          );
        },
      ),
    );
  }
}
