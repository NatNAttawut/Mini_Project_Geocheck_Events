class AdminProfile {
  final int id;

  final String firstname;
  final String lastname;

  final String email;
  final String role;

  final int totalUsers;
  final int totalEvents;
  final int openEvents;
  final int todayCheckins;

  const AdminProfile({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.role,
    required this.totalUsers,
    required this.totalEvents,
    required this.openEvents,
    required this.todayCheckins,
  });

  String get fullName {
    return '$firstname $lastname'.trim();
  }

  String get initials {
    final first =
        firstname.isNotEmpty
            ? firstname[0].toUpperCase()
            : '';

    final last =
        lastname.isNotEmpty
            ? lastname[0].toUpperCase()
            : '';

    return '$first$last';
  }
}