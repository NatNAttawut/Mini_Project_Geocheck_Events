import 'package:flutter/material.dart';

import '../../models/admin_report.dart';
import '../../services/admin_report_service.dart';

class AdminReportScreen
    extends StatefulWidget {
  const AdminReportScreen({
    super.key,
  });

  @override
  State<AdminReportScreen>
      createState() =>
          _AdminReportScreenState();
}

class _AdminReportScreenState
    extends State<
        AdminReportScreen> {
  static const Color backgroundColor =
      Color(0xFF080D13);

  static const Color cardColor =
      Color(0xFF101720);

  static const Color borderColor =
      Color(0xFF26313D);

  static const Color primaryColor =
      Color(0xFFB7F52B);

  static const Color textPrimary =
      Color(0xFFF3F5F7);

  static const Color textSecondary =
      Color(0xFF8B98A5);

  AdminReport? _report;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadReport();
  }

  // =========================================================
  // Load Report
  // =========================================================

  Future<void>
      _loadReport() async {
    setState(() {
      _isLoading = true;
    });

    final result =
        await AdminReportService
            .getReport();

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    if (result['success'] ==
        true) {
      setState(() {
        _report =
            result['report']
                as AdminReport;
      });

      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          result['message'] ??
              'ไม่สามารถโหลดรายงานได้',
        ),
        backgroundColor:
            const Color(
          0xFFD94A4A,
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          backgroundColor,

      body: SafeArea(
        child: _isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(
                  color:
                      primaryColor,
                ),
              )
            : _report == null
                ? _buildError()
                : RefreshIndicator(
                    color:
                        primaryColor,
                    onRefresh:
                        _loadReport,
                    child:
                        _buildContent(),
                  ),
      ),
    );
  }

  // =========================================================
  // Content
  // =========================================================

  Widget _buildContent() {
    final report =
        _report!;

    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),

      padding:
          const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        115,
      ),

      children: [
        // =====================================================
        // Header
        // =====================================================

        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration:
                  BoxDecoration(
                color:
                    primaryColor
                        .withOpacity(
                  0.10,
                ),
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),
              child:
                  const Icon(
                Icons
                    .analytics_rounded,
                color:
                    primaryColor,
                size: 24,
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            const Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    'รายงาน',
                    style:
                        TextStyle(
                      color:
                          textPrimary,
                      fontSize:
                          22,
                      fontWeight:
                          FontWeight
                              .w700,
                    ),
                  ),

                  SizedBox(
                    height: 2,
                  ),

                  Text(
                    'ภาพรวมการใช้งานระบบ GeoCheck',
                    style:
                        TextStyle(
                      color:
                          textSecondary,
                      fontSize:
                          11,
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed:
                  _loadReport,
              icon:
                  const Icon(
                Icons
                    .refresh_rounded,
                color:
                    textSecondary,
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 28,
        ),

        // =====================================================
        // Overview
        // =====================================================

        const Text(
          'ภาพรวมระบบ',
          style:
              TextStyle(
            color:
                textPrimary,
            fontSize: 17,
            fontWeight:
                FontWeight.w700,
          ),
        ),

        const SizedBox(
          height: 13,
        ),

        Row(
          children: [
            Expanded(
              child:
                  _SummaryCard(
                icon:
                    Icons
                        .groups_rounded,
                title:
                    'สมาชิก',
                value:
                    '${report.totalUsers}',
                unit:
                    'คน',
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            Expanded(
              child:
                  _SummaryCard(
                icon:
                    Icons
                        .event_rounded,
                title:
                    'กิจกรรม',
                value:
                    '${report.totalEvents}',
                unit:
                    'กิจกรรม',
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 10,
        ),

        Row(
          children: [
            Expanded(
              child:
                  _SummaryCard(
                icon:
                    Icons
                        .how_to_reg_rounded,
                title:
                    'ลงทะเบียน',
                value:
                    '${report.totalRegistrations}',
                unit:
                    'ครั้ง',
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            Expanded(
              child:
                  _SummaryCard(
                icon:
                    Icons
                        .location_on_rounded,
                title:
                    'เช็กอิน',
                value:
                    '${report.totalCheckins}',
                unit:
                    'ครั้ง',
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 12,
        ),

        // =====================================================
        // Attendance
        // =====================================================

        _AttendanceCard(
          rate:
              report.attendanceRate,
          openEvents:
              report.openEvents,
          registrations:
              report.totalRegistrations,
          checkins:
              report.totalCheckins,
        ),

        const SizedBox(
          height: 30,
        ),

        // =====================================================
        // Event Report
        // =====================================================

        Row(
          children: [
            const Expanded(
              child:
                  Text(
                'รายงานตามกิจกรรม',
                style:
                    TextStyle(
                  color:
                      textPrimary,
                  fontSize:
                      17,
                  fontWeight:
                      FontWeight
                          .w700,
                ),
              ),
            ),

            Text(
              '${report.events.length} กิจกรรม',
              style:
                  const TextStyle(
                color:
                    textSecondary,
                fontSize:
                    10,
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 13,
        ),

        if (report.events.isEmpty)
          _buildNoEvents()
        else
          ...report.events.map(
            (event) =>
                Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 12,
              ),
              child:
                  _EventReportCard(
                event:
                    event,
              ),
            ),
          ),
      ],
    );
  }

  // =========================================================
  // Empty
  // =========================================================

  Widget _buildNoEvents() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        vertical: 45,
      ),
      decoration:
          BoxDecoration(
        color:
            cardColor,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
        border:
            Border.all(
          color:
              borderColor,
        ),
      ),
      child:
          const Column(
        children: [
          Icon(
            Icons
                .analytics_outlined,
            color:
                textSecondary,
            size: 40,
          ),

          SizedBox(
            height: 12,
          ),

          Text(
            'ยังไม่มีข้อมูลรายงานกิจกรรม',
            style:
                TextStyle(
              color:
                  textPrimary,
              fontWeight:
                  FontWeight
                      .w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child:
          Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          const Icon(
            Icons
                .error_outline_rounded,
            color:
                Color(
              0xFFFF6262,
            ),
            size:
                45,
          ),

          const SizedBox(
            height: 12,
          ),

          const Text(
            'ไม่สามารถโหลดรายงานได้',
            style:
                TextStyle(
              color:
                  textPrimary,
            ),
          ),

          const SizedBox(
            height: 15,
          ),

          TextButton(
            onPressed:
                _loadReport,
            child:
                const Text(
              'ลองอีกครั้ง',
              style:
                  TextStyle(
                color:
                    primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// Summary Card
// =============================================================

class _SummaryCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String unit;

  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(
        15,
      ),
      decoration:
          BoxDecoration(
        color:
            _AdminReportScreenState
                .cardColor,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        border:
            Border.all(
          color:
              _AdminReportScreenState
                  .borderColor,
        ),
      ),
      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          Container(
            width: 37,
            height: 37,
            decoration:
                BoxDecoration(
              color:
                  _AdminReportScreenState
                      .primaryColor
                      .withOpacity(
                0.09,
              ),
              borderRadius:
                  BorderRadius.circular(
                11,
              ),
            ),
            child:
                Icon(
              icon,
              color:
                  _AdminReportScreenState
                      .primaryColor,
              size:
                  19,
            ),
          ),

          const SizedBox(
            height: 15,
          ),

          Row(
            crossAxisAlignment:
                CrossAxisAlignment
                    .end,
            children: [
              Text(
                value,
                style:
                    const TextStyle(
                  color:
                      _AdminReportScreenState
                          .textPrimary,
                  fontSize:
                      25,
                  fontWeight:
                      FontWeight
                          .w800,
                ),
              ),

              const SizedBox(
                width: 5,
              ),

              Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 3,
                ),
                child:
                    Text(
                  unit,
                  style:
                      const TextStyle(
                    color:
                        _AdminReportScreenState
                            .textSecondary,
                    fontSize:
                        9,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 2,
          ),

          Text(
            title,
            style:
                const TextStyle(
              color:
                  _AdminReportScreenState
                      .textSecondary,
              fontSize:
                  10,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// Attendance Overview
// =============================================================

class _AttendanceCard
    extends StatelessWidget {
  final double rate;
  final int openEvents;
  final int registrations;
  final int checkins;

  const _AttendanceCard({
    required this.rate,
    required this.openEvents,
    required this.registrations,
    required this.checkins,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final progress =
        (rate / 100)
            .clamp(
              0.0,
              1.0,
            );

    return Container(
      padding:
          const EdgeInsets.all(
        18,
      ),
      decoration:
          BoxDecoration(
        color:
            _AdminReportScreenState
                .cardColor,

        borderRadius:
            BorderRadius.circular(
          20,
        ),

        border:
            Border.all(
          color:
              _AdminReportScreenState
                  .primaryColor
                  .withOpacity(
            0.18,
          ),
        ),
      ),
      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          const Row(
            children: [
              Icon(
                Icons
                    .trending_up_rounded,
                color:
                    _AdminReportScreenState
                        .primaryColor,
                size:
                    20,
              ),

              SizedBox(
                width: 8,
              ),

              Text(
                'อัตราการเข้าร่วม',
                style:
                    TextStyle(
                  color:
                      _AdminReportScreenState
                          .textPrimary,
                  fontSize:
                      14,
                  fontWeight:
                      FontWeight
                          .w700,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 18,
          ),

          Text(
            '${rate.toStringAsFixed(1)}%',
            style:
                const TextStyle(
              color:
                  _AdminReportScreenState
                      .primaryColor,
              fontSize:
                  31,
              fontWeight:
                  FontWeight
                      .w800,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(
              20,
            ),
            child:
                LinearProgressIndicator(
              value:
                  progress,
              minHeight:
                  8,
              backgroundColor:
                  const Color(
                0xFF202A35,
              ),
              valueColor:
                  const AlwaysStoppedAnimation<
                      Color>(
                _AdminReportScreenState
                    .primaryColor,
              ),
            ),
          ),

          const SizedBox(
            height: 15,
          ),

          Row(
            children: [
              Expanded(
                child:
                    _miniValue(
                  'กำลังเปิด',
                  '$openEvents',
                ),
              ),

              Expanded(
                child:
                    _miniValue(
                  'ลงทะเบียน',
                  '$registrations',
                ),
              ),

              Expanded(
                child:
                    _miniValue(
                  'เช็กอิน',
                  '$checkins',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniValue(
    String label,
    String value,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style:
              const TextStyle(
            color:
                _AdminReportScreenState
                    .textPrimary,
            fontSize:
                14,
            fontWeight:
                FontWeight.w700,
          ),
        ),

        Text(
          label,
          style:
              const TextStyle(
            color:
                _AdminReportScreenState
                    .textSecondary,
            fontSize:
                9,
          ),
        ),
      ],
    );
  }
}

// =============================================================
// Event Report Card
// =============================================================

class _EventReportCard
    extends StatelessWidget {
  final EventReport event;

  const _EventReportCard({
    required this.event,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final rate =
        event.attendanceRate
            .clamp(
              0,
              100,
            );

    return Container(
      padding:
          const EdgeInsets.all(
        16,
      ),
      decoration:
          BoxDecoration(
        color:
            _AdminReportScreenState
                .cardColor,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
        border:
            Border.all(
          color:
              _AdminReportScreenState
                  .borderColor,
        ),
      ),
      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Expanded(
                child:
                    Text(
                  event.title,
                  style:
                      const TextStyle(
                    color:
                        _AdminReportScreenState
                            .textPrimary,
                    fontSize:
                        14,
                    fontWeight:
                        FontWeight
                            .w700,
                  ),
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              _statusBadge(
                event.status,
              ),
            ],
          ),

          const SizedBox(
            height: 8,
          ),

          Row(
            children: [
              const Icon(
                Icons
                    .calendar_month_outlined,
                color:
                    _AdminReportScreenState
                        .textSecondary,
                size:
                    14,
              ),

              const SizedBox(
                width: 6,
              ),

              Text(
                _formatDate(
                  event.startAt,
                ),
                style:
                    const TextStyle(
                  color:
                      _AdminReportScreenState
                          .textSecondary,
                  fontSize:
                      10,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 17,
          ),

          Row(
            children: [
              Expanded(
                child:
                    _eventValue(
                  icon:
                      Icons
                          .how_to_reg_rounded,
                  title:
                      'ลงทะเบียน',
                  value:
                      '${event.registeredCount}',
                ),
              ),

              Container(
                width:
                    1,
                height:
                    32,
                color:
                    _AdminReportScreenState
                        .borderColor,
              ),

              Expanded(
                child:
                    _eventValue(
                  icon:
                      Icons
                          .location_on_rounded,
                  title:
                      'เช็กอินแล้ว',
                  value:
                      '${event.checkinCount}',
                ),
              ),

              Container(
                width:
                    1,
                height:
                    32,
                color:
                    _AdminReportScreenState
                        .borderColor,
              ),

              Expanded(
                child:
                    _eventValue(
                  icon:
                      Icons
                          .percent_rounded,
                  title:
                      'เข้าร่วม',
                  value:
                      '${event.attendanceRate.toStringAsFixed(0)}%',
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 17,
          ),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(
              20,
            ),
            child:
                LinearProgressIndicator(
              value:
                  rate / 100,

              minHeight:
                  6,

              backgroundColor:
                  const Color(
                0xFF202A35,
              ),

              valueColor:
                  const AlwaysStoppedAnimation<
                      Color>(
                _AdminReportScreenState
                    .primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _eventValue({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color:
              _AdminReportScreenState
                  .primaryColor,
          size:
              17,
        ),

        const SizedBox(
          height: 4,
        ),

        Text(
          value,
          style:
              const TextStyle(
            color:
                _AdminReportScreenState
                    .textPrimary,
            fontSize:
                13,
            fontWeight:
                FontWeight.w700,
          ),
        ),

        Text(
          title,
          style:
              const TextStyle(
            color:
                _AdminReportScreenState
                    .textSecondary,
            fontSize:
                8,
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(
    String status,
  ) {
    String text;

    switch (status) {
      case 'open':
        text = 'เปิดรับ';
        break;

      case 'closed':
        text = 'ปิดรับ';
        break;

      case 'completed':
        text = 'เสร็จสิ้น';
        break;

      case 'cancelled':
        text = 'ยกเลิก';
        break;

      default:
        text = 'แบบร่าง';
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration:
          BoxDecoration(
        color:
            _AdminReportScreenState
                .primaryColor
                .withOpacity(
          0.08,
        ),
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child:
          Text(
        text,
        style:
            const TextStyle(
          color:
              _AdminReportScreenState
                  .primaryColor,
          fontSize:
              8,
          fontWeight:
              FontWeight.w700,
        ),
      ),
    );
  }

  String _formatDate(
    DateTime date,
  ) {
    String two(
      int value,
    ) {
      return value
          .toString()
          .padLeft(
            2,
            '0',
          );
    }

    return '${two(date.day)}/${two(date.month)}/${date.year} '
        '${two(date.hour)}:${two(date.minute)}';
  }
}