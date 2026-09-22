import 'dart:convert';

import 'package:http/http.dart'
    as http;

import '../config/api_config.dart';
import '../models/admin_dashboard.dart';

import 'auth_service.dart';

class AdminDashboardService {
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
  // Dashboard
  // =========================================================

  static Future<
      Map<String, dynamic>>
      getDashboard() async {
    try {
      final response =
          await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/api/admin/dashboard',
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
          'success': true,

          'dashboard':
              AdminDashboard.fromJson(
            data,
          ),
        };
      }

      return {
        'success': false,

        'message':
            data['message'] ??
                'ไม่สามารถโหลด Dashboard ได้',
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