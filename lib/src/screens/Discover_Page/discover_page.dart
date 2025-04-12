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
  bool _showAllMatches = false;
  final _searchController = TextEditingController();
  List<Event> _searchResults = [];
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.lightPrimary,
        title: const Text('Discover Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Popular Events'),
            _buildPopularEvents(),
            _buildTodayMatchesHeader(),
            _buildTodayMatches(),
            _buildSectionTitle('Latest News'),
            _buildNewsSection(),
          ],
        ),
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
    return SizedBox(
      height: 200,
      child: Consumer<EventProvider>(
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
                  return SizedBox(
                    width: 300,
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
      ),
    );
  }

  Widget _buildTodayMatchesHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Today's Matches",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _showAllMatches = !_showAllMatches),
            child: Text(
              _showAllMatches ? 'Show Less' : 'See All',
              style: const TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayMatches() {
    return Consumer<EventProvider>(
      builder: (context, provider, child) {
        return StreamBuilder<List<Event>>(
          stream: provider.getTodayEvents(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final events = snapshot.data!;
            return SizedBox(
              height: _showAllMatches ? null : 200,
              child: ListView.builder(
                shrinkWrap: _showAllMatches,
                physics: _showAllMatches
                    ? const NeverScrollableScrollPhysics()
                    : null,
                scrollDirection:
                    _showAllMatches ? Axis.vertical : Axis.horizontal,
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: _showAllMatches ? null : 300,
                    child: EventCard(
                      event: events[index],
                      onRegister: () {},
                      isRegistered: false,
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNewsSection() {
    return SizedBox(
      height: 200,
      child: Consumer<NewsProvider>(
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
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showNewsDetails(News news) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(news.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (news.imageUrl != null) Image.network(news.imageUrl!),
              const SizedBox(height: 16),
              Text(news.description),
              const SizedBox(height: 8),
              Text(
                _formatDate(news.timestamp),
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
