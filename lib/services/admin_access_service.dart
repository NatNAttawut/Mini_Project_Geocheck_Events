import 'dart:convert';

import 'package:http/http.dart'
    as http;

import '../config/api_config.dart';
import '../models/access_account.dart';

import 'auth_service.dart';

class AdminAccessService {
  static Future<
      Map<String, String>>
      _headers() async {
    final token =
        await AuthService.getToken();

    return {
      'Content-Type':
          'application/json',

      'Accept':
          'application/json',

      if (token != null)
        'Authorization':
            'Bearer $token',
    };
  }

  // =========================================================
  // GET
  // =========================================================

  static Future<
      Map<String, dynamic>>
      getAccounts() async {
    try {
      final response =
          await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/api/admin/access',
        ),

        headers:
            await _headers(),
      );

      final data =
          jsonDecode(
        response.body,
      ) as Map<String, dynamic>;

      if (
          response.statusCode ==
                  200 &&
              data['success'] ==
                  true) {
        final list =
            data['accounts']
                    as List<dynamic>? ??
                [];

        return {
          'success': true,

          'accounts':
              list
                  .map(
                    (item) =>
                        AccessAccount
                            .fromJson(
                      item as Map<
                          String,
                          dynamic>,
                    ),
                  )
                  .toList(),
        };
      }

      return {
        'success': false,

        'message':
            data['message'] ??
                'ไม่สามารถโหลดข้อมูลสิทธิ์ได้',
      };
    } catch (_) {
      return {
        'success': false,

        'message':
            'ไม่สามารถเชื่อมต่อ Server ได้',
      };
    }
  }

  // =========================================================
  // CREATE ADMIN
  // =========================================================

  static Future<
      Map<String, dynamic>>
      createAdmin({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
  }) async {
    try {
      final response =
          await http.post(
        Uri.parse(
          '${ApiConfig.baseUrl}/api/admin/access/admins',
        ),

        headers:
            await _headers(),

        body:
            jsonEncode({
          'firstname':
              firstname,

          'lastname':
              lastname,

          'email':
              email,

          'password':
              password,
        }),
      );

      final data =
          jsonDecode(
        response.body,
      ) as Map<String, dynamic>;

      return {
        'success':
            response.statusCode ==
                    201 &&
                data['success'] ==
                    true,

        'message':
            data['message'] ??
                'ไม่สามารถเพิ่ม Admin ได้',
      };
    } catch (_) {
      return {
        'success': false,
        'message':
            'ไม่สามารถเชื่อมต่อ Server ได้',
      };
    }
  }

  // =========================================================
  // CHANGE ROLE
  // =========================================================

  static Future<
      Map<String, dynamic>>
      changeRole({
    required int userId,
    required String role,
  }) async {
    try {
      final response =
          await http.patch(
        Uri.parse(
          '${ApiConfig.baseUrl}/api/admin/access/$userId/role',
        ),

        headers:
            await _headers(),

        body:
            jsonEncode({
          'role':
              role,
        }),
      );

      final data =
          jsonDecode(
        response.body,
      ) as Map<String, dynamic>;

      return {
        'success':
            response.statusCode ==
                    200 &&
                data['success'] ==
                    true,

        'message':
            data['message'] ??
                'ไม่สามารถเปลี่ยนสิทธิ์ได้',
      };
    } catch (_) {
      return {
        'success': false,

        'message':
            'ไม่สามารถเชื่อมต่อ Server ได้',
      };
    }
  }
}