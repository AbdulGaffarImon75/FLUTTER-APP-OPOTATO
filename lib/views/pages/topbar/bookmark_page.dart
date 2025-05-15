// lib/views/pages/bookmark_page.dart

import 'package:flutter/material.dart';
import '/controllers/bookmark_controller.dart';
import '/../models/bookmark_model.dart';
import 'package:O_potato/views/pages/bottom_nav_bar.dart';

class BookmarkPage extends StatelessWidget {
  const BookmarkPage({super.key});

  @override
  Widget build(BuildContext context) {
    final BookmarkController ctrl = BookmarkController();

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavBar(activeIndex: 2),
      appBar: AppBar(title: const Text('Bookmarks')),
      body: StreamBuilder<List<BookmarkModel>>(
        stream: ctrl.streamBookmarks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final bookmarks = snapshot.data!;
          if (bookmarks.isEmpty) {
            return const Center(child: Text('No bookmarks yet.'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
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
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bookmarks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    return _BookmarkCard(
                      bookmark: bookmarks[i],
                      onRemove: () => ctrl.removeBookmark(bookmarks[i].id),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BookmarkCard extends StatelessWidget {
  final BookmarkModel bookmark;
  final VoidCallback onRemove;

  const _BookmarkCard({required this.bookmark, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => BookmarkDetailsPage(
                    title: bookmark.title,
                    restaurant: bookmark.vendor,
                  ),
            ),
          ),
      child: Card(
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
                      bookmark.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bookmark.price,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bookmark.vendor,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    bookmark.imageUrl.isNotEmpty
                        ? Image.network(
                          bookmark.imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        )
                        : Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 40),
                        ),
              ),
              IconButton(
                icon: const Icon(Icons.bookmark, color: Colors.purple),
                onPressed: onRemove,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Keep your existing details page below:
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
