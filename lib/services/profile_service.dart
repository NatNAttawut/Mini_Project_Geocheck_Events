import 'dart:convert';

import 'package:http/http.dart'
    as http;

import '../config/api_config.dart';
import '../models/user_profile.dart';

import 'auth_service.dart';

class ProfileService {
  // =========================================================
  // Headers
  // =========================================================

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
  // GET PROFILE
  // =========================================================

  static Future<
      Map<String, dynamic>>
      getProfile() async {
    try {
      final response =
          await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/api/profile',
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
        return {
          'success':
              true,

          'profile':
              UserProfile.fromJson(
            data['user']
                as Map<String, dynamic>,
          ),
        };
      }

      return {
        'success':
            false,

        'message':
            data['message'] ??
                'ไม่สามารถโหลดโปรไฟล์ได้',
      };
    } catch (error) {
      return {
        'success':
            false,

        'message':
            'ไม่สามารถเชื่อมต่อ Server ได้',
      };
    }
  }

  // =========================================================
  // UPDATE PROFILE
  // =========================================================

  static Future<
      Map<String, dynamic>>
      updateProfile({
    required String firstname,
    required String lastname,
    String? studentId,
  }) async {
    try {
      final response =
          await http.put(
        Uri.parse(
          '${ApiConfig.baseUrl}/api/profile',
        ),

        headers:
            await _headers(),

        body:
            jsonEncode({
          'firstname':
              firstname,

          'lastname':
              lastname,

          'student_id':
              studentId,
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
                'ไม่สามารถแก้ไขโปรไฟล์ได้',
      };
    } catch (error) {
      return {
        'success':
            false,

        'message':
            'ไม่สามารถเชื่อมต่อ Server ได้',
      };
    }
  }

  // =========================================================
  // CHANGE PASSWORD
  // =========================================================

  static Future<
      Map<String, dynamic>>
      changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response =
          await http.put(
        Uri.parse(
          '${ApiConfig.baseUrl}/api/profile/password',
        ),

        headers:
            await _headers(),

        body:
            jsonEncode({
          'current_password':
              currentPassword,

          'new_password':
              newPassword,

          'confirm_password':
              confirmPassword,
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
                'ไม่สามารถเปลี่ยนรหัสผ่านได้',
      };
    } catch (error) {
      return {
        'success':
            false,

        'message':
            'ไม่สามารถเชื่อมต่อ Server ได้',
      };
    }
  }
}