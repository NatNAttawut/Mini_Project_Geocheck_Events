class AccessAccount {
  final int id;

  final String firstname;
  final String lastname;

  final String? studentId;

  final String email;
  final String role;

  const AccessAccount({
    required this.id,
    required this.firstname,
    required this.lastname,
    this.studentId,
    required this.email,
    required this.role,
  });

  String get fullName =>
      '$firstname $lastname'.trim();

  bool get isSuperAdmin =>
      role == 'super_admin';

  bool get isAdmin =>
      role == 'admin';

  bool get isUser =>
      role == 'user';

  factory AccessAccount.fromJson(
    Map<String, dynamic> json,
  ) {
    return AccessAccount(
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
    );
  }
}