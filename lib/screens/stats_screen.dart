import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../providers/habit_providers.dart';
import '../utils/habit_statistics.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final habitsAsync = ref.watch(habitControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: habitsAsync.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return _StatsError(
            onRetry: () {
              ref.invalidate(habitControllerProvider);
            },
          );
        },
        data: (habits) {
          return _StatsContent(
            habits: habits,
          );
        },
      ),
    );
  }
}

class _StatsContent extends StatelessWidget {
  final List<Habit> habits;

  const _StatsContent({
    required this.habits,
  });

  @override
  Widget build(BuildContext context) {
    if (habits.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bar_chart,
                size: 56,
              ),
              SizedBox(height: 16),
              Text(
                'No statistics yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Create and complete '
                'habits to start building '
                'your statistics.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final today = dateOnly(DateTime.now());

    final todaySummary = completionSummaryForDate(habits, today);

    final weekSummary = completionSummaryForWeek(habits, today);

    final completions = totalCompletions(habits);

    final currentBestStreak = bestCurrentStreak(habits, today);

    final longestStreak = longestStreakAcrossHabits(habits, today);

    final bestHabit = bestPerformingHabit(habits, today);

    final sevenDays = lastSevenDaysStats(habits, today);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Overview',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),

        const SizedBox(height: 16),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.45,
          children: [
            _MetricCard(
              icon: Icons.today_outlined,
              value: '${todaySummary.percentage}%',
              label: "Today's completion",
            ),

            _MetricCard(
              icon: Icons.date_range_outlined,
              value: '${weekSummary.percentage}%',
              label: 'This week',
            ),

            _MetricCard(
              icon: Icons.check_circle_outline,
              value: '$completions',
              label: 'Total completions',
            ),

            _MetricCard(
              icon: Icons.local_fire_department_outlined,
              value: '$currentBestStreak',
              label: 'Best current streak',
            ),
          ],
        ),

        const SizedBox(height: 28),

        _LongestStreakCard(streak: longestStreak),

        const SizedBox(height: 12),

        if (bestHabit != null)
          _BestHabitCard(performance: bestHabit),
        
        const SizedBox(height: 28),

        Text(
          'Last 7 days',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),

        const SizedBox(height: 12),

        _CompletionTrendChart(stats: sevenDays),

        const SizedBox(height: 32),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),

            const SizedBox(height: 10),

            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _LongestStreakCard extends StatelessWidget {
  final int streak;

  const _LongestStreakCard({
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              Icons.local_fire_department,
              size: 38,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Longest streak',
                    style: Theme.of(context)
                        .textTheme.titleMedium,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '$streak '
                    '${streak == 1 ? 'day' : 'days'}',
                    style: 
                        Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BestHabitCard extends StatelessWidget {
  final HabitPerformance performance;

  const _BestHabitCard({
    required this.performance,
  });

  @override
  Widget build(BuildContext context) {
    final habit = performance.habit;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),

                const SizedBox(width: 8),

                const Text(
                  'Best-performing habit',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              habit.name,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 4),

            Text(
              '${performance.summary.completed} '
              'of '
              '${performance.summary.scheduled} '
              'completed',
            ),

            const SizedBox(height: 12),

            LinearProgressIndicator(
              value: performance.rate,
              minHeight: 8,
            ),

            const SizedBox(height: 8),

            Text(
              '${performance.percentage}% completion rate',
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletionTrendChart extends StatelessWidget {
  final List<DayCompletionStat> stats;

  const _CompletionTrendChart({
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    final inactiveColor = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
        child: SizedBox(
          height: 180,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: stats.map(
              (stat) {
                final barFactor = 
                    !stat.hasScheduledHabits
                        ? 0.02
                        : stat.rate == 0
                            ? 0.05
                            : stat.rate;

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        stat.hasScheduledHabits
                            ? '${stat.percentage}%'
                            : '—',
                        style: const TextStyle(
                          fontSize: 11,
                        ),
                      ),

                      const SizedBox(height: 6),

                      SizedBox(
                        height: 100,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: 22,
                            height: 100 * barFactor,
                            decoration: BoxDecoration(
                              color: stat.hasScheduledHabits
                                  ? primaryColor
                                  : inactiveColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        DateFormat(
                          'EEE',
                        ).format(
                          stat.date,
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ).toList(),
          ),
        ),
      ),
    );
  }
}

class _StatsError extends StatelessWidget {
  final VoidCallback onRetry;

  const _StatsError({
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48
            ),

            const SizedBox(height: 12),

            const Text('Could not load statistics'),

            const SizedBox(height: 16),

            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}