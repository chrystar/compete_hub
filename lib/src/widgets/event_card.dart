import 'package:compete_hub/src/screens/feedback/event_feedback_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/utils/app_colors.dart';
import '../models/event.dart';
import '../providers/event_provider.dart';
import '../models/registration.dart'; // Add this import
import 'package:compete_hub/src/screens/payment/payment_screen.dart'; // Add this import
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:compete_hub/src/auth/sign_in.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onRegister;
  final bool isRegistered;
  final bool showFeedbackButton;
  final PaymentStatus? paymentStatus; // Add this
  final String? registrationId; // Add this

  const EventCard({
    Key? key,
    required this.event,
    this.onRegister,
    this.isRegistered = false,
    this.showFeedbackButton = true,
    this.paymentStatus,
    this.registrationId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasEnded = event.endDateTime.isBefore(DateTime.now());
    final authProvider = Provider.of<AuthProviders>(context, listen: false);
    final isAuthenticated = authProvider.currentUser != null;
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
                          else if (!isRegistered && !hasEnded)
                            ElevatedButton(
                              onPressed: isAuthenticated
                                  ? onRegister
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const LoginScreen(),
                                        ),
                                      );
                                    },
                              child: const Text('Register'),
                            )
                          else if (isRegistered && event.feeType == EventFeeType.paid && paymentStatus == PaymentStatus.pending && !hasEnded)
                            isAuthenticated
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Pending',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const LoginScreen(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                                    child: const Text('Login to Complete Registration'),
                                  )
                          else if (hasEnded)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Event Ended',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: (event.feeType == EventFeeType.paid && paymentStatus == PaymentStatus.pending)
                                    ? Colors.orange.withOpacity(0.1)
                                    : Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                (event.feeType == EventFeeType.paid && paymentStatus == PaymentStatus.pending)
                                    ? 'Pending'
                                    : 'Registered',
                                style: TextStyle(
                                  color: (event.feeType == EventFeeType.paid && paymentStatus == PaymentStatus.pending)
                                      ? Colors.orange
                                      : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (showFeedbackButton || hasEnded)
                            Expanded(
                              child: hasEnded
                                  ? ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EventFeedbackScreen(event: event),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.feedback, size: 16, color: Colors.white),
                                      label: const Text('Live a Feedback', style: TextStyle(color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.lightPrimary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                      ),
                                    )
                                  : OutlinedButton.icon(
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
