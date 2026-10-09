import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';
import '../../utils/date_formatter.dart';
import '../medicine/medicine_details_screen.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, child) {
        final events = state.events;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Activity & Trace Log'),
          ),
          body: RefreshIndicator(
            onRefresh: () => state.refreshData(),
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : events.isEmpty
                    ? ListView(
                        padding: const EdgeInsets.all(32),
                        children: const [
                          SizedBox(height: 60),
                          Icon(
                            Icons.history_rounded,
                            size: 64,
                            color: AppColors.textMuted,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No Activity Logged Yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Events like medicine additions, portion splits, location changes, and recall flags will appear here.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          
                          Color iconBg;
                          Color iconFg;
                          IconData iconData;

                          switch (event.eventType) {
                            case 'split':
                              iconBg = AppColors.splitBg;
                              iconFg = AppColors.split;
                              iconData = Icons.alt_route_rounded;
                              break;
                            case 'recalled':
                              iconBg = AppColors.criticalBg;
                              iconFg = AppColors.critical;
                              iconData = Icons.warning_rounded;
                              break;
                            case 'location_changed':
                              iconBg = AppColors.infoBg;
                              iconFg = AppColors.info;
                              iconData = Icons.place_rounded;
                              break;
                            case 'added':
                            default:
                              iconBg = AppColors.successBg;
                              iconFg = AppColors.success;
                              iconData = Icons.add_circle_outline_rounded;
                              break;
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(14),
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: iconBg,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(iconData, color: iconFg, size: 22),
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      event.title,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    DateFormatter.formatDateTime(event.createdAt),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  event.description,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                              onTap: () {
                                if (event.itemId.isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MedicineDetailsScreen(itemId: event.itemId),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
          ),
        );
      },
    );
  }
}
