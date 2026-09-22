import 'user_event.dart';

class UserHomeData {
  final String firstname;
  final String lastname;

  final int registeredTotal;
  final int checkedInTotal;
  final int upcomingTotal;
  final int checkinReadyTotal;

  final UserEvent? nextEvent;

  final List<UserEvent>
      checkinReadyEvents;

  final List<UserEvent>
      openEvents;

  const UserHomeData({
    required this.firstname,
    required this.lastname,
    required this.registeredTotal,
    required this.checkedInTotal,
    required this.upcomingTotal,
    required this.checkinReadyTotal,
    required this.nextEvent,
    required this.checkinReadyEvents,
    required this.openEvents,
  });

  String get fullName =>
      '$firstname $lastname'.trim();

  factory UserHomeData.fromJson(
    Map<String, dynamic> json,
  ) {
    final user =
        json['user']
            as Map<String, dynamic>? ??
        {};

    final summary =
        json['summary']
            as Map<String, dynamic>? ??
        {};

    final readyRaw =
        json['checkin_ready_events']
            as List<dynamic>? ??
        [];

    final openRaw =
        json['open_events']
            as List<dynamic>? ??
        [];

    final nextRaw =
        json['next_event'];

    return UserHomeData(
      firstname:
          user['firstname']
                  ?.toString() ??
              '',

      lastname:
          user['lastname']
                  ?.toString() ??
              '',

      registeredTotal:
          int.tryParse(
            summary[
                    'registered_total']
                .toString(),
          ) ??
          0,

      checkedInTotal:
          int.tryParse(
            summary[
                    'checked_in_total']
                .toString(),
          ) ??
          0,

      upcomingTotal:
          int.tryParse(
            summary[
                    'upcoming_total']
                .toString(),
          ) ??
          0,

      checkinReadyTotal:
          int.tryParse(
            summary[
                    'checkin_ready_total']
                .toString(),
          ) ??
          0,

      nextEvent:
          nextRaw == null
              ? null
              : UserEvent.fromJson(
                  nextRaw as Map<
                      String,
                      dynamic>,
                ),

      checkinReadyEvents:
          readyRaw
              .map(
                (item) =>
                    UserEvent.fromJson(
                  item as Map<
                      String,
                      dynamic>,
                ),
              )
              .toList(),

      openEvents:
          openRaw
              .map(
                (item) =>
                    UserEvent.fromJson(
                  item as Map<
                      String,
                      dynamic>,
                ),
              )
              .toList(),
    );
  }
}