class UserEvent {
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

  final bool isRegistered;

  final bool isCheckedIn;

  final DateTime? checkedInAt;

  final double? checkinDistance;

  const UserEvent({
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
    required this.isRegistered,
    this.isCheckedIn = false,
    this.checkedInAt,
    this.checkinDistance,
  });

  // =========================================================
  // จำนวนที่เหลือ
  // =========================================================

  int? get remainingSlots {
    if (maxParticipants == null) {
      return null;
    }

    final remaining =
        maxParticipants! -
        registeredCount;

    return remaining < 0
        ? 0
        : remaining;
  }

  bool get isFull {
    if (maxParticipants == null) {
      return false;
    }

    return registeredCount >=
        maxParticipants!;
  }

  // =========================================================
  // JSON
  // =========================================================

  factory UserEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserEvent(
      id:
          int.tryParse(
            json['id'].toString(),
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

      latitude:
          double.tryParse(
            json['latitude']
                .toString(),
          ) ??
          0,

      longitude:
          double.tryParse(
            json['longitude']
                .toString(),
          ) ??
          0,

      checkinRadius:
          int.tryParse(
            json['checkin_radius']
                .toString(),
          ) ??
          100,

      // Server UTC -> Local ของอุปกรณ์
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

      maxParticipants:
          json['max_participants'] ==
                  null
              ? null
              : int.tryParse(
                  json[
                          'max_participants']
                      .toString(),
                ),

      status:
          json['status']
                  ?.toString() ??
              'open',

      registeredCount:
          int.tryParse(
            json['registered_count']
                .toString(),
          ) ??
          0,

      isRegistered:
          json['is_registered'] ==
                  true ||
              json['is_registered']
                      ?.toString() ==
                  '1',
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
            json[
                    'checked_in_at']
                .toString(),
          )?.toLocal(),

checkinDistance:
    json['checkin_distance'] ==
            null
        ? null
        : double.tryParse(
            json[
                    'checkin_distance']
                .toString(),
          ),


    );
    
  }
}