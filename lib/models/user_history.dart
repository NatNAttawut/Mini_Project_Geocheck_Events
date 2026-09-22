class UserHistoryItem {
  final int eventId;

  final String title;
  final String? description;
  final String locationName;

  final DateTime startAt;
  final DateTime endAt;

  final DateTime? checkinStartAt;
  final DateTime? checkinEndAt;

  final String eventStatus;
  final String registrationStatus;

  final DateTime? registeredAt;

  final bool isCheckedIn;

  final DateTime? checkedInAt;

  final double? distanceMeters;

  final double? checkinLatitude;
  final double? checkinLongitude;

  const UserHistoryItem({
    required this.eventId,
    required this.title,
    this.description,
    required this.locationName,
    required this.startAt,
    required this.endAt,
    this.checkinStartAt,
    this.checkinEndAt,
    required this.eventStatus,
    required this.registrationStatus,
    this.registeredAt,
    required this.isCheckedIn,
    this.checkedInAt,
    this.distanceMeters,
    this.checkinLatitude,
    this.checkinLongitude,
  });

  // =========================================================
  // สถานะสำหรับหน้า History
  // =========================================================

  String get historyStatus {
    if (registrationStatus ==
        'cancelled') {
      return 'cancelled';
    }

    if (eventStatus ==
        'cancelled') {
      return 'cancelled';
    }

    if (isCheckedIn) {
      return 'checked_in';
    }

    final now =
        DateTime.now();

    final checkinDeadline =
        checkinEndAt ??
        endAt;

    if (now.isAfter(
      checkinDeadline,
    )) {
      return 'missed';
    }

    if (now.isBefore(
      startAt,
    )) {
      return 'upcoming';
    }

    return 'waiting';
  }

  // =========================================================
  // JSON
  // =========================================================

  factory UserHistoryItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserHistoryItem(
      eventId:
          int.tryParse(
            json['event_id']
                .toString(),
          ) ??
          0,

      title:
          json['title']
                  ?.toString() ??
              '',

      description:
          json['description']
              ?.toString(),

      locationName:
          json['location_name']
                  ?.toString() ??
              '',

      // UTC -> Local
      startAt:
          DateTime.parse(
            json['start_at']
                .toString(),
          ).toLocal(),

      endAt:
          DateTime.parse(
            json['end_at']
                .toString(),
          ).toLocal(),

      checkinStartAt:
          json['checkin_start_at'] ==
                  null
              ? null
              : DateTime.tryParse(
                  json[
                          'checkin_start_at']
                      .toString(),
                )?.toLocal(),

      checkinEndAt:
          json['checkin_end_at'] ==
                  null
              ? null
              : DateTime.tryParse(
                  json[
                          'checkin_end_at']
                      .toString(),
                )?.toLocal(),

      eventStatus:
          json['event_status']
                  ?.toString() ??
              '',

      registrationStatus:
          json[
                      'registration_status']
                  ?.toString() ??
              '',

      registeredAt:
          json['registered_at'] ==
                  null
              ? null
              : DateTime.tryParse(
                  json['registered_at']
                      .toString(),
                )?.toLocal(),

      isCheckedIn:
          json['is_checked_in'] ==
                  true ||
              json['is_checked_in']
                      ?.toString() ==
                  '1',

      checkedInAt:
          json['checked_in_at'] ==
                  null
              ? null
              : DateTime.tryParse(
                  json['checked_in_at']
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