class UserProfile {
  final int id;

  final String firstname;
  final String lastname;

  final String? studentId;

  final String email;
  final String role;

  final int registeredEvents;
  final int checkedInEvents;

  const UserProfile({
    required this.id,
    required this.firstname,
    required this.lastname,
    this.studentId,
    required this.email,
    required this.role,
    required this.registeredEvents,
    required this.checkedInEvents,
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

  factory UserProfile.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserProfile(
      id:
          int.tryParse(
            json['id'].toString(),
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

      role:
          json['role']
                  ?.toString() ??
              'user',

      registeredEvents:
          int.tryParse(
            json['registered_events']
                .toString(),
          ) ??
          0,

      checkedInEvents:
          int.tryParse(
            json['checked_in_events']
                .toString(),
          ) ??
          0,
    );
  }
}