import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:O_potato/pages/bottom_nav_bar.dart';

class BookmarkPage extends StatelessWidget {
  const BookmarkPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view bookmarks')),
      );
    }

    final bookmarkStream =
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('bookmarks')
            .orderBy('timestamp', descending: true)
            .snapshots();

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavBar(activeIndex: 2),
      appBar: AppBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: bookmarkStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookmarks = snapshot.data!.docs;

          if (bookmarks.isEmpty) {
            return const Center(child: Text('No bookmarks yet.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Column(
                    children: [
                      Icon(Icons.bookmark, size: 80, color: Colors.purple),
                      SizedBox(height: 10),
                      Text(
                        'Bookmarks',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bookmarks.length,
                  itemBuilder: (context, index) {
                    final doc = bookmarks[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildBookmarkCard(context, doc.id, data);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookmarkCard(
    BuildContext context,
    String docId,
    Map<String, dynamic> bookmark,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => BookmarkDetailsPage(
                  title: bookmark['title'] ?? '',
                  restaurant: bookmark['vendor'] ?? 'Unknown vendor',
                ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bookmark['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bookmark['price'] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.purple,
                      ),
                    ),
                    if (bookmark['vendor'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        bookmark['vendor']!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  color: Colors.grey[300],
                  width: 80,
                  height: 80,
                  child:
                      bookmark['imageURL'] != null
                          ? Image.network(
                            bookmark['imageURL'],
                            fit: BoxFit.cover,
                          )
                          : const Icon(
                            Icons.image,
                            size: 40,
                            color: Colors.white,
                          ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.bookmark, color: Colors.purple),
                onPressed: () => _removeBookmark(docId),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _removeBookmark(String docId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('bookmarks')
        .doc(docId)
        .delete();
  }
}

class BookmarkDetailsPage extends StatelessWidget {
  final String title;
  final String restaurant;

  const BookmarkDetailsPage({
    super.key,
    required this.title,
    required this.restaurant,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: Center(
        child: Text(
          'Details for "$title"\nfrom "$restaurant"',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
