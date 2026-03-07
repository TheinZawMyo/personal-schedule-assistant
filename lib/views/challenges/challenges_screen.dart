import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/challenge_provider.dart';
import 'add_challenge_screen.dart';
import '../../models/challenge.dart';
import '../../core/theme/app_colors.dart';

class ChallengesScreen extends ConsumerWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenges = ref.watch(challengeProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildStats(challenges),
              const SizedBox(height: 24),
              const Text(
                'Ongoing Challenges',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: challenges.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.builder(
                        itemCount: challenges.length,
                        itemBuilder: (context, index) {
                          final challenge = challenges[index];
                          return _buildChallengeCard(context, ref, challenge);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddChallengeScreen()),
        ),
        child: const Icon(LucideIcons.trophy),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Motivation & Goals',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        Text(
          'Challenges',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStats(List<Challenge> challenges) {
    final activeCount = challenges
        .where((c) => c.isActive && c.endDate.isAfter(DateTime.now()))
        .length;
    final completedCount = challenges
        .where((c) => c.endDate.isBefore(DateTime.now()))
        .length;

    return Row(
      children: [
        _buildStatCard(
          'Active',
          activeCount.toString(),
          LucideIcons.flame,
          Colors.orange,
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          'Completed',
          completedCount.toString(),
          LucideIcons.checkCircle,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeCard(
    BuildContext context,
    WidgetRef ref,
    Challenge challenge,
  ) {
    final now = DateTime.now();
    final totalDays =
        challenge.endDate.difference(challenge.startDate).inDays + 1;
    final currentDay = challenge.startDate.isAfter(now)
        ? 0
        : now.difference(challenge.startDate).inDays + 1;

    final progress = (currentDay / totalDays).clamp(0.0, 1.0);
    final isFinished = challenge.endDate.isBefore(now);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddChallengeScreen(challenge: challenge),
          ),
        ),
        onLongPress: () => _showDeleteDialog(context, ref, challenge),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      challenge.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (challenge.isSpecificTime)
                    Icon(LucideIcons.clock, size: 14, color: AppColors.primary),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${DateFormat('MMM d').format(challenge.startDate)} — ${DateFormat('MMM d').format(challenge.endDate)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isFinished
                        ? 'Challenge Ended'
                        : 'Day $currentDay of $totalDays',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
                minHeight: 6,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    Challenge challenge,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Challenge'),
        content: Text('Are you sure you want to delete "${challenge.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(challengeProvider.notifier)
                  .deleteChallenge(challenge.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.trophy,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          const Text(
            'No challenges yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ready to push yourself? Create your first challenge!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
