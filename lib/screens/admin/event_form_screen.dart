import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../models/admin_event.dart';
import '../../services/admin_event_service.dart';

class EventFormScreen extends StatefulWidget {
  final AdminEvent? event;

  const EventFormScreen({
    super.key,
    this.event,
  });

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  // =========================================================
  // Colors
  // =========================================================

  static const Color backgroundColor = Color(0xFF080D13);
  static const Color cardColor = Color(0xFF101720);
  static const Color fieldColor = Color(0xFF151E28);
  static const Color borderColor = Color(0xFF26313D);
  static const Color primaryColor = Color(0xFFB7F52B);
  static const Color textPrimary = Color(0xFFF3F5F7);
  static const Color textSecondary = Color(0xFF8B98A5);
  static const Color dangerColor = Color(0xFFFF6262);

  // =========================================================
  // Form
  // =========================================================

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late TextEditingController _radiusController;
  late TextEditingController _maxParticipantsController;

  DateTime? _startAt;
  DateTime? _endAt;
  DateTime? _checkinStartAt;
  DateTime? _checkinEndAt;

  String _status = 'draft';
  bool _isLoading = false;

  bool get _isEditing => widget.event != null;

  // =========================================================
  // Map Preview
  // =========================================================

  final MapController _mapController = MapController();
  bool _mapReady = false;

  LatLng? get _previewPoint {
    final latitude = double.tryParse(
      _latitudeController.text.trim(),
    );

    final longitude = double.tryParse(
      _longitudeController.text.trim(),
    );

    if (latitude == null ||
        longitude == null ||
        latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      return null;
    }

    return LatLng(latitude, longitude);
  }

  double get _previewRadius {
    final radius = double.tryParse(
      _radiusController.text.trim(),
    );

    if (radius == null || radius <= 0) {
      return 100;
    }

    return radius;
  }

  // =========================================================
  // Status
  // =========================================================

  final Map<String, String> _statusLabels = const {
    'draft': 'แบบร่าง',
    'open': 'เปิดรับสมัคร',
    'closed': 'ปิดรับสมัคร',
    'completed': 'เสร็จสิ้น',
    'cancelled': 'ยกเลิก',
  };

  // =========================================================
  // Init
  // =========================================================

