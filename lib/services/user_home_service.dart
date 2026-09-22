import 'dart:convert';

import 'package:http/http.dart'
    as http;

import '../config/api_config.dart';
import '../models/user_home.dart';

import 'auth_service.dart';

class UserHomeService {
  static Future<
      Map<String, String>>
      _headers() async {
    final token =
        await AuthService.getToken();

    return {
      'Accept':
          'application/json',

      'Content-Type':
          'application/json',

      if (token != null)
        'Authorization':
            'Bearer $token',
    };
  }

  static Future<
      Map<String, dynamic>>
      getHome() async {
    try {
      final response =
          await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/api/home',
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

          'home':
              UserHomeData.fromJson(
            data,
          ),
        };
      }

      return {
        'success':
            false,

        'message':
            data['message'] ??
                'ไม่สามารถโหลดหน้าหลักได้',
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