import 'dart:convert';

import 'package:http/http.dart'
    as http;

import '../config/api_config.dart';
import '../models/admin_event.dart';
import 'auth_service.dart';
import '../models/admin_event_detail.dart';

class AdminEventService {
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
  // GET EVENTS
  // =========================================================

  static Future<
      Map<String, dynamic>>
      getEvents({
    String search = '',
    String status = 'all',
  }) async {
    try {
      final parameters =
          <String, String>{};

      if (
          search.trim().isNotEmpty) {
        parameters['search'] =
            search.trim();
      }

      if (status != 'all') {
        parameters['status'] =
            status;
      }

      var uri =
          Uri.parse(
        '${ApiConfig.baseUrl}/api/admin/events',
      );

      if (
          parameters.isNotEmpty) {
        uri = uri.replace(
          queryParameters:
              parameters,
        );
      }

      final response =
          await http.get(
        uri,
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
        final List<dynamic>
            rawEvents =
            data['events'] ?? [];

        final events =
            rawEvents.map(
          (item) {
            return AdminEvent
                .fromJson(
              item as Map<String,
                  dynamic>,
            );
          },
        ).toList();

        return {
          'success': true,
          'events': events,
        };
      }

      return {
        'success': false,
        'message':
            data['message'] ??
                'ไม่สามารถโหลดกิจกรรมได้',
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
  // CREATE
  // =========================================================

  static Future<
      Map<String, dynamic>>
      createEvent(
    Map<String, dynamic>
        eventData,
  ) async {
    try {
      final response =
          await http.post(
        Uri.parse(
          '${ApiConfig.baseUrl}/api/admin/events',
        ),
        headers:
            await _headers(),
        body:
            jsonEncode(
          eventData,
        ),
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
                'ไม่สามารถสร้างกิจกรรมได้',
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
  // UPDATE
  // =========================================================

  static Future<
      Map<String, dynamic>>
      updateEvent({
    required int id,
    required Map<String, dynamic>
        eventData,
  }) async {
    try {
      final response =
          await http.put(
        Uri.parse(
          '${ApiConfig.baseUrl}/api/admin/events/$id',
        ),
        headers:
            await _headers(),
        body:
            jsonEncode(
          eventData,
        ),
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
                'ไม่สามารถแก้ไขกิจกรรมได้',
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
// GET EVENT DETAIL
// =========================================================

static Future<Map<String, dynamic>>
    getEventDetail(
  int id,
) async {
  try {
    final response =
        await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/admin/events/$id/detail',
      ),
      headers:
          await _headers(),
    );

    final data =
        jsonDecode(
      response.body,
    ) as Map<String, dynamic>;

    if (response.statusCode == 200 &&
        data['success'] == true) {
      return {
        'success': true,

        'detail':
            AdminEventDetail.fromJson(
          data,
        ),
      };
    }

    return {
      'success': false,

      'message':
          data['message'] ??
              'ไม่สามารถโหลดรายละเอียดกิจกรรมได้',
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
  // DELETE
  // =========================================================

  static Future<
      Map<String, dynamic>>
      deleteEvent(
    int id,
  ) async {
    try {
      final response =
          await http.delete(
        Uri.parse(
          '${ApiConfig.baseUrl}/api/admin/events/$id',
        ),
        headers:
            await _headers(),
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
                'ไม่สามารถลบกิจกรรมได้',
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