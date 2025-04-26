import 'package:compete_hub/src/models/news.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../providers/event_provider.dart';
import '../../widgets/event_card.dart';
import '../../../core/utils/app_colors.dart';
import '../../providers/news_provider.dart';
import '../search_screen/search_screen.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final _searchController = TextEditingController();
  List<Event> _searchResults = [];
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.lightPrimary,
        automaticallyImplyLeading: false,
        title: const Text('Discover Events',
            style: TextStyle(color: Colors.white, fontSize: 24)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Popular Events'),
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildPopularEvents(),
            ),
          ),
          _buildSectionTitle('Latest News'),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildNewsSection(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPopularEvents() {
    return Consumer<EventProvider>(
      builder: (context, provider, child) {
        return StreamBuilder<List<Event>>(
          stream: provider.getPopularEvents(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final events = snapshot.data!;
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: events.length,
              itemBuilder: (context, index) {
                return Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  margin: const EdgeInsets.only(right: 16),
                  child: EventCard(
                    event: events[index],
                    onRegister: () {},
                    isRegistered: false,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildNewsSection() {
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, child) {
        return StreamBuilder<List<News>>(
          stream: newsProvider.streamNews(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final news = snapshot.data!;
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: news.length,
              itemBuilder: (context, index) {
                final newsItem = news[index];
                return Container(
                  width: 300,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (newsItem.imageUrl != null)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                          child: Image.network(
                            newsItem.imageUrl!,
                            height: 100,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              newsItem.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              newsItem.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDate(newsItem.timestamp),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => _showNewsDetails(newsItem),
                              icon: const Icon(Icons.arrow_forward),
                              label: const Text('See Details'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showNewsDetails(News news) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.lightPrimary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (news.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      news.imageUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  news.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDate(news.timestamp),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  news.description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
