import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';

class AuthService {
  // =========================================================
  // Login
  // =========================================================

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/auth/login');

    try {
      debugPrint('====================================');
      debugPrint('LOGIN API');
      debugPrint('URL: $url');
      debugPrint('EMAIL: ${email.trim()}');
      debugPrint('====================================');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'email': email.trim(), 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('LOGIN STATUS: ${response.statusCode}');

      // =====================================================
      // แปลง JSON ที่ Server ส่งกลับ
      // =====================================================

      Map<String, dynamic> data;

      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (error) {
        debugPrint('JSON DECODE ERROR: $error');

        debugPrint('SERVER RESPONSE: ${response.body}');

        return {
          'success': false,
          'message': 'Server ส่งข้อมูลกลับมาในรูปแบบไม่ถูกต้อง',
        };
      }

      // =====================================================
      // Login สำเร็จ
      // =====================================================

      if (response.statusCode == 200 && data['success'] == true) {
        final token = data['token'];
        final user = data['user'];

        if (token == null || token.toString().isEmpty) {
          return {
            'success': false,
            'message': 'เข้าสู่ระบบสำเร็จ แต่ไม่ได้รับ JWT Token',
          };
        }

        // ---------------------------------------------------
        // เก็บ JWT ไว้ในเครื่อง
        // ---------------------------------------------------

        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('auth_token', token.toString());

        // ---------------------------------------------------
        // เก็บข้อมูล User บางส่วนไว้ใช้ภายหลัง
        // ---------------------------------------------------

        if (user is Map<String, dynamic>) {
          if (user['id'] != null) {
            await prefs.setInt('user_id', int.parse(user['id'].toString()));
          }

          if (user['email'] != null) {
            await prefs.setString('user_email', user['email'].toString());
          }

          if (user['role'] != null) {
            await prefs.setString('user_role', user['role'].toString());
          }

          if (user['firstname'] != null) {
            await prefs.setString(
              'user_firstname',
              user['firstname'].toString(),
            );
          }

          if (user['lastname'] != null) {
            await prefs.setString('user_lastname', user['lastname'].toString());
          }
        }

        debugPrint('LOGIN SUCCESS');
        debugPrint('ROLE: ${user?['role']}');

        return {
          'success': true,
          'message': data['message'] ?? 'เข้าสู่ระบบสำเร็จ',
          'token': token,
          'user': user,
        };
      }

      // =====================================================
      // Login ไม่สำเร็จ
      // เช่น 400 / 401 / 403
      // =====================================================

      debugPrint('LOGIN FAILED: ${data['message']}');

      return {
        'success': false,
        'message': data['message'] ?? 'อีเมลหรือรหัสผ่านไม่ถูกต้อง',
      };
    }
    // =======================================================
    // Timeout
    // =======================================================
    on TimeoutException catch (error) {
      debugPrint('LOGIN TIMEOUT: $error');

      return {'success': false, 'message': 'Server ใช้เวลาตอบกลับนานเกินไป'};
    }
    // =======================================================
    // เชื่อมต่อ Server ไม่ได้
    // =======================================================
    on http.ClientException catch (error) {
      debugPrint('LOGIN CLIENT ERROR: $error');

      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ Server ได้'};
    }
    // =======================================================
    // Error อื่น ๆ
    // =======================================================
    catch (error, stackTrace) {
      debugPrint('LOGIN API ERROR: $error');

      debugPrint('STACK TRACE: $stackTrace');

      return {'success': false, 'message': 'ไม่สามารถเชื่อมต่อ Server ได้'};
    }
  }

  // =========================================================
  // Get Token
  // =========================================================

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('auth_token');
  }

  // =========================================================
  // Get User Role
  // =========================================================

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString('user_role');
  }

  // =========================================================
  // Get User Name
  // =========================================================

  static Future<String> getFullName() async {
    final prefs = await SharedPreferences.getInstance();

    final firstname = prefs.getString('user_firstname') ?? '';

    final lastname = prefs.getString('user_lastname') ?? '';

    return '$firstname $lastname'.trim();
  }

  // =========================================================
  // Check Login
  // =========================================================

  static Future<bool> isLoggedIn() async {
    final token = await getToken();

    return token != null && token.isNotEmpty;
  }

  // =========================================================
  // Logout
  // =========================================================

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('user_email');
    await prefs.remove('user_role');
    await prefs.remove('user_firstname');
    await prefs.remove('user_lastname');

    debugPrint('LOGOUT SUCCESS');
  }

  static Future<Map<String, dynamic>> register({
  required String firstname,
  required String lastname,
  required String studentId,
  required String email,
  required String password,
}) async {
  try {
    final response = await http.post(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/auth/register',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'firstname': firstname.trim(),
        'lastname': lastname.trim(),
        'student_id': studentId.trim(),
        'email': email.trim(),
        'password': password,
      }),
    );

    final data =
        jsonDecode(response.body)
            as Map<String, dynamic>;

    if ((response.statusCode == 200 ||
            response.statusCode == 201) &&
        data['success'] == true) {
      return {
        'success': true,
        'message':
            data['message'] ??
                'สร้างบัญชีเรียบร้อยแล้ว',
        'user': data['user'],
      };
    }

    return {
      'success': false,
      'message':
          data['message'] ??
              'ไม่สามารถสร้างบัญชีได้',
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
