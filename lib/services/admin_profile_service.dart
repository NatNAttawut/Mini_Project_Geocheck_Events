import 'dart:convert';

import 'package:http/http.dart'
    as http;

import '../config/api_config.dart';
import '../models/admin_profile.dart';

import 'auth_service.dart';

class AdminProfileService {
  // =========================================================
  // Headers
  // =========================================================

  static Future<Map<String, String>>
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
  // GET ADMIN PROFILE
  // =========================================================

  static Future<Map<String, dynamic>>
      getProfile() async {
    try {
      final headers =
          await _headers();

      // ดึงข้อมูล Admin
      final profileResponse =
          await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/api/profile',
        ),
        headers: headers,
      );

      // ดึง Summary ของระบบ
      final dashboardResponse =
          await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/api/admin/dashboard',
        ),
        headers: headers,
      );

      final profileData =
          jsonDecode(
        profileResponse.body,
      ) as Map<String, dynamic>;

      final dashboardData =
          jsonDecode(
        dashboardResponse.body,
      ) as Map<String, dynamic>;

      if (profileResponse.statusCode !=
              200 ||
          profileData['success'] !=
              true) {
        return {
          'success': false,
          'message':
              profileData['message'] ??
                  'ไม่สามารถโหลดข้อมูลผู้ดูแลระบบได้',
        };
      }

      if (dashboardResponse.statusCode !=
              200 ||
          dashboardData['success'] !=
              true) {
        return {
          'success': false,
          'message':
              dashboardData['message'] ??
                  'ไม่สามารถโหลดข้อมูลระบบได้',
        };
      }

      final user =
          profileData['user']
              as Map<String, dynamic>;

      final summary =
          dashboardData['summary']
                  as Map<String, dynamic>? ??
              {};

      final profile =
          AdminProfile(
        id:
            int.tryParse(
              user['id'].toString(),
            ) ??
            0,

        firstname:
            user['firstname']
                    ?.toString() ??
                '',

        lastname:
            user['lastname']
                    ?.toString() ??
                '',

        email:
            user['email']
                    ?.toString() ??
                '',

        role:
            user['role']
                    ?.toString() ??
                'admin',

        totalUsers:
            int.tryParse(
              summary['total_users']
                  .toString(),
            ) ??
            0,

        totalEvents:
            int.tryParse(
              summary['total_events']
                  .toString(),
            ) ??
            0,

        openEvents:
            int.tryParse(
              summary['open_events']
                  .toString(),
            ) ??
            0,

        todayCheckins:
            int.tryParse(
              summary['today_checkins']
                  .toString(),
            ) ??
            0,
      );

      return {
        'success': true,
        'profile': profile,
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
  // UPDATE ADMIN PROFILE
  // =========================================================

  static Future<Map<String, dynamic>>
      updateProfile({
    required String firstname,
    required String lastname,
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
              firstname.trim(),

          'lastname':
              lastname.trim(),

          // Admin ไม่มี student id
          'student_id':
              null,
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
                'ไม่สามารถแก้ไขข้อมูลได้',
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
  // CHANGE PASSWORD
  // =========================================================

  static Future<Map<String, dynamic>>
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
        'success': false,
        'message':
            'ไม่สามารถเชื่อมต่อ Server ได้',
      };
    }
  }
}