  @override
  void initState() {
    super.initState();

    final event = widget.event;

    _titleController = TextEditingController(
      text: event?.title ?? '',
    );

    _descriptionController = TextEditingController(
      text: event?.description ?? '',
    );

    _locationController = TextEditingController(
      text: event?.locationName ?? '',
    );

    _latitudeController = TextEditingController(
      text: event == null ? '' : event.latitude.toString(),
    );

    _longitudeController = TextEditingController(
      text: event == null ? '' : event.longitude.toString(),
    );

    _radiusController = TextEditingController(
      text: event == null ? '100' : event.checkinRadius.toString(),
    );

    _maxParticipantsController = TextEditingController(
      text: event?.maxParticipants?.toString() ?? '',
    );

    if (event != null) {
      _startAt = event.startAt.toLocal();
      _endAt = event.endAt.toLocal();
      _checkinStartAt = event.checkinStartAt?.toLocal();
      _checkinEndAt = event.checkinEndAt?.toLocal();
      _status = event.status;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _radiusController.dispose();
    _maxParticipantsController.dispose();
    _mapController.dispose();

    super.dispose();
  }

  // =========================================================
  // Map Helpers
  // =========================================================

  void _updateMapPreview() {
    if (!mounted) {
      return;
    }

    setState(() {});

    final point = _previewPoint;

    if (!_mapReady || point == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_mapReady) {
        return;
      }

      final latestPoint = _previewPoint;

      if (latestPoint == null) {
        return;
      }

      _fitMapToRadius(
        latestPoint,
        _previewRadius,
      );
    });
  }

  void _fitMapToRadius(
    LatLng center,
    double radiusMeters,
  ) {
    if (!_mapReady) {
      return;
    }

    final safeRadius = radiusMeters.clamp(10.0, 50000.0).toDouble();

    // 1 degree latitude is approximately 111.32 km.
    final latDelta = safeRadius / 111320.0;

    // Longitude distance changes depending on latitude.
    final latitudeRadians = center.latitude * math.pi / 180.0;
    final cosLatitude = math.cos(latitudeRadians).abs().clamp(0.20, 1.0);
    final lngDelta = safeRadius / (111320.0 * cosLatitude);

    // Give the circle some space around the edge of the map.
    const extraSpace = 1.45;

    final south = (center.latitude - (latDelta * extraSpace))
        .clamp(-85.0, 85.0)
        .toDouble();

    final north = (center.latitude + (latDelta * extraSpace))
        .clamp(-85.0, 85.0)
        .toDouble();

    final west = (center.longitude - (lngDelta * extraSpace))
        .clamp(-180.0, 180.0)
        .toDouble();

    final east = (center.longitude + (lngDelta * extraSpace))
        .clamp(-180.0, 180.0)
        .toDouble();

    final bounds = LatLngBounds(
      LatLng(south, west),
      LatLng(north, east),
    );

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(38),
        minZoom: 3,
        maxZoom: 19,
      ),
    );
  }

  // =========================================================
  // Select Date + Time
  // =========================================================

  Future<DateTime?> _pickDateTime(
    DateTime? current,
  ) async {
    final now = DateTime.now();
    final initialDate = current ?? now;

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: primaryColor,
              surface: cardColor,
              onSurface: textPrimary,
              onPrimary: backgroundColor,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: cardColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date == null) {
      return null;
    }

    if (!mounted) {
      return null;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        current ?? now,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: primaryColor,
              surface: cardColor,
              onSurface: textPrimary,
              onPrimary: backgroundColor,
            ),
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: cardColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time == null) {
      return null;
    }

    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  // =========================================================
  // Submit
  // =========================================================

  Future<void> _submit() async {
    if (_isLoading) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startAt == null) {
      _showMessage(
        'กรุณาเลือกวันเวลาเริ่มกิจกรรม',
        error: true,
      );
      return;
    }

    if (_endAt == null) {
      _showMessage(
        'กรุณาเลือกวันเวลาสิ้นสุดกิจกรรม',
        error: true,
      );
      return;
    }

    if (!_endAt!.isAfter(_startAt!)) {
      _showMessage(
        'เวลาสิ้นสุดต้องอยู่หลังเวลาเริ่มกิจกรรม',
        error: true,
      );
      return;
    }

    final hasCheckinStart = _checkinStartAt != null;
    final hasCheckinEnd = _checkinEndAt != null;

    if (hasCheckinStart != hasCheckinEnd) {
      _showMessage(
        'กรุณากำหนดเวลาเปิดและปิดเช็กอินให้ครบ',
        error: true,
      );
      return;
    }

    if (_checkinStartAt != null &&
        _checkinEndAt != null &&
        !_checkinEndAt!.isAfter(_checkinStartAt!)) {
      _showMessage(
        'เวลาปิดเช็กอินต้องอยู่หลังเวลาเปิดเช็กอิน',
        error: true,
      );
      return;
    }

    final latitude = double.tryParse(
      _latitudeController.text.trim(),
    );

    final longitude = double.tryParse(
      _longitudeController.text.trim(),
    );

    final radius = int.tryParse(
      _radiusController.text.trim(),
    );

    final maxParticipants = _maxParticipantsController.text.trim().isEmpty
        ? null
        : int.tryParse(
            _maxParticipantsController.text.trim(),
          );

    if (latitude == null || latitude < -90 || latitude > 90) {
      _showMessage(
        'Latitude ต้องอยู่ระหว่าง -90 ถึง 90',
        error: true,
      );
      return;
    }

    if (longitude == null || longitude < -180 || longitude > 180) {
      _showMessage(
        'Longitude ต้องอยู่ระหว่าง -180 ถึง 180',
        error: true,
      );
      return;
    }

    if (radius == null || radius <= 0) {
      _showMessage(
        'รัศมีเช็กอินต้องมากกว่า 0 เมตร',
        error: true,
      );
      return;
    }

    if (_maxParticipantsController.text.trim().isNotEmpty &&
        (maxParticipants == null || maxParticipants <= 0)) {
      _showMessage(
        'จำนวนผู้เข้าร่วมต้องมากกว่า 0',
        error: true,
      );
      return;
    }

    final data = <String, dynamic>{
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      'location_name': _locationController.text.trim(),
      'latitude': latitude,
      'longitude': longitude,
      'checkin_radius': radius,
      'start_at': _startAt!.toIso8601String(),
      'end_at': _endAt!.toIso8601String(),
      'checkin_start_at': _checkinStartAt?.toIso8601String(),
      'checkin_end_at': _checkinEndAt?.toIso8601String(),
      'max_participants': maxParticipants,
      'status': _status,
    };

    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> result;

    if (_isEditing) {
      result = await AdminEventService.updateEvent(
        id: widget.event!.id,
        eventData: data,
      );
    } else {
      result = await AdminEventService.createEvent(
        data,
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      _showMessage(
        result['message'] ?? 'บันทึกกิจกรรมเรียบร้อยแล้ว',
      );

      await Future.delayed(
        const Duration(milliseconds: 300),
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(
        context,
        true,
      );
      return;
    }

    _showMessage(
      result['message'] ?? 'ไม่สามารถบันทึกกิจกรรมได้',
      error: true,
    );
  }

  // =========================================================
  // Message
  // =========================================================

  void _showMessage(
    String message, {
    bool error = false,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error
            ? const Color(0xFFD94A4A)
            : const Color(0xFF253512),
      ),
    );
  }

  // =========================================================
  // Build
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: _isLoading
              ? null
              : () {
                  Navigator.pop(context);
                },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textPrimary,
            size: 20,
          ),
        ),
        title: Text(
          _isEditing ? 'แก้ไขกิจกรรม' : 'สร้างกิจกรรม',
          style: const TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),

                // =====================================================
                // General
                // =====================================================

                _sectionTitle(
                  icon: Icons.event_note_rounded,
                  title: 'ข้อมูลกิจกรรม',
                  subtitle: 'ข้อมูลพื้นฐานของกิจกรรม',
                ),
                const SizedBox(height: 12),
                _card(
                  children: [
                    _textField(
                      controller: _titleController,
                      label: 'ชื่อกิจกรรม',
                      hint: 'เช่น กิจกรรมปฐมนิเทศนักศึกษา',
                      icon: Icons.campaign_outlined,
                      requiredField: true,
                    ),
                    const SizedBox(height: 14),
                    _textField(
                      controller: _descriptionController,
                      label: 'รายละเอียด',
                      hint: 'รายละเอียดกิจกรรม...',
                      icon: Icons.notes_rounded,
                      maxLines: 4,
                      requiredField: false,
                    ),
                    const SizedBox(height: 14),
                    _textField(
                      controller: _locationController,
                      label: 'สถานที่',
                      hint: 'เช่น อาคารเรียนรวม ชั้น 1',
                      icon: Icons.location_on_outlined,
                      requiredField: true,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // =====================================================
                // Check-in Location
                // =====================================================

                _sectionTitle(
                  icon: Icons.my_location_rounded,
                  title: 'ตำแหน่งเช็กอิน',
                  subtitle: 'กำหนดจุดและรัศมีที่อนุญาตให้เช็กอิน',
                ),
                const SizedBox(height: 12),
                _card(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _numberField(
                            controller: _latitudeController,
                            label: 'Latitude',
                            hint: '18.7883',
                            icon: Icons.north_rounded,
                            decimal: true,
                            onChanged: (_) {
                              _updateMapPreview();
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _numberField(
                            controller: _longitudeController,
                            label: 'Longitude',
                            hint: '98.9853',
                            icon: Icons.east_rounded,
                            decimal: true,
                            onChanged: (_) {
                              _updateMapPreview();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _numberField(
                      controller: _radiusController,
                      label: 'รัศมีเช็กอิน (เมตร)',
                      hint: '100',
                      icon: Icons.radar_rounded,
                      onChanged: (_) {
                        _updateMapPreview();
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildCheckinMap(),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.12),
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: primaryColor,
                            size: 17,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'วงกลมบนแผนที่แสดงพื้นที่เช็กอินจริงตามรัศมีที่กำหนด ผู้ใช้ต้องอยู่ภายในพื้นที่นี้จึงจะเช็กอินได้',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 10,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // =====================================================
                // Event Date Time
                // =====================================================

                _sectionTitle(
                  icon: Icons.schedule_rounded,
                  title: 'วันเวลากิจกรรม',
                  subtitle: 'กำหนดช่วงเวลาของกิจกรรม',
                ),
                const SizedBox(height: 12),
                _card(
                  children: [
                    _dateTimeButton(
                      label: 'เริ่มกิจกรรม',
                      value: _startAt,
                      icon: Icons.play_circle_outline_rounded,
                      onTap: () async {
                        final value = await _pickDateTime(
                          _startAt,
                        );

                        if (value != null) {
                          setState(() {
                            _startAt = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _dateTimeButton(
                      label: 'สิ้นสุดกิจกรรม',
                      value: _endAt,
                      icon: Icons.stop_circle_outlined,
                      onTap: () async {
                        final value = await _pickDateTime(
                          _endAt ?? _startAt,
                        );

                        if (value != null) {
                          setState(() {
                            _endAt = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // =====================================================
                // Check-in Time
                // =====================================================

                _sectionTitle(
                  icon: Icons.location_searching_rounded,
                  title: 'ช่วงเวลาเช็กอิน',
                  subtitle: 'ผู้ใช้จะเช็กอินได้เฉพาะช่วงเวลานี้',
                ),
                const SizedBox(height: 12),
                _card(
                  children: [
                    _dateTimeButton(
                      label: 'เปิดเช็กอิน',
                      value: _checkinStartAt,
                      icon: Icons.login_rounded,
                      allowClear: true,
                      onClear: () {
                        setState(() {
                          _checkinStartAt = null;
                        });
                      },
                      onTap: () async {
                        final value = await _pickDateTime(
                          _checkinStartAt ?? _startAt,
                        );

                        if (value != null) {
                          setState(() {
                            _checkinStartAt = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _dateTimeButton(
                      label: 'ปิดเช็กอิน',
                      value: _checkinEndAt,
                      icon: Icons.logout_rounded,
                      allowClear: true,
                      onClear: () {
                        setState(() {
                          _checkinEndAt = null;
                        });
                      },
                      onTap: () async {
                        final value = await _pickDateTime(
                          _checkinEndAt ?? _checkinStartAt ?? _startAt,
                        );

                        if (value != null) {
                          setState(() {
                            _checkinEndAt = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'หากไม่กำหนดช่วงเวลาเช็กอิน ผู้ใช้จะยังไม่สามารถใช้ระบบเช็กอินสำหรับกิจกรรมนี้ได้',
                      style: TextStyle(
                        color: Color(0xFF667380),
                        fontSize: 10,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // =====================================================
                // Participants
                // =====================================================

                _sectionTitle(
                  icon: Icons.groups_2_outlined,
                  title: 'ผู้เข้าร่วม',
                  subtitle: 'กำหนดจำนวนผู้เข้าร่วมสูงสุด',
                ),
                const SizedBox(height: 12),
                _card(
                  children: [
                    _numberField(
                      controller: _maxParticipantsController,
                      label: 'จำนวนผู้เข้าร่วมสูงสุด',
                      hint: 'ไม่จำกัด',
                      icon: Icons.groups_rounded,
                      requiredField: false,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'เว้นว่างหากไม่ต้องการจำกัดจำนวนผู้ลงทะเบียน',
                      style: TextStyle(
                        color: Color(0xFF667380),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // =====================================================
                // Status
                // =====================================================

                _sectionTitle(
                  icon: Icons.toggle_on_outlined,
                  title: 'สถานะกิจกรรม',
                  subtitle: 'กำหนดสถานะปัจจุบันของกิจกรรม',
                ),
                const SizedBox(height: 12),
                _card(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _status,
                      dropdownColor: cardColor,
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 13,
                      ),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: primaryColor,
                      ),
                      decoration: _inputDecoration(
                        label: 'สถานะ',
                        icon: Icons.flag_outlined,
                      ),
                      items: _statusLabels.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _status = value;
                        });
                      },
                    ),
                    const SizedBox(height: 13),
                    _statusDescription(),
                  ],
                ),
                const SizedBox(height: 30),

                // =====================================================
                // Save
                // =====================================================

                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: backgroundColor,
                      disabledBackgroundColor: primaryColor.withOpacity(0.45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: backgroundColor,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isEditing
                                    ? Icons.save_outlined
                                    : Icons.add_circle_outline_rounded,
                                size: 20,
                              ),
                              const SizedBox(width: 9),
                              Text(
                                _isEditing
                                    ? 'บันทึกการแก้ไข'
                                    : 'สร้างกิจกรรม',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // Map Preview
  // =========================================================

  Widget _buildCheckinMap() {
    final point = _previewPoint;
    final radius = _previewRadius;

    if (point == null) {
      return Container(
        height: 210,
        decoration: BoxDecoration(
          color: const Color(0xFF0C131A),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: borderColor,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.map_outlined,
                color: Color(0xFF667481),
                size: 36,
              ),
              SizedBox(height: 10),
              Text(
                'กรอก Latitude และ Longitude',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'เพื่อแสดงพื้นที่เช็กอินบนแผนที่',
                style: TextStyle(
                  color: Color(0xFF596673),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.map_rounded,
              color: primaryColor,
              size: 17,
            ),
            const SizedBox(width: 7),
            const Expanded(
              child: Text(
                'ตัวอย่างพื้นที่เช็กอิน',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: primaryColor.withOpacity(0.18),
                ),
              ),
              child: Text(
                'รัศมี ${radius.toStringAsFixed(0)} ม.',
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: 260,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: point,
                    initialZoom: 17,
                    minZoom: 3,
                    maxZoom: 20,
                    backgroundColor: const Color(0xFF101720),
                    onMapReady: () {
                      _mapReady = true;

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted || !_mapReady) {
                          return;
                        }

                        final latestPoint = _previewPoint;

                        if (latestPoint == null) {
                          return;
                        }

                        _fitMapToRadius(
                          latestPoint,
                          _previewRadius,
                        );
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.geocheck',
                    ),
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: point,
                          radius: radius,
                          useRadiusInMeter: true,
                          color: primaryColor.withOpacity(0.18),
                          borderColor: primaryColor,
                          borderStrokeWidth: 2,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: point,
                          width: 52,
                          height: 52,
                          child: Container(
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: backgroundColor,
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: backgroundColor,
                              size: 26,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution(
                          'OpenStreetMap contributors',
                        ),
                      ],
                    ),
                  ],
                ),

                // Re-center button
                Positioned(
                  right: 10,
                  top: 10,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        _fitMapToRadius(
                          point,
                          radius,
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xE6101720),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: borderColor,
                          ),
                        ),
                        child: const Icon(
                          Icons.center_focus_strong_rounded,
                          color: primaryColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 9),
        Row(
          children: [
            const Icon(
              Icons.my_location_rounded,
              color: textSecondary,
              size: 13,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${point.latitude.toStringAsFixed(6)}, '
                '${point.longitude.toStringAsFixed(6)}',
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 10,
                ),
              ),
            ),
            Text(
              'รัศมี ${radius.toStringAsFixed(0)} เมตร',
              style: const TextStyle(
                color: primaryColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // =========================================================
  // Header
  // =========================================================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryColor.withOpacity(0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 49,
            height: 49,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              _isEditing
                  ? Icons.edit_calendar_rounded
                  : Icons.event_available_rounded,
              color: backgroundColor,
              size: 25,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? 'แก้ไขข้อมูลกิจกรรม' : 'กิจกรรมใหม่',
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isEditing
                      ? 'ปรับปรุงข้อมูล เวลา และตำแหน่งเช็กอิน'
                      : 'กรอกข้อมูลเพื่อสร้างกิจกรรมใน GeoCheck',
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 10,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // Section
  // =========================================================

  Widget _sectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: primaryColor,
          size: 19,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _card({
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  // =========================================================
  // Text Field
  // =========================================================

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool requiredField = true,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        color: textPrimary,
        fontSize: 13,
      ),
      decoration: _inputDecoration(
        label: label,
        hint: hint,
        icon: icon,
      ),
      validator: (value) {
        if (requiredField &&
            (value == null || value.trim().isEmpty)) {
          return 'กรุณากรอก$label';
        }

        return null;
      },
    );
  }

  // =========================================================
  // Number Field
  // =========================================================

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool requiredField = true,
    bool decimal = false,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.numberWithOptions(
        decimal: decimal,
        signed: decimal,
      ),
      style: const TextStyle(
        color: textPrimary,
        fontSize: 13,
      ),
      decoration: _inputDecoration(
        label: label,
        hint: hint,
        icon: icon,
      ),
      validator: (value) {
        if (!requiredField &&
            (value == null || value.trim().isEmpty)) {
          return null;
        }

        if (value == null || value.trim().isEmpty) {
          return 'กรุณากรอก$label';
        }

        if (num.tryParse(value.trim()) == null) {
          return 'กรุณากรอกตัวเลข';
        }

        return null;
      },
    );
  }

  // =========================================================
  // Input Decoration
  // =========================================================

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(
        color: textSecondary,
        fontSize: 12,
      ),
      hintStyle: const TextStyle(
        color: Color(0xFF566370),
        fontSize: 11,
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF71808E),
        size: 19,
      ),
      filled: true,
      fillColor: fieldColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: borderColor,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: borderColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: primaryColor,
          width: 1.3,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: dangerColor,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: dangerColor,
        ),
      ),
      errorStyle: const TextStyle(
        color: dangerColor,
        fontSize: 10,
      ),
    );
  }

  // =========================================================
  // Date Time Button
  // =========================================================

  Widget _dateTimeButton({
    required String label,
    required DateTime? value,
    required IconData icon,
    required VoidCallback onTap,
    bool allowClear = false,
    VoidCallback? onClear,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: fieldColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: value == null
                ? borderColor
                : primaryColor.withOpacity(0.35),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                icon,
                color: primaryColor,
                size: 19,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: textSecondary,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value == null
                        ? 'แตะเพื่อเลือกวันและเวลา'
                        : _formatDateTime(value),
                    style: TextStyle(
                      color: value == null
                          ? const Color(0xFF63717F)
                          : textPrimary,
                      fontSize: 12,
                      fontWeight: value == null
                          ? FontWeight.w400
                          : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (allowClear && value != null)
              IconButton(
                onPressed: onClear,
                icon: const Icon(
                  Icons.close_rounded,
                  color: textSecondary,
                  size: 18,
                ),
              )
            else
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF667481),
              ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // Status Description
  // =========================================================

  Widget _statusDescription() {
    String description;
    IconData icon;

    switch (_status) {
      case 'open':
        description =
            'ผู้ใช้สามารถเห็นกิจกรรมและลงทะเบียนเข้าร่วมได้';
        icon = Icons.lock_open_rounded;
        break;

      case 'closed':
        description =
            'กิจกรรมยังแสดงอยู่ แต่ปิดรับการลงทะเบียนแล้ว';
        icon = Icons.lock_outline_rounded;
        break;

      case 'completed':
        description =
            'กิจกรรมสิ้นสุดแล้ว เหมาะสำหรับเก็บไว้ในประวัติ';
        icon = Icons.task_alt_rounded;
        break;

      case 'cancelled':
        description =
            'กิจกรรมถูกยกเลิก ผู้ใช้ไม่สามารถเข้าร่วมได้';
        icon = Icons.cancel_outlined;
        break;

      default:
        description =
            'กิจกรรมยังเป็นแบบร่าง และยังไม่เปิดให้ผู้ใช้ลงทะเบียน';
        icon = Icons.edit_note_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: primaryColor,
            size: 18,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                color: textSecondary,
                fontSize: 10,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // Date Format
  // =========================================================

  String _formatDateTime(
    DateTime date,
  ) {
    String two(int number) {
      return number.toString().padLeft(2, '0');
    }

    return '${two(date.day)}/${two(date.month)}/${date.year}  '
        '${two(date.hour)}:${two(date.minute)} น.';
  }
}
