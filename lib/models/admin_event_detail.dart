class AdminEventDetail {
  final int id;

  final String title;
  final String? description;

  final String locationName;

  final double latitude;
  final double longitude;

  final int checkinRadius;

  final DateTime startAt;
  final DateTime endAt;

  final DateTime? checkinStartAt;
  final DateTime? checkinEndAt;

  final int? maxParticipants;

  final String status;

  final int registeredCount;
  final int checkinCount;
  final int pendingCount;

  final List<EventParticipant>
      participants;

  const AdminEventDetail({
    required this.id,
    required this.title,
    this.description,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.checkinRadius,
    required this.startAt,
    required this.endAt,
    this.checkinStartAt,
    this.checkinEndAt,
    this.maxParticipants,
    required this.status,
    required this.registeredCount,
    required this.checkinCount,
    required this.pendingCount,
    required this.participants,
  });

  factory AdminEventDetail.fromJson(
    Map<String, dynamic> json,
  ) {
    final event =
        json['event']
            as Map<String, dynamic>;

    final rawParticipants =
        json['participants']
            as List<dynamic>? ??
        [];

    return AdminEventDetail(
      id:
          int.tryParse(
            event['id'].toString(),
          ) ??
          0,

      title:
          event['title']
                  ?.toString() ??
              '',

      description:
          event['description']
              ?.toString(),

      locationName:
          event['location_name']
                  ?.toString() ??
              '',

      latitude:
          double.tryParse(
            event['latitude']
                .toString(),
          ) ??
          0,

      longitude:
          double.tryParse(
            event['longitude']
                .toString(),
          ) ??
          0,

      checkinRadius:
          int.tryParse(
            event['checkin_radius']
                .toString(),
          ) ??
          100,

      // UTC -> Local เวลาไทย
      startAt:
          DateTime.parse(
            event['start_at']
                .toString(),
          ).toLocal(),

      endAt:
          DateTime.parse(
            event['end_at']
                .toString(),
          ).toLocal(),

      checkinStartAt:
          event['checkin_start_at'] ==
                  null
              ? null
              : DateTime.tryParse(
                  event[
                          'checkin_start_at']
                      .toString(),
                )?.toLocal(),

      checkinEndAt:
          event['checkin_end_at'] ==
                  null
              ? null
              : DateTime.tryParse(
                  event[
                          'checkin_end_at']
                      .toString(),
                )?.toLocal(),

      maxParticipants:
          event['max_participants'] ==
                  null
              ? null
              : int.tryParse(
                  event[
                          'max_participants']
                      .toString(),
                ),

      status:
          event['status']
                  ?.toString() ??
              'draft',

      registeredCount:
          int.tryParse(
            event['registered_count']
                .toString(),
          ) ??
          0,

      checkinCount:
          int.tryParse(
            event['checkin_count']
                .toString(),
          ) ??
          0,

      pendingCount:
          int.tryParse(
            event['pending_count']
                .toString(),
          ) ??
          0,

      participants:
          rawParticipants
              .map(
                (item) =>
                    EventParticipant
                        .fromJson(
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
// Participant
// =============================================================

class EventParticipant {
  final int userId;

  final String firstname;
  final String lastname;

  final String? studentId;
  final String email;

  final DateTime? registeredAt;

  final bool checkedIn;

  final DateTime? checkedInAt;

  final double? distanceMeters;

  final double? checkinLatitude;
  final double? checkinLongitude;

  const EventParticipant({
    required this.userId,
    required this.firstname,
    required this.lastname,
    this.studentId,
    required this.email,
    this.registeredAt,
    required this.checkedIn,
    this.checkedInAt,
    this.distanceMeters,
    this.checkinLatitude,
    this.checkinLongitude,
  });

  String get fullName =>
      '$firstname $lastname'.trim();

  String get initials {
    final first =
        firstname.isNotEmpty
            ? firstname[0]
                .toUpperCase()
            : '';

    final last =
        lastname.isNotEmpty
            ? lastname[0]
                .toUpperCase()
            : '';

    return '$first$last';
  }

  factory EventParticipant.fromJson(
    Map<String, dynamic> json,
  ) {
    return EventParticipant(
      userId:
          int.tryParse(
            json['user_id']
                .toString(),
          ) ??
          0,

      firstname:
          json['firstname']
                  ?.toString() ??
              '',

      lastname:
          json['lastname']
                  ?.toString() ??
              '',

      studentId:
          json['student_id']
              ?.toString(),

      email:
          json['email']
                  ?.toString() ??
              '',

      registeredAt:
          json['registered_at'] ==
                  null
              ? null
              : DateTime.tryParse(
                  json[
                          'registered_at']
                      .toString(),
                )?.toLocal(),

      checkedIn:
          json['checked_in'] ==
                  true ||
              json['checked_in']
                      ?.toString() ==
                  '1',

      checkedInAt:
          json['checked_in_at'] ==
                  null
              ? null
              : DateTime.tryParse(
                  json[
                          'checked_in_at']
                      .toString(),
                )?.toLocal(),

      distanceMeters:
          json['distance_meters'] ==
                  null
              ? null
              : double.tryParse(
                  json[
                          'distance_meters']
                      .toString(),
                ),

      checkinLatitude:
          json['checkin_latitude'] ==
                  null
              ? null
              : double.tryParse(
                  json[
                          'checkin_latitude']
                      .toString(),
                ),

      checkinLongitude:
          json['checkin_longitude'] ==
                  null
              ? null
              : double.tryParse(
                  json[
                          'checkin_longitude']
                      .toString(),
                ),
    );
  }
}