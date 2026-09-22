import 'package:flutter/material.dart';

import '../../models/admin_dashboard.dart';
import '../../services/admin_dashboard_service.dart';
import '../../widgets/admin_bottom_nav.dart';

import 'members_screen.dart';
import 'manage_events_screen.dart';
import 'admin_report_screen.dart';
import 'admin_profile_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({
    super.key,
  });

  @override
  State<AdminHomeScreen> createState() =>
      _AdminHomeScreenState();
}

class _AdminHomeScreenState
    extends State<AdminHomeScreen> {
  int _currentIndex = 0;

  final GlobalKey<_AdminDashboardState>
      _dashboardKey =
      GlobalKey<_AdminDashboardState>();

  static const Color backgroundColor =
      Color(0xFF080D13);

  // =========================================================
  // Change Page
  // =========================================================

  void _changePage(int index) {
    setState(() {
      _currentIndex = index;
    });

    // กลับมาหน้า Dashboard ให้โหลดข้อมูลใหม่
    if (index == 0) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) {
        _dashboardKey.currentState
            ?.refreshDashboard();
      });
    }
  }

  // =========================================================
  // Build
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: IndexedStack(
        index: _currentIndex,
        children: [
          // =================================================
          // Dashboard
          // =================================================

          _AdminDashboard(
            key: _dashboardKey,

            onOpenMembers: () {
              _changePage(1);
            },

            onOpenEvents: () {
              _changePage(2);
            },

            onOpenReports: () {
              _changePage(3);
            },
          ),

          // =================================================
          // Members
          // =================================================

          const MembersScreen(),

          // =================================================
          // Events
          // =================================================

          const ManageEventsScreen(),

          // =================================================
          // Reports
          // =================================================

          const AdminReportScreen(),

          // =================================================
          // Profile
          // =================================================

          const AdminProfileScreen(),
        ],
      ),

      bottomNavigationBar:
          AdminBottomNav(
        currentIndex: _currentIndex,
        onTap: _changePage,
      ),
    );
  }
}

// =============================================================
// Admin Dashboard
// =============================================================

class _AdminDashboard
    extends StatefulWidget {
  final VoidCallback onOpenMembers;
  final VoidCallback onOpenEvents;
  final VoidCallback onOpenReports;

  const _AdminDashboard({
    super.key,
    required this.onOpenMembers,
    required this.onOpenEvents,
    required this.onOpenReports,
  });

  @override
  State<_AdminDashboard> createState() =>
      _AdminDashboardState();
}

