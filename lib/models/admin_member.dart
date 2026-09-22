class AdminMember {
  final int id;
  final String firstname;
  final String lastname;
  final String? studentId;
  final String email;
  final String role;
  final String? createdAt;

  const AdminMember({
    required this.id,
    required this.firstname,
    required this.lastname,
    this.studentId,
    required this.email,
    required this.role,
    this.createdAt,
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

  factory AdminMember.fromJson(
    Map<String, dynamic> json,
  ) {
    return AdminMember(
      id: int.tryParse(
            json['id'].toString(),
          ) ??
          0,

      firstname:
          json['firstname']?.toString() ??
              '',

      lastname:
          json['lastname']?.toString() ??
              '',

      studentId:
          json['student_id']?.toString(),

      email:
          json['email']?.toString() ??
              '',

      role:
          json['role']?.toString() ??
              'user',

      createdAt:
          json['created_at']?.toString(),
    );
  }
}