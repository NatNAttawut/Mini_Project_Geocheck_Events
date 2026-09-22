class AdminReport {
  final int totalUsers;
  final int totalEvents;
  final int openEvents;

  final int totalRegistrations;
  final int totalCheckins;

  final double attendanceRate;

  final List<EventReport> events;

  const AdminReport({
    required this.totalUsers,
    required this.totalEvents,
    required this.openEvents,
    required this.totalRegistrations,
    required this.totalCheckins,
    required this.attendanceRate,
    required this.events,
  });

  factory AdminReport.fromJson(
    Map<String, dynamic> json,
  ) {
    final summary =
        json['summary']
            as Map<String, dynamic>? ??
        {};

    final rawEvents =
        json['events']
            as List<dynamic>? ??
        [];

    return AdminReport(
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

      totalRegistrations:
          int.tryParse(
            summary[
                    'total_registrations']
                .toString(),
          ) ??
          0,

      totalCheckins:
          int.tryParse(
            summary['total_checkins']
                .toString(),
          ) ??
          0,

      attendanceRate:
          double.tryParse(
            summary['attendance_rate']
                .toString(),
          ) ??
          0,

      events:
          rawEvents
              .map(
                (item) =>
                    EventReport.fromJson(
                  item as Map<
                      String,
                      dynamic>,
                ),
              )
              .toList(),
    );
  }
}

// =============================================================
// Event Report
// =============================================================

class EventReport {
  final int id;

  final String title;
  final String locationName;

  final DateTime startAt;
  final DateTime endAt;

  final String status;

  final int? maxParticipants;

  final int registeredCount;
  final int checkinCount;

  final double attendanceRate;

  const EventReport({
    required this.id,
    required this.title,
    required this.locationName,
    required this.startAt,
    required this.endAt,
    required this.status,
    this.maxParticipants,
    required this.registeredCount,
    required this.checkinCount,
    required this.attendanceRate,
  });

  factory EventReport.fromJson(
    Map<String, dynamic> json,
  ) {
    return EventReport(
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

      // UTC -> Local
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

      attendanceRate:
          double.tryParse(
            json['attendance_rate']
                .toString(),
          ) ??
          0,
    );
  }
}