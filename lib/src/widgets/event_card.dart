import 'package:compete_hub/src/screens/feedback/event_feedback_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/utils/app_colors.dart';
import '../models/event.dart';
import '../providers/event_provider.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onRegister;
  final bool isRegistered;
  final bool hideFeedbackButton;

  const EventCard({
    Key? key,
    required this.event,
    this.onRegister,
    this.isRegistered = false,
    this.hideFeedbackButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.lightPrimary.withOpacity(0.1),
      color: AppColors.lightBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isRegistered 
              ? AppColors.lightPrimary.withOpacity(0.3)
              : AppColors.lightPrimary.withOpacity(0.08),
          width: isRegistered ? 2 : 1,
        ),
      ),
      child: Stack(
        //clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  _buildBannerImage(),
                  Positioned(
                    top: 6,
                    right: 8, // Remove conditional positioning
                    child: StreamBuilder<int>(
                      stream: Provider.of<EventProvider>(context)
                          .getEventLikes(event.id),
                      builder: (context, snapshot) {
                        final likes = snapshot.data ?? 0;
                        final hasLiked = Provider.of<EventProvider>(context)
                            .hasUserLikedEvent(event.id);

                        return Container(
                          height: 35,
                          padding: EdgeInsets.only(left: 6),
                          decoration: BoxDecoration(
                            color: AppColors.lightPrimary,
                            borderRadius: BorderRadius.circular(12),
                            //border: Border.all(color: Colors.grey)
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$likes',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: Icon(
                                  hasLiked == true
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: hasLiked == true
                                      ? Colors.red
                                      : Colors.white,
                                ),
                                onPressed: () {
                                  Provider.of<EventProvider>(context,
                                          listen: false)
                                      .toggleEventLike(event.id);
                                },
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                iconSize: 18,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style:  TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.lightPrimary.withOpacity(1),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.description,
                      style: const TextStyle(color: AppColors.lightOnSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          event.locationType == EventLocationType.online
                              ? Icons.computer
                              : Icons.location_on,
                          color: AppColors.lightOnSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          event.location ?? 'Online',
                          style: const TextStyle(color: AppColors.lightOnSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Format: ${event.format.toString().split('.').last}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        if (Provider.of<EventProvider>(context)
                            .isEventOrganizer(event.organizerId))
                          const Text(
                            'Creator',
                            style: TextStyle(
                              color: AppColors.lightPrimaryVariant,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        else if (!isRegistered)
                          ElevatedButton(
                            onPressed: onRegister,
                            child: const Text('Register'),
                          )
                        else
                          Text(
                            'Registered',
                            style: TextStyle(
                              color: Colors.green,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (!hideFeedbackButton)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EventFeedbackScreen(event: event),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.feedback, size: 16),
                              label: const Text('Live a Feedback'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.lightOnSurfaceVariant,
                                side: BorderSide(color: AppColors.lightOnSurfaceVariant.withOpacity(0.3)),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBannerImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      child: event.bannerImageUrl != null
          ? CachedNetworkImage(
              imageUrl: event.bannerImageUrl!,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildPlaceholder(),
              errorWidget: (context, url, error) => _buildPlaceholder(),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade700,
            Colors.purple.shade700,
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            event.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
