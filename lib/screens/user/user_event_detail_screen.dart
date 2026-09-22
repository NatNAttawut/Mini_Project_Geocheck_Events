import 'package:flutter/material.dart';

import '../../models/user_event.dart';
import '../../services/user_event_service.dart';
import 'user_checkin_screen.dart';

class UserEventDetailScreen extends StatefulWidget {
  final int eventId;

  const UserEventDetailScreen({super.key, required this.eventId});

  @override
  State<UserEventDetailScreen> createState() => _UserEventDetailScreenState();
}

class _UserEventDetailScreenState extends State<UserEventDetailScreen> {
  static const Color backgroundColor = Color(0xFF080D13);

  static const Color cardColor = Color(0xFF101720);

  static const Color borderColor = Color(0xFF26313D);

  static const Color primaryColor = Color(0xFFB7F52B);

  static const Color textPrimary = Color(0xFFF3F5F7);

  static const Color textSecondary = Color(0xFF8B98A5);

  static const Color warningColor = Color(0xFFFFB74D);

  UserEvent? _event;

  bool _isLoading = true;
  bool _isRegistering = false;

  bool _isCheckinTime(UserEvent event) {
    if (event.checkinStartAt == null || event.checkinEndAt == null) {
      return false;
    }

    final now = DateTime.now();

    debugPrint('NOW              : $now');
    debugPrint('CHECKIN START    : ${event.checkinStartAt}');
    debugPrint('CHECKIN END      : ${event.checkinEndAt}');

    return !now.isBefore(event.checkinStartAt!) &&
        !now.isAfter(event.checkinEndAt!);
  }

  @override
  void initState() {
    super.initState();

    _loadEvent();
  }

  // =========================================================
  // Load Detail
  // =========================================================

