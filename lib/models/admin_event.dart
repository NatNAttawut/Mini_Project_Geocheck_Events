class AdminEvent {
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

  const AdminEvent({
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
  });

  factory AdminEvent.fromJson(
    Map<String, dynamic> json,
  ) {
    return AdminEvent(
      id: int.tryParse(
            json['id'].toString(),
          ) ??
          0,

      title:
          json['title']?.toString() ??
              '',

      description:
          json['description']?.toString(),

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

      startAt: DateTime.parse(
        json['start_at'].toString(),
      ).toLocal(),

      endAt: DateTime.parse(
        json['end_at'].toString(),
      ).toLocal(),

      checkinStartAt:
        json['checkin_start_at'] == null
            ? null
            : DateTime.tryParse(
                json['checkin_start_at'].toString(),
              )?.toLocal(),

      checkinEndAt:
        json['checkin_end_at'] == null
            ? null
            : DateTime.tryParse(
                json['checkin_end_at'].toString(),
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
          json['status']?.toString() ??
              'draft',

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