class _AdminDashboardState
    extends State<_AdminDashboard> {
  // =========================================================
  // Colors
  // =========================================================

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

  // =========================================================
  // State
  // =========================================================

  AdminDashboard? _dashboard;

  bool _isLoading = true;

  // =========================================================
  // Init
  // =========================================================

  @override
  void initState() {
    super.initState();

    _loadDashboard();
  }

  // =========================================================
  // Public Refresh
  // =========================================================

  Future<void> refreshDashboard() async {
    await _loadDashboard(
      showLoading: false,
    );
  }

  // =========================================================
  // Load Dashboard
  // =========================================================

  Future<void> _loadDashboard({
    bool showLoading = true,
  }) async {
    if (showLoading &&
        mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final result =
        await AdminDashboardService
            .getDashboard();

    if (!mounted) {
      return;
    }

    if (result['success'] == true) {
      setState(() {
        _dashboard =
            result['dashboard']
                as AdminDashboard;

        _isLoading = false;
      });

      return;
    }

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          result['message'] ??
              'ไม่สามารถโหลด Dashboard ได้',
        ),
        backgroundColor:
            const Color(
          0xFFD94A4A,
        ),
      ),
    );
  }

  // =========================================================
  // Build
  // =========================================================

  @override
  Widget build(BuildContext context) {
    // =======================================================
    // Initial Loading
    // =======================================================

    if (_isLoading &&
        _dashboard == null) {
      return const SafeArea(
        child: Center(
          child:
              CircularProgressIndicator(
            color: primaryColor,
          ),
        ),
      );
    }

    // =======================================================
    // Error
    // =======================================================

    if (_dashboard == null) {
      return _buildError();
    }

    final dashboard =
        _dashboard!;

    return SafeArea(
      child: RefreshIndicator(
        color: primaryColor,

        onRefresh:
            refreshDashboard,

        child:
            SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),

          padding:
              const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            35,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // =================================================
              // Header
              // =================================================

              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,

                    decoration:
                        BoxDecoration(
                      color:
                          primaryColor,

                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),
                    ),

                    child:
                        const Icon(
                      Icons
                          .admin_panel_settings_rounded,

                      color:
                          backgroundColor,

                      size: 25,
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
                          'GeoCheck Admin',

                          style:
                              TextStyle(
                            color:
                                textPrimary,

                            fontSize:
                                19,

                            fontWeight:
                                FontWeight
                                    .w700,
                          ),
                        ),

                        SizedBox(
                          height: 2,
                        ),

                        Text(
                          'CONTROL CENTER',

                          style:
                              TextStyle(
                            color:
                                Color(
                              0xFF586572,
                            ),

                            fontSize:
                                9,

                            letterSpacing:
                                2,

                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ===========================================
                  // Refresh Button
                  // ===========================================

                  Material(
                    color:
                        Colors.transparent,

                    child: InkWell(
                      onTap:
                          refreshDashboard,

                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),

                      child: Container(
                        width: 43,
                        height: 43,

                        decoration:
                            BoxDecoration(
                          color:
                              cardColor,

                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),

                          border:
                              Border.all(
                            color:
                                borderColor,
                          ),
                        ),

                        child:
                            const Icon(
                          Icons
                              .refresh_rounded,

                          color:
                              textPrimary,

                          size: 21,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 30,
              ),

              // =================================================
              // Welcome
              // =================================================

              const Text(
                'ADMIN DASHBOARD',

                style:
                    TextStyle(
                  color:
                      primaryColor,

                  fontSize:
                      10,

                  letterSpacing:
                      2,

                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(
                height: 7,
              ),

              const Text(
                'ภาพรวมระบบ\nGeoCheck Event',

                style:
                    TextStyle(
                  color:
                      textPrimary,

                  fontSize:
                      30,

                  height:
                      1.15,

                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              const Text(
                'ข้อมูลล่าสุดจากสมาชิก กิจกรรม และการเช็กอิน',

                style:
                    TextStyle(
                  color:
                      textSecondary,

                  fontSize:
                      13,
                ),
              ),

              const SizedBox(
                height: 26,
              ),

              // =================================================
              // Real Statistics
              // =================================================

              Row(
                children: [
                  Expanded(
                    child:
                        _StatCard(
                      icon:
                          Icons
                              .groups_rounded,

                      title:
                          'สมาชิก',

                      value:
                          '${dashboard.totalUsers}',

                      description:
                          'ทั้งหมด',
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child:
                        _StatCard(
                      icon:
                          Icons
                              .event_available_rounded,

                      title:
                          'กิจกรรม',

                      value:
                          '${dashboard.totalEvents}',

                      description:
                          'ทั้งหมด',
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 12,
              ),

              Row(
                children: [
                  Expanded(
                    child:
                        _StatCard(
                      icon:
                          Icons
                              .campaign_rounded,

                      title:
                          'กำลังเปิด',

                      value:
                          '${dashboard.openEvents}',

                      description:
                          'กิจกรรม',
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child:
                        _StatCard(
                      icon:
                          Icons
                              .location_on_rounded,

                      title:
                          'เช็กอินวันนี้',

                      value:
                          '${dashboard.todayCheckins}',

                      description:
                          'คน',

                      highlight:
                          true,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 30,
              ),

              // =================================================
              // Quick Actions
              // =================================================

              const Text(
                'จัดการด่วน',

                style:
                    TextStyle(
                  color:
                      textPrimary,

                  fontSize:
                      18,

                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              _AdminQuickAction(
                icon:
                    Icons
                        .add_circle_outline_rounded,

                title:
                    'สร้างกิจกรรมใหม่',

                subtitle:
                    'เพิ่มกิจกรรมและกำหนดพื้นที่เช็กอิน',

                onTap:
                    widget
                        .onOpenEvents,
              ),

              const SizedBox(
                height: 10,
              ),

              _AdminQuickAction(
                icon:
                    Icons
                        .groups_2_outlined,

                title:
                    'จัดการสมาชิก',

                subtitle:
                    'ดูข้อมูลสมาชิกทั้งหมดในระบบ',

                onTap:
                    widget
                        .onOpenMembers,
              ),

              const SizedBox(
                height: 10,
              ),

              _AdminQuickAction(
                icon:
                    Icons
                        .analytics_outlined,

                title:
                    'ดูรายงาน',

                subtitle:
                    'ตรวจสอบการลงทะเบียนและเช็กอิน',

                onTap:
                    widget
                        .onOpenReports,
              ),

              const SizedBox(
                height: 30,
              ),

              // =================================================
              // Recent Events Header
              // =================================================

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'กิจกรรมล่าสุด',

                      style:
                          TextStyle(
                        color:
                            textPrimary,

                        fontSize:
                            18,

                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap:
                        widget
                            .onOpenEvents,

                    child:
                        const Text(
                      'ดูทั้งหมด',

                      style:
                          TextStyle(
                        color:
                            primaryColor,

                        fontSize:
                            12,

                        fontWeight:
                            FontWeight
                                .w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 14,
              ),

              // =================================================
              // Recent Events
              // =================================================

              if (dashboard
                  .recentEvents
                  .isEmpty)
                _buildEmptyEvents()
              else
                ...dashboard
                    .recentEvents
                    .map(
                  (event) {
                    return Padding(
                      padding:
                          const EdgeInsets
                              .only(
                        bottom: 12,
                      ),

                      child:
                          _AdminEventCard(
                        title:
                            event.title,

                        location:
                            event
                                .locationName,

                        date:
                            _formatDate(
                          event.startAt,
                        ),

                        registered:
                            event
                                .registeredCount,

                        checkedIn:
                            event
                                .checkinCount,

                        status:
                            _statusText(
                          event.status,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // Error
  // =========================================================

  Widget _buildError() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding:
              const EdgeInsets.all(
            25,
          ),

          child: Column(
            mainAxisSize:
                MainAxisSize.min,

            children: [
              Container(
                width: 74,
                height: 74,

                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFFF6262,
                  ).withOpacity(
                    0.08,
                  ),

                  shape:
                      BoxShape.circle,
                ),

                child:
                    const Icon(
                  Icons
                      .cloud_off_rounded,

                  color:
                      Color(
                    0xFFFF6262,
                  ),

                  size: 32,
                ),
              ),

              const SizedBox(
                height: 17,
              ),

              const Text(
                'โหลด Dashboard ไม่สำเร็จ',

                style:
                    TextStyle(
                  color:
                      textPrimary,

                  fontSize:
                      17,

                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(
                height: 6,
              ),

              const Text(
                'ตรวจสอบการเชื่อมต่อ Server แล้วลองอีกครั้ง',

                textAlign:
                    TextAlign.center,

                style:
                    TextStyle(
                  color:
                      textSecondary,

                  fontSize:
                      11,
                ),
              ),

              const SizedBox(
                height: 17,
              ),

              ElevatedButton.icon(
                onPressed: () {
                  _loadDashboard();
                },

                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      primaryColor,

                  foregroundColor:
                      backgroundColor,

                  elevation: 0,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                      14,
                    ),
                  ),
                ),

                icon:
                    const Icon(
                  Icons
                      .refresh_rounded,
                ),

                label:
                    const Text(
                  'ลองอีกครั้ง',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // Empty Recent Events
  // =========================================================

  Widget _buildEmptyEvents() {
    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.symmetric(
        vertical: 38,
        horizontal: 20,
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
                .event_busy_outlined,

            color:
                textSecondary,

            size: 37,
          ),

          SizedBox(
            height: 11,
          ),

          Text(
            'ยังไม่มีกิจกรรม',

            style:
                TextStyle(
              color:
                  textPrimary,

              fontSize:
                  14,

              fontWeight:
                  FontWeight.w700,
            ),
          ),

          SizedBox(
            height: 4,
          ),

          Text(
            'สร้างกิจกรรมใหม่เพื่อเริ่มใช้งาน',

            style:
                TextStyle(
              color:
                  textSecondary,

              fontSize:
                  10,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // Status Text
  // =========================================================

  String _statusText(
    String status,
  ) {
    switch (status) {
      case 'open':
        return 'เปิดรับ';

      case 'closed':
        return 'ปิดรับ';

      case 'completed':
        return 'เสร็จสิ้น';

      case 'cancelled':
        return 'ยกเลิก';

      default:
        return 'แบบร่าง';
    }
  }

  // =========================================================
  // Format Date
  // =========================================================

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

// =============================================================
// Statistic Card
// =============================================================

class _StatCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String description;
  final bool highlight;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.description,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(
        17,
      ),

      decoration:
          BoxDecoration(
        color:
            _AdminDashboardState
                .cardColor,

        borderRadius:
            BorderRadius.circular(
          20,
        ),

        border:
            Border.all(
          color: highlight
              ? _AdminDashboardState
                  .primaryColor
                  .withOpacity(
                    0.30,
                  )
              : _AdminDashboardState
                  .borderColor,
        ),

        boxShadow: highlight
            ? [
                BoxShadow(
                  color:
                      _AdminDashboardState
                          .primaryColor
                          .withOpacity(
                    0.03,
                  ),

                  blurRadius:
                      18,
                ),
              ]
            : null,
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,

                decoration:
                    BoxDecoration(
                  color:
                      _AdminDashboardState
                          .primaryColor
                          .withOpacity(
                    0.09,
                  ),

                  borderRadius:
                      BorderRadius
                          .circular(
                    12,
                  ),
                ),

                child: Icon(
                  icon,

                  color:
                      _AdminDashboardState
                          .primaryColor,

                  size: 20,
                ),
              ),

              const Spacer(),

              Container(
                width: 7,
                height: 7,

                decoration:
                    const BoxDecoration(
                  color:
                      _AdminDashboardState
                          .primaryColor,

                  shape:
                      BoxShape.circle,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 18,
          ),

          Text(
            value,

            style:
                const TextStyle(
              color:
                  _AdminDashboardState
                      .textPrimary,

              fontSize:
                  27,

              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 3,
          ),

          Text(
            title,

            style:
                const TextStyle(
              color:
                  _AdminDashboardState
                      .textPrimary,

              fontSize:
                  12,

              fontWeight:
                  FontWeight.w600,
            ),
          ),

          const SizedBox(
            height: 2,
          ),

          Text(
            description,

            style:
                const TextStyle(
              color:
                  _AdminDashboardState
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
// Quick Action
// =============================================================

class _AdminQuickAction
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AdminQuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
          Colors.transparent,

      child: InkWell(
        onTap:
            onTap,

        borderRadius:
            BorderRadius.circular(
          18,
        ),

        child: Container(
          padding:
              const EdgeInsets.all(
            15,
          ),

          decoration:
              BoxDecoration(
            color:
                _AdminDashboardState
                    .cardColor,

            borderRadius:
                BorderRadius.circular(
              18,
            ),

            border:
                Border.all(
              color:
                  _AdminDashboardState
                      .borderColor,
            ),
          ),

          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,

                decoration:
                    BoxDecoration(
                  color:
                      _AdminDashboardState
                          .primaryColor
                          .withOpacity(
                    0.09,
                  ),

                  borderRadius:
                      BorderRadius
                          .circular(
                    13,
                  ),
                ),

                child: Icon(
                  icon,

                  color:
                      _AdminDashboardState
                          .primaryColor,

                  size: 22,
                ),
              ),

              const SizedBox(
                width: 13,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    Text(
                      title,

                      style:
                          const TextStyle(
                        color:
                            _AdminDashboardState
                                .textPrimary,

                        fontSize:
                            14,

                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      subtitle,

                      style:
                          const TextStyle(
                        color:
                            _AdminDashboardState
                                .textSecondary,

                        fontSize:
                            11,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons
                    .arrow_forward_ios_rounded,

                color:
                    Color(
                  0xFF596673,
                ),

                size:
                    15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================
// Event Card
// =============================================================

class _AdminEventCard
    extends StatelessWidget {
  final String title;
  final String location;
  final String date;

  final int registered;
  final int checkedIn;

  final String status;

  const _AdminEventCard({
    required this.title,
    required this.location,
    required this.date,
    required this.registered,
    required this.checkedIn,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(
        17,
      ),

      decoration:
          BoxDecoration(
        color:
            _AdminDashboardState
                .cardColor,

        borderRadius:
            BorderRadius.circular(
          20,
        ),

        border:
            Border.all(
          color:
              _AdminDashboardState
                  .borderColor,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          // =================================================
          // Event Title + Status
          // =================================================

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Expanded(
                child: Text(
                  title,

                  maxLines: 2,

                  overflow:
                      TextOverflow
                          .ellipsis,

                  style:
                      const TextStyle(
                    color:
                        _AdminDashboardState
                            .textPrimary,

                    fontSize:
                        14,

                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      _AdminDashboardState
                          .primaryColor
                          .withOpacity(
                    0.08,
                  ),

                  borderRadius:
                      BorderRadius
                          .circular(
                    30,
                  ),
                ),

                child: Text(
                  status,

                  style:
                      const TextStyle(
                    color:
                        _AdminDashboardState
                            .primaryColor,

                    fontSize:
                        9,

                    fontWeight:
                        FontWeight
                            .w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 9,
          ),

          // =================================================
          // Location
          // =================================================

          Row(
            children: [
              const Icon(
                Icons
                    .location_on_outlined,

                color:
                    _AdminDashboardState
                        .textSecondary,

                size: 14,
              ),

              const SizedBox(
                width: 6,
              ),

              Expanded(
                child: Text(
                  location,

                  maxLines: 1,

                  overflow:
                      TextOverflow
                          .ellipsis,

                  style:
                      const TextStyle(
                    color:
                        _AdminDashboardState
                            .textSecondary,

                    fontSize:
                        10,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 6,
          ),

          // =================================================
          // Date
          // =================================================

          Row(
            children: [
              const Icon(
                Icons
                    .calendar_month_outlined,

                color:
                    _AdminDashboardState
                        .textSecondary,

                size: 14,
              ),

              const SizedBox(
                width: 6,
              ),

              Text(
                date,

                style:
                    const TextStyle(
                  color:
                      _AdminDashboardState
                          .textSecondary,

                  fontSize:
                      10,

                  letterSpacing:
                      0.3,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 16,
          ),

          Container(
            height: 1,

            color:
                _AdminDashboardState
                    .borderColor,
          ),

          const SizedBox(
            height: 14,
          ),

          // =================================================
          // Counts
          // =================================================

          Row(
            children: [
              Expanded(
                child:
                    _EventCount(
                  icon:
                      Icons
                          .how_to_reg_rounded,

                  label:
                      'ลงทะเบียน',

                  value:
                      registered,
                ),
              ),

              Container(
                height: 32,
                width: 1,

                color:
                    _AdminDashboardState
                        .borderColor,
              ),

              Expanded(
                child:
                    _EventCount(
                  icon:
                      Icons
                          .location_on_rounded,

                  label:
                      'เช็กอินแล้ว',

                  value:
                      checkedIn,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================
// Event Count
// =============================================================

class _EventCount
    extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;

  const _EventCount({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,

      children: [
        Icon(
          icon,

          color:
              _AdminDashboardState
                  .primaryColor,

          size: 17,
        ),

        const SizedBox(
          width: 7,
        ),

        Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Text(
              '$value',

              style:
                  const TextStyle(
                color:
                    _AdminDashboardState
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
                    _AdminDashboardState
                        .textSecondary,

                fontSize:
                    9,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// =============================================================
// Temporary Admin Pages
// =============================================================

class _AdminPlaceholderPage
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _AdminPlaceholderPage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            Container(
              width: 78,
              height: 78,

              decoration:
                  BoxDecoration(
                color:
                    _AdminDashboardState
                        .primaryColor
                        .withOpacity(
                  0.08,
                ),

                shape:
                    BoxShape.circle,

                border:
                    Border.all(
                  color:
                      _AdminDashboardState
                          .primaryColor
                          .withOpacity(
                    0.20,
                  ),
                ),
              ),

              child: Icon(
                icon,

                color:
                    _AdminDashboardState
                        .primaryColor,

                size: 33,
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            Text(
              title,

              style:
                  const TextStyle(
                color:
                    _AdminDashboardState
                        .textPrimary,

                fontSize:
                    22,

                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 7,
            ),

            Text(
              subtitle,

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                color:
                    _AdminDashboardState
                        .textSecondary,

                fontSize:
                    13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}