  Future<void> _loadEvent({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    final result = await UserEventService.getEventDetail(widget.eventId);

    if (!mounted) {
      return;
    }

    if (result['success'] == true) {
      setState(() {
        _event = result['event'] as UserEvent;

        _isLoading = false;
      });

      return;
    }

    setState(() {
      _isLoading = false;
    });

    _showMessage(result['message'] ?? 'โหลดข้อมูลไม่สำเร็จ', error: true);
  }

  // =========================================================
  // Register
  // =========================================================

  Future<void> _register() async {
    if (_isRegistering || _event == null) {
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor: cardColor,

          title: const Text(
            'ยืนยันการลงทะเบียน',

            style: TextStyle(color: textPrimary),
          ),

          content: Text(
            'ต้องการลงทะเบียนเข้าร่วมกิจกรรม "${_event!.title}" ใช่หรือไม่',

            style: const TextStyle(color: textSecondary, height: 1.5),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },

              child: const Text(
                'ยกเลิก',

                style: TextStyle(color: textSecondary),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,

                foregroundColor: backgroundColor,
              ),

              child: const Text('ลงทะเบียน'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    setState(() {
      _isRegistering = true;
    });

    final result = await UserEventService.registerEvent(_event!.id);

    if (!mounted) {
      return;
    }

    setState(() {
      _isRegistering = false;
    });

    if (result['success'] == true) {
      _showMessage(result['message'] ?? 'ลงทะเบียนสำเร็จ');

      // โหลดข้อมูลใหม่
      // จำนวนผู้สมัคร + isRegistered
      await _loadEvent(showLoading: false);

      return;
    }

    _showMessage(result['message'] ?? 'ลงทะเบียนไม่สำเร็จ', error: true);
  }

  // =========================================================
  // Message
  // =========================================================

  void _showMessage(String message, {bool error = false}) {
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
          onPressed: () {
            Navigator.pop(context, true);
          },

          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,

            color: textPrimary,

            size: 20,
          ),
        ),

        title: const Text(
          'รายละเอียดกิจกรรม',

          style: TextStyle(
            color: textPrimary,

            fontSize: 18,

            fontWeight: FontWeight.w700,
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {
              _loadEvent(showLoading: false);
            },

            icon: const Icon(Icons.refresh_rounded, color: textPrimary),
          ),
        ],
      ),

      body: _isLoading && _event == null
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _event == null
          ? _buildError()
          : RefreshIndicator(
              color: primaryColor,

              onRefresh: () => _loadEvent(showLoading: false),

              child: _buildContent(),
            ),

      bottomNavigationBar: _event == null ? null : _buildBottomButton(),
    );
  }

  // =========================================================
  // Content
  // =========================================================

  Widget _buildContent() {
    final event = _event!;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),

      padding: const EdgeInsets.fromLTRB(20, 10, 20, 125),

      children: [
        // =====================================================
        // Header
        // =====================================================
        Container(
          padding: const EdgeInsets.all(19),

          decoration: BoxDecoration(
            color: cardColor,

            borderRadius: BorderRadius.circular(23),

            border: Border.all(
              color: event.isRegistered
                  ? primaryColor.withOpacity(0.25)
                  : borderColor,
            ),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                children: [
                  _statusBadge(event.status),

                  if (event.isRegistered) ...[
                    const SizedBox(width: 7),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),

                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.08),

                        borderRadius: BorderRadius.circular(30),
                      ),

                      child: const Row(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          Icon(
                            Icons.check_circle_rounded,

                            color: primaryColor,

                            size: 12,
                          ),

                          SizedBox(width: 4),

                          Text(
                            'ลงทะเบียนแล้ว',

                            style: TextStyle(
                              color: primaryColor,

                              fontSize: 8,

                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 15),

              Text(
                event.title,

                style: const TextStyle(
                  color: textPrimary,

                  fontSize: 22,

                  height: 1.25,

                  fontWeight: FontWeight.w800,
                ),
              ),

              if (event.description != null &&
                  event.description!.trim().isNotEmpty) ...[
                const SizedBox(height: 9),

                Text(
                  event.description!,

                  style: const TextStyle(
                    color: textSecondary,

                    fontSize: 11,

                    height: 1.55,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 20),

        // =====================================================
        // Information
        // =====================================================
        const Text(
          'ข้อมูลกิจกรรม',

          style: TextStyle(
            color: textPrimary,

            fontSize: 17,

            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(17),

          decoration: BoxDecoration(
            color: cardColor,

            borderRadius: BorderRadius.circular(20),

            border: Border.all(color: borderColor),
          ),

          child: Column(
            children: [
              _infoRow(
                icon: Icons.location_on_outlined,

                title: 'สถานที่',

                value: event.locationName,
              ),

              _divider(),

              _infoRow(
                icon: Icons.calendar_month_outlined,

                title: 'วันและเวลา',

                value: _formatEventDate(event),
              ),

              _divider(),

              _infoRow(
                icon: Icons.groups_2_outlined,

                title: 'ผู้เข้าร่วม',

                value: _participantText(event),
              ),

              _divider(),

              _infoRow(
                icon: Icons.radar_rounded,

                title: 'พื้นที่เช็กอิน',

                value: 'ภายในรัศมี ${event.checkinRadius} เมตร',
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // =====================================================
        // Check-in information
        // =====================================================
        const Text(
          'การเช็กอิน',

          style: TextStyle(
            color: textPrimary,

            fontSize: 17,

            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(17),

          decoration: BoxDecoration(
            color: cardColor,

            borderRadius: BorderRadius.circular(20),

            border: Border.all(color: borderColor),
          ),

          child: event.checkinStartAt == null || event.checkinEndAt == null
              ? const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,

                      color: textSecondary,

                      size: 19,
                    ),

                    SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        'ผู้จัดยังไม่ได้กำหนดช่วงเวลาเช็กอิน',

                        style: TextStyle(color: textSecondary, fontSize: 11),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _infoRow(
                      icon: Icons.login_rounded,

                      title: 'เปิดเช็กอิน',

                      value: _formatDateTime(event.checkinStartAt!),
                    ),

                    _divider(),

                    _infoRow(
                      icon: Icons.logout_rounded,

                      title: 'ปิดเช็กอิน',

                      value: _formatDateTime(event.checkinEndAt!),
                    ),
                  ],
                ),
        ),

        if (event.isRegistered) ...[
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(15),

            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.06),

              borderRadius: BorderRadius.circular(17),

              border: Border.all(color: primaryColor.withOpacity(0.18)),
            ),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Icon(
                  Icons.verified_rounded,

                  color: primaryColor,

                  size: 22,
                ),

                const SizedBox(width: 11),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text(
                        'คุณลงทะเบียนกิจกรรมนี้แล้ว',

                        style: TextStyle(
                          color: textPrimary,

                          fontSize: 12,

                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        event.isCheckedIn
                            ? 'เช็กอินกิจกรรมนี้เรียบร้อยแล้ว'
                            : 'เมื่อถึงช่วงเวลาเช็กอิน คุณสามารถใช้ GPS เพื่อเช็กอินได้',

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
          ),
        ],
      ],
    );
  }

  // =========================================================
  // Bottom Button
  // =========================================================

  Widget _buildBottomButton() {
    final event = _event!;

    String text;
    IconData icon;

    bool enabled = true;
    VoidCallback? action;

    // =========================================================
    // เช็กอินไปแล้ว
    // =========================================================

    if (event.isCheckedIn) {
      text = 'เช็กอินเรียบร้อยแล้ว';
      icon = Icons.check_circle_rounded;

      enabled = false;
    }
    // =========================================================
    // ลงทะเบียนแล้ว
    // =========================================================
    else if (event.isRegistered) {
      // -------------------------------------------------------
      // Admin ยังไม่ได้กำหนดเวลา Check-in
      // -------------------------------------------------------

      if (event.checkinStartAt == null || event.checkinEndAt == null) {
        text = 'ยังไม่กำหนดเวลาเช็กอิน';
        icon = Icons.schedule_rounded;

        enabled = false;
      }
      // -------------------------------------------------------
      // อยู่ในช่วง Check-in
      // -------------------------------------------------------
      else if (_isCheckinTime(event)) {
        text = 'เช็กอินด้วย GPS';
        icon = Icons.my_location_rounded;

        enabled = true;

        action = () async {
          final success = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => UserCheckinScreen(event: event)),
          );

          if (success == true && mounted) {
            await _loadEvent(showLoading: false);
          }
        };
      }
      // -------------------------------------------------------
      // ยังไม่ถึงเวลา
      // -------------------------------------------------------
      else if (DateTime.now().isBefore(event.checkinStartAt!)) {
        text = 'ยังไม่ถึงเวลาเช็กอิน';
        icon = Icons.schedule_rounded;

        enabled = false;
      }
      // -------------------------------------------------------
      // หมดเวลา Check-in
      // -------------------------------------------------------
      else {
        text = 'หมดเวลาเช็กอินแล้ว';
        icon = Icons.timer_off_outlined;

        enabled = false;
      }
    }
    // =========================================================
    // ยังไม่ได้ลงทะเบียน + ปิดรับ
    // =========================================================
    else if (event.status != 'open') {
      text = 'ปิดรับลงทะเบียน';
      icon = Icons.lock_outline_rounded;

      enabled = false;
    }
    // =========================================================
    // คนเต็ม
    // =========================================================
    else if (event.isFull) {
      text = 'ผู้เข้าร่วมเต็มแล้ว';
      icon = Icons.groups_rounded;

      enabled = false;
    }
    // =========================================================
    // ยังไม่ได้ลงทะเบียน
    // =========================================================
    else {
      text = 'ลงทะเบียนเข้าร่วม';
      icon = Icons.how_to_reg_rounded;

      enabled = true;
      action = _register;
    }

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 15),

        decoration: BoxDecoration(
          color: backgroundColor,

          border: Border(top: BorderSide(color: borderColor.withOpacity(0.7))),
        ),

        child: SizedBox(
          height: 55,

          child: ElevatedButton(
            onPressed: enabled && !_isRegistering ? action : null,

            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,

              foregroundColor: backgroundColor,

              disabledBackgroundColor: const Color(0xFF1B2630),

              disabledForegroundColor: textSecondary,

              elevation: 0,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
              ),
            ),

            child: _isRegistering
                ? const SizedBox(
                    width: 23,
                    height: 23,

                    child: CircularProgressIndicator(
                      color: backgroundColor,

                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Icon(icon, size: 20),

                      const SizedBox(width: 8),

                      Text(
                        text,

                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // Info Row
  // =========================================================

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Container(
          width: 38,
          height: 38,

          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.08),

            borderRadius: BorderRadius.circular(11),
          ),

          child: Icon(icon, color: primaryColor, size: 18),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                title,

                style: const TextStyle(color: textSecondary, fontSize: 9),
              ),

              const SizedBox(height: 3),

              Text(
                value,

                style: const TextStyle(
                  color: textPrimary,

                  fontSize: 11,

                  height: 1.4,

                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 13),

      child: Divider(color: borderColor, height: 1),
    );
  }

  // =========================================================
  // Status
  // =========================================================

  Widget _statusBadge(String status) {
    String text;
    Color color;

    switch (status) {
      case 'open':
        text = 'เปิดรับสมัคร';

        color = primaryColor;

        break;

      case 'closed':
        text = 'ปิดรับสมัคร';

        color = warningColor;

        break;

      case 'completed':
        text = 'เสร็จสิ้น';

        color = textSecondary;

        break;

      default:
        text = status;

        color = textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

      decoration: BoxDecoration(
        color: color.withOpacity(0.09),

        borderRadius: BorderRadius.circular(30),
      ),

      child: Text(
        text,

        style: TextStyle(
          color: color,

          fontSize: 8,

          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // =========================================================
  // Error
  // =========================================================

  Widget _buildError() {
    return Center(
      child: TextButton(
        onPressed: _loadEvent,

        child: const Text(
          'โหลดข้อมูลไม่สำเร็จ - แตะเพื่อลองใหม่',

          style: TextStyle(color: primaryColor),
        ),
      ),
    );
  }

  // =========================================================
  // Participant
  // =========================================================

  String _participantText(UserEvent event) {
    if (event.maxParticipants == null) {
      return 'ลงทะเบียนแล้ว ${event.registeredCount} คน • ไม่จำกัดจำนวน';
    }

    final remaining = event.remainingSlots ?? 0;

    return 'ลงทะเบียนแล้ว ${event.registeredCount}/${event.maxParticipants} คน • เหลือ $remaining ที่';
  }

  // =========================================================
  // Date
  // =========================================================

  String _formatEventDate(UserEvent event) {
    final start = event.startAt;

    final end = event.endAt;

    final sameDay =
        start.year == end.year &&
        start.month == end.month &&
        start.day == end.day;

    if (sameDay) {
      return '${_two(start.day)}/${_two(start.month)}/${start.year} '
          '${_two(start.hour)}:${_two(start.minute)} - '
          '${_two(end.hour)}:${_two(end.minute)}';
    }

    return '${_formatDateTime(start)} - ${_formatDateTime(end)}';
  }

  String _formatDateTime(DateTime date) {
    return '${_two(date.day)}/${_two(date.month)}/${date.year} '
        '${_two(date.hour)}:${_two(date.minute)}';
  }

  String _two(int number) {
    return number.toString().padLeft(2, '0');
  }
}
