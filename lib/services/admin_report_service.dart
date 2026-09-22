import 'dart:convert';

import 'package:http/http.dart'
    as http;

import '../config/api_config.dart';
import '../models/admin_report.dart';

import 'auth_service.dart';

class AdminReportService {
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
  // Get Report
  // =========================================================

  static Future<
      Map<String, dynamic>>
      getReport() async {
    try {
      final response =
          await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/api/admin/reports/summary',
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

          'report':
              AdminReport.fromJson(
            data,
          ),
        };
      }

      return {
        'success': false,

        'message':
            data['message'] ??
                'ไม่สามารถโหลดรายงานได้',
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