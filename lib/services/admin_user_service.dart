import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/admin_member.dart';
import 'auth_service.dart';

class AdminUserService {
  // =========================================================
  // Headers
  // =========================================================

  static Future<Map<String, String>>
      _headers() async {
    final token =
        await AuthService.getToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null)
        'Authorization': 'Bearer $token',
    };
  }

  // =========================================================
  // Get Members
  // =========================================================

  static Future<Map<String, dynamic>>
      getMembers({
    String search = '',
  }) async {
    try {
      var uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/admin/users',
      );

      if (search.trim().isNotEmpty) {
        uri = uri.replace(
          queryParameters: {
            'search': search.trim(),
          },
        );
      }

      final response = await http.get(
        uri,
        headers: await _headers(),
      );

      final data =
          jsonDecode(response.body)
              as Map<String, dynamic>;

      if (response.statusCode == 200 &&
          data['success'] == true) {
        final List rawUsers =
            data['users'] ?? [];

        final members = rawUsers
            .map(
              (item) =>
                  AdminMember.fromJson(
                item,
              ),
            )
            .toList();

        return {
          'success': true,
          'members': members,
        };
      }

      return {
        'success': false,
        'message':
            data['message'] ??
            'ไม่สามารถโหลดสมาชิกได้',
      };
    } catch (error) {
      return {
        'success': false,
        'message':
            'ไม่สามารถเชื่อมต่อ Server ได้',
      };
    }
  }

  // =========================================================
  // Create Member
  // =========================================================

  static Future<Map<String, dynamic>>
      createMember({
    required String firstname,
    required String lastname,
    required String studentId,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          '${ApiConfig.baseUrl}/api/admin/users',
        ),
        headers: await _headers(),
        body: jsonEncode({
          'firstname': firstname.trim(),
          'lastname': lastname.trim(),
          'student_id':
              studentId.trim(),
          'email': email.trim(),
          'password': password,
        }),
      );

      final data =
          jsonDecode(response.body)
              as Map<String, dynamic>;

      return {
        'success':
            response.statusCode == 201 &&
            data['success'] == true,
        'message':
            data['message'] ??
            'ไม่สามารถเพิ่มสมาชิกได้',
      };
    } catch (error) {
      return {
        'success': false,
        'message':
            'ไม่สามารถเชื่อมต่อ Server ได้',
      };
    }
  }

  // =========================================================
  // Update Member
  // =========================================================

  static Future<Map<String, dynamic>>
      updateMember({
    required int id,
    required String firstname,
    required String lastname,
    required String studentId,
    required String email,
    String password = '',
  }) async {
    try {
      final response = await http.put(
        Uri.parse(
          '${ApiConfig.baseUrl}/api/admin/users/$id',
        ),
        headers: await _headers(),
        body: jsonEncode({
          'firstname': firstname.trim(),
          'lastname': lastname.trim(),
          'student_id':
              studentId.trim(),
          'email': email.trim(),
          'password': password,
        }),
      );

      final data =
          jsonDecode(response.body)
              as Map<String, dynamic>;

      return {
        'success':
            response.statusCode == 200 &&
            data['success'] == true,
        'message':
            data['message'] ??
            'ไม่สามารถแก้ไขสมาชิกได้',
      };
    } catch (error) {
      return {
        'success': false,
        'message':
            'ไม่สามารถเชื่อมต่อ Server ได้',
      };
    }
  }

  // =========================================================
  // Delete Member
  // =========================================================

  static Future<Map<String, dynamic>>
      deleteMember(int id) async {
    try {
      final response =
          await http.delete(
        Uri.parse(
          '${ApiConfig.baseUrl}/api/admin/users/$id',
        ),
        headers: await _headers(),
      );

      final data =
          jsonDecode(response.body)
              as Map<String, dynamic>;

      return {
        'success':
            response.statusCode == 200 &&
            data['success'] == true,
        'message':
            data['message'] ??
            'ไม่สามารถลบสมาชิกได้',
      };
    } catch (error) {
      return {
        'success': false,
        'message':
            'ไม่สามารถเชื่อมต่อ Server ได้',
      };
    }
  }
}