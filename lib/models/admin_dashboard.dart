class AdminDashboard {
  final int totalUsers;
  final int totalEvents;
  final int openEvents;
  final int todayCheckins;

  final List<DashboardEvent>
      recentEvents;

  const AdminDashboard({
    required this.totalUsers,
    required this.totalEvents,
    required this.openEvents,
    required this.todayCheckins,
    required this.recentEvents,
  });

  factory AdminDashboard.fromJson(
    Map<String, dynamic> json,
  ) {
    final summary =
        json['summary']
            as Map<String, dynamic>? ??
        {};

    final rawEvents =
        json['recent_events']
            as List<dynamic>? ??
        [];

    return AdminDashboard(
      totalUsers:
          int.tryParse(
            summary['total_users']
                .toString(),
          ) ??
          0,

      totalEvents:
          int.tryParse(
            summary['total_events']
                .toString(),
          ) ??
          0,

      openEvents:
          int.tryParse(
            summary['open_events']
                .toString(),
          ) ??
          0,

      todayCheckins:
          int.tryParse(
            summary['today_checkins']
                .toString(),
          ) ??
          0,

      recentEvents:
          rawEvents.map(
        (item) {
          return DashboardEvent
              .fromJson(
            item as Map<String, dynamic>,
          );
        },
      ).toList(),
    );
  }
}

// =============================================================
// Recent Event
// =============================================================

class DashboardEvent {
  final int id;

  final String title;
  final String locationName;

  final DateTime startAt;
  final DateTime endAt;

  final String status;

  final int? maxParticipants;

  final int registeredCount;
  final int checkinCount;

  const DashboardEvent({
    required this.id,
    required this.title,
    required this.locationName,
    required this.startAt,
    required this.endAt,
    required this.status,
    this.maxParticipants,
    required this.registeredCount,
    required this.checkinCount,
  });

  factory DashboardEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return DashboardEvent(
      id:
          int.tryParse(
            json['id'].toString(),
          ) ??
          0,

      title:
          json['title']
                  ?.toString() ??
              '',

      locationName:
          json['location_name']
                  ?.toString() ??
              '',

      // สำคัญ: UTC -> Local +7
      startAt:
          DateTime.parse(
            json['start_at'].toString(),
          ).toLocal(),

      endAt:
          DateTime.parse(
            json['end_at'].toString(),
          ).toLocal(),

      status:
          json['status']
                  ?.toString() ??
              'draft',

      maxParticipants:
          json['max_participants'] ==
                  null
              ? null
              : int.tryParse(
                  json[
                          'max_participants']
                      .toString(),
                ),

      registeredCount:
          int.tryParse(
            json['registered_count']
                .toString(),
          ) ??
          0,

      checkinCount:
          int.tryParse(
            json['checkin_count']
                .toString(),
          ) ??
          0,
    );
  }
}