import 'dart:convert';

import 'package:http/http.dart'
    as http;

import '../config/api_config.dart';
import '../models/user_event.dart';
import '../models/user_history.dart';

import 'auth_service.dart';

class UserEventService {
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
  // GET Events
  // =========================================================

  static Future<
      Map<String, dynamic>>
      getEvents({
    String search = '',
    String status = 'all',
  }) async {
    try {
      final queryParameters =
          <String, String>{};

      if (search.trim().isNotEmpty) {
        queryParameters['search'] =
            search.trim();
      }

      if (status != 'all') {
        queryParameters['status'] =
            status;
      }

      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/events',
      ).replace(
        queryParameters:
            queryParameters.isEmpty
                ? null
                : queryParameters,
      );

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

      if (response.statusCode == 200 &&
          data['success'] == true) {
        final rawEvents =
            data['events']
                as List<dynamic>? ??
            [];

        final events =
            rawEvents
                .map(
                  (item) =>
                      UserEvent.fromJson(
                    item as Map<
                        String,
                        dynamic>,
                  ),
                )
                .toList();

        return {
          'success': true,
          'events': events,
          'total': events.length,
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
// GET EVENT DETAIL
// =========================================================

static Future<Map<String, dynamic>>
    getEventDetail(
  int eventId,
) async {
  try {
    final response =
        await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/events/$eventId',
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

        'event':
            UserEvent.fromJson(
          data['event']
              as Map<String, dynamic>,
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
// REGISTER EVENT
// =========================================================

static Future<Map<String, dynamic>>
    registerEvent(
  int eventId,
) async {
  try {
    final response =
        await http.post(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/events/$eventId/register',
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
              'ไม่สามารถลงทะเบียนกิจกรรมได้',
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
// CHECK-IN
// =========================================================

static Future<Map<String, dynamic>>
    checkIn({
  required int eventId,
  required double latitude,
  required double longitude,
}) async {
  try {
    final response =
        await http.post(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/events/$eventId/checkin',
      ),

      headers:
          await _headers(),

      body:
          jsonEncode({
        'latitude':
            latitude,

        'longitude':
            longitude,
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
              'ไม่สามารถเช็กอินได้',

      'distance_meters':
          data['distance_meters'] ??
              data['checkin']
                  ?['distance_meters'],

      'allowed_radius':
          data['allowed_radius'] ??
              data['checkin']
                  ?['allowed_radius'],
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
// MY EVENT HISTORY
// =========================================================

static Future<Map<String, dynamic>>
    getHistory() async {
  try {
    final response =
        await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/events/history',
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
      final rawHistory =
          data['history']
              as List<dynamic>? ??
          [];

      final history =
          rawHistory.map(
        (item) {
          return UserHistoryItem
              .fromJson(
            item as Map<String, dynamic>,
          );
        },
      ).toList();

      return {
        'success': true,
        'history': history,
      };
    }

    return {
      'success': false,

      'message':
          data['message'] ??
              'ไม่สามารถโหลดประวัติได้',
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
// CHECK-IN CENTER
// =========================================================

static Future<Map<String, dynamic>>
    getCheckinCenter() async {
  try {
    final response =
        await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/events/checkin-center',
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
      final rawEvents =
          data['events']
              as List<dynamic>? ??
          [];

      final events =
          rawEvents.map(
        (item) {
          return UserEvent.fromJson(
            item as Map<String, dynamic>,
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
              'ไม่สามารถโหลดข้อมูลเช็กอินได้',
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