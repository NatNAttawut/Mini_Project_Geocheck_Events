import 'package:flutter/material.dart';

import '../../models/user_event.dart';
import '../../services/user_event_service.dart';

import 'user_checkin_screen.dart';
import 'user_event_detail_screen.dart';

class UserCheckinCenterScreen
    extends StatefulWidget {
  const UserCheckinCenterScreen({
    super.key,
  });

  @override
  State<UserCheckinCenterScreen>
      createState() =>
          UserCheckinCenterScreenState();
}

class UserCheckinCenterScreenState
    extends State<UserCheckinCenterScreen> {
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

  static const Color warningColor =
      Color(0xFFFFB74D);

  static const Color dangerColor =
      Color(0xFFFF6262);

  static const Color infoColor =
      Color(0xFF64B5F6);

  // =========================================================
  // State
  // =========================================================

  List<UserEvent> _events = [];

  bool _isLoading = true;

  String _filter = 'all';

  // =========================================================
  // Init
  // =========================================================

  @override
  void initState() {
    super.initState();

    _loadEvents();
  }

  // =========================================================
  // Public Refresh
  // เรียกจาก Bottom Navigation ได้
  // =========================================================

  Future<void> refresh() async {
    await _loadEvents(
      showLoading: false,
    );
  }

  // =========================================================
  // Load
  // =========================================================

  Future<void> _loadEvents({
    bool showLoading = true,
  }) async {
    if (showLoading &&
        mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final result =
        await UserEventService
            .getCheckinCenter();

    if (!mounted) {
      return;
    }

    if (result['success'] ==
        true) {
      final events =
          result['events']
              as List<UserEvent>;

      events.sort(
        _sortEvents,
      );

      setState(() {
        _events = events;
        _isLoading = false;
      });

      return;
    }

    setState(() {
      _isLoading = false;
    });

    _showMessage(
      result['message'] ??
          'ไม่สามารถโหลดข้อมูลเช็กอินได้',

      error: true,
    );
  }

  // =========================================================
  // Status
  // =========================================================

  String _checkinStatus(
    UserEvent event,
  ) {
    if (event.isCheckedIn) {
      return 'checked_in';
    }

    if (event.checkinStartAt ==
            null ||
        event.checkinEndAt ==
            null) {
      return 'unavailable';
    }

    final now =
        DateTime.now();

    final start =
        event.checkinStartAt!;

    final end =
        event.checkinEndAt!;

    if (now.isBefore(start)) {
      return 'upcoming';
    }

    if (!now.isBefore(start) &&
        !now.isAfter(end)) {
      return 'ready';
    }

    return 'missed';
  }

  int _statusWeight(
    UserEvent event,
  ) {
    switch (
        _checkinStatus(event)) {
      case 'ready':
        return 0;

      case 'upcoming':
        return 1;

      case 'checked_in':
        return 2;

      case 'missed':
        return 3;

      default:
        return 4;
    }
  }

  int _sortEvents(
    UserEvent a,
    UserEvent b,
  ) {
    final statusCompare =
        _statusWeight(a)
            .compareTo(
      _statusWeight(b),
    );

    if (statusCompare != 0) {
      return statusCompare;
    }

    return a.startAt.compareTo(
      b.startAt,
    );
  }

  // =========================================================
  // Filter
  // =========================================================

  List<UserEvent>
      get _filteredEvents {
    if (_filter == 'all') {
      return _events;
    }

    return _events.where(
      (event) {
        return _checkinStatus(
              event,
            ) ==
            _filter;
      },
    ).toList();
  }

  int _countStatus(
    String status,
  ) {
    return _events
        .where(
          (event) =>
              _checkinStatus(
                event,
              ) ==
              status,
        )
        .length;
  }

  // =========================================================
  // Open GPS
  // =========================================================

  Future<void> _openCheckin(
    UserEvent event,
  ) async {
    final success =
        await Navigator.push<bool>(
      context,

      MaterialPageRoute(
        builder: (_) =>
            UserCheckinScreen(
          event: event,
        ),
      ),
    );

    if (success == true &&
        mounted) {
      await refresh();
    }
  }

  // =========================================================
  // Open Detail
  // =========================================================

  Future<void> _openDetail(
    UserEvent event,
  ) async {
    await Navigator.push(
      context,

      MaterialPageRoute(
        builder: (_) =>
            UserEventDetailScreen(
          eventId: event.id,
        ),
      ),
    );

    if (mounted) {
      await refresh();
    }
  }

  // =========================================================
  // Build
  // =========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          backgroundColor,

      body: SafeArea(
        child: RefreshIndicator(
          color:
              primaryColor,

          onRefresh:
              refresh,

          child:
              CustomScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),

            slivers: [
              // ===============================================
              // Header
              // ===============================================

              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets
                          .fromLTRB(
                    20,
                    20,
                    20,
                    0,
                  ),

                  child: Row(
                    children: [
                      Container(
                        width: 47,
                        height: 47,

                        decoration:
                            BoxDecoration(
                          color:
                              primaryColor
                                  .withOpacity(
                            0.08,
                          ),

                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),

                          border:
                              Border.all(
                            color:
                                primaryColor
                                    .withOpacity(
                              0.14,
                            ),
                          ),
                        ),

                        child:
                            const Icon(
                          Icons
                              .my_location_rounded,

                          color:
                              primaryColor,

                          size: 23,
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
                              'เช็กอิน',

                              style:
                                  TextStyle(
                                color:
                                    textPrimary,

                                fontSize:
                                    25,

                                fontWeight:
                                    FontWeight
                                        .w800,
                              ),
                            ),

                            SizedBox(
                              height: 2,
                            ),

                            Text(
                              'กิจกรรมที่คุณลงทะเบียนไว้',

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
                      ),

                      IconButton(
                        onPressed:
                            refresh,

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
                ),
              ),

              // ===============================================
              // Ready Highlight
              // ===============================================

              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets
                          .fromLTRB(
                    20,
                    24,
                    20,
                    0,
                  ),

                  child:
                      _buildReadySummary(),
                ),
              ),

              // ===============================================
              // Filters
              // ===============================================

              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets
                          .only(
                    top: 18,
                    bottom: 15,
                  ),

                  child:
                      _buildFilters(),
                ),
              ),

              // ===============================================
              // Loading
              // ===============================================

              if (_isLoading)
                const SliverFillRemaining(
                  hasScrollBody:
                      false,

                  child: Center(
                    child:
                        CircularProgressIndicator(
                      color:
                          primaryColor,
                    ),
                  ),
                )

              // ===============================================
              // Empty
              // ===============================================

              else if (_filteredEvents
                  .isEmpty)
                SliverFillRemaining(
                  hasScrollBody:
                      false,

                  child:
                      _buildEmpty(),
                )

              // ===============================================
              // Events
              // ===============================================

              else
                SliverPadding(
                  padding:
                      const EdgeInsets
                          .fromLTRB(
                    20,
                    0,
                    20,
                    120,
                  ),

                  sliver:
                      SliverList(
                    delegate:
                        SliverChildBuilderDelegate(
                      (
                        context,
                        index,
                      ) {
                        final event =
                            _filteredEvents[
                                index];

                        final status =
                            _checkinStatus(
                          event,
                        );

                        return Padding(
                          padding:
                              const EdgeInsets
                                  .only(
                            bottom: 12,
                          ),

                          child:
                              _CheckinEventCard(
                            event:
                                event,

                            status:
                                status,

                            onTap:
                                () {
                              _openDetail(
                                event,
                              );
                            },

                            onCheckin:
                                () {
                              _openCheckin(
                                event,
                              );
                            },
                          ),
                        );
                      },

                      childCount:
                          _filteredEvents
                              .length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // Ready Summary
  // =========================================================

  Widget _buildReadySummary() {
    final ready =
        _countStatus(
      'ready',
    );

    return Container(
      padding:
          const EdgeInsets.all(
        17,
      ),

      decoration:
          BoxDecoration(
        color:
            ready > 0
                ? primaryColor
                    .withOpacity(
                      0.07,
                    )
                : cardColor,

        borderRadius:
            BorderRadius.circular(
          20,
        ),

        border:
            Border.all(
          color:
              ready > 0
                  ? primaryColor
                      .withOpacity(
                        0.25,
                      )
                  : borderColor,
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 47,
            height: 47,

            decoration:
                BoxDecoration(
              color:
                  ready > 0
                      ? primaryColor
                          .withOpacity(
                            0.12,
                          )
                      : borderColor
                          .withOpacity(
                            0.30,
                          ),

              shape:
                  BoxShape.circle,
            ),

            child: Icon(
              ready > 0
                  ? Icons
                      .radar_rounded
                  : Icons
                      .location_searching_rounded,

              color:
                  ready > 0
                      ? primaryColor
                      : textSecondary,

              size: 23,
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
                  ready > 0
                      ? 'พร้อมเช็กอิน $ready กิจกรรม'
                      : 'ยังไม่มีกิจกรรมที่เช็กอินได้ตอนนี้',

                  style:
                      TextStyle(
                    color:
                        ready > 0
                            ? primaryColor
                            : textPrimary,

                    fontSize:
                        13,

                    fontWeight:
                        FontWeight
                            .w700,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  ready > 0
                      ? 'เลือกกิจกรรมด้านล่างเพื่อตรวจตำแหน่ง GPS'
                      : 'เมื่อถึงเวลาเช็กอิน ระบบจะแสดงปุ่ม GPS ที่นี่',

                  style:
                      const TextStyle(
                    color:
                        textSecondary,

                    fontSize:
                        9,

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
  // Filters
  // =========================================================

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection:
          Axis.horizontal,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
      ),

      child: Row(
        children: [
          _filterButton(
            value: 'all',
            text: 'ทั้งหมด',
            count:
                _events.length,
          ),

          _filterButton(
            value: 'ready',
            text: 'เช็กอินได้',
            count:
                _countStatus(
              'ready',
            ),
          ),

          _filterButton(
            value: 'upcoming',
            text: 'รอเวลา',
            count:
                _countStatus(
              'upcoming',
            ),
          ),

          _filterButton(
            value:
                'checked_in',
            text:
                'เช็กอินแล้ว',
            count:
                _countStatus(
              'checked_in',
            ),
          ),

          _filterButton(
            value: 'missed',
            text: 'หมดเวลา',
            count:
                _countStatus(
              'missed',
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterButton({
    required String value,
    required String text,
    required int count,
  }) {
    final selected =
        _filter == value;

    return Padding(
      padding:
          const EdgeInsets.only(
        right: 8,
      ),

      child: InkWell(
        onTap: () {
          setState(() {
            _filter =
                value;
          });
        },

        borderRadius:
            BorderRadius.circular(
          30,
        ),

        child:
            AnimatedContainer(
          duration:
              const Duration(
            milliseconds: 180,
          ),

          padding:
              const EdgeInsets
                  .symmetric(
            horizontal: 13,
            vertical: 8,
          ),

          decoration:
              BoxDecoration(
            color:
                selected
                    ? primaryColor
                    : cardColor,

            borderRadius:
                BorderRadius.circular(
              30,
            ),

            border:
                Border.all(
              color:
                  selected
                      ? primaryColor
                      : borderColor,
            ),
          ),

          child: Row(
            children: [
              Text(
                text,

                style:
                    TextStyle(
                  color:
                      selected
                          ? backgroundColor
                          : textSecondary,

                  fontSize:
                      9,

                  fontWeight:
                      FontWeight
                          .w600,
                ),
              ),

              if (count > 0) ...[
                const SizedBox(
                  width: 5,
                ),

                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        selected
                            ? backgroundColor
                                .withOpacity(
                                  0.14,
                                )
                            : borderColor,

                    borderRadius:
                        BorderRadius
                            .circular(
                      10,
                    ),
                  ),

                  child: Text(
                    '$count',

                    style:
                        TextStyle(
                      color:
                          selected
                              ? backgroundColor
                              : textPrimary,

                      fontSize: 8,

                      fontWeight:
                          FontWeight
                              .w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // Empty
  // =========================================================

  Widget _buildEmpty() {
    String title =
        'ยังไม่มีกิจกรรม';

    String subtitle =
        'กิจกรรมที่ลงทะเบียนไว้จะแสดงที่นี่';

    if (_filter == 'ready') {
      title =
          'ยังไม่มีกิจกรรมที่เช็กอินได้';

      subtitle =
          'เมื่อถึงช่วงเวลาเช็กอิน กิจกรรมจะแสดงที่นี่';
    }

    if (_filter ==
        'upcoming') {
      title =
          'ไม่มีกิจกรรมที่รอเวลา';

      subtitle =
          'กิจกรรมที่ยังไม่ถึงเวลาเช็กอินจะแสดงที่นี่';
    }

    if (_filter ==
        'checked_in') {
      title =
          'ยังไม่มีการเช็กอิน';

      subtitle =
          'กิจกรรมที่เช็กอินสำเร็จจะแสดงที่นี่';
    }

    if (_filter ==
        'missed') {
      title =
          'ไม่มีรายการหมดเวลา';

      subtitle =
          'ดีมาก คุณไม่มีรายการที่พลาดการเช็กอิน';
    }

    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          30,
        ),

        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            Container(
              width: 75,
              height: 75,

              decoration:
                  BoxDecoration(
                color:
                    primaryColor
                        .withOpacity(
                          0.05,
                        ),

                shape:
                    BoxShape.circle,
              ),

              child:
                  const Icon(
                Icons
                    .my_location_outlined,

                color:
                    textSecondary,

                size: 34,
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            Text(
              title,

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                color:
                    textPrimary,

                fontSize: 14,

                fontWeight:
                    FontWeight
                        .w700,
              ),
            ),

            const SizedBox(
              height: 5,
            ),

            Text(
              subtitle,

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                color:
                    textSecondary,

                fontSize: 9,

                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // Message
  // =========================================================

  void _showMessage(
    String message, {
    bool error = false,
  }) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(
          message,
        ),

        backgroundColor:
            error
                ? const Color(
                    0xFFD94A4A,
                  )
                : const Color(
                    0xFF253512,
                  ),
      ),
    );
  }
}

// =============================================================
// Check-in Event Card
// =============================================================

class _CheckinEventCard
    extends StatelessWidget {
  final UserEvent event;
  final String status;

  final VoidCallback onTap;
  final VoidCallback onCheckin;

  const _CheckinEventCard({
    required this.event,
    required this.status,
    required this.onTap,
    required this.onCheckin,
  });

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

  static const Color warningColor =
      Color(0xFFFFB74D);

  static const Color dangerColor =
      Color(0xFFFF6262);

  static const Color infoColor =
      Color(0xFF64B5F6);

  @override
  Widget build(
    BuildContext context,
  ) {
    final statusInfo =
        _statusInfo();

    return Material(
      color:
          Colors.transparent,

      child: InkWell(
        onTap:
            onTap,

        borderRadius:
            BorderRadius.circular(
          20,
        ),

        child: Container(
          padding:
              const EdgeInsets.all(
            16,
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
                  status == 'ready'
                      ? primaryColor
                          .withOpacity(
                            0.28,
                          )
                      : borderColor,
            ),
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,

            children: [
              // ===============================================
              // Title + Status
              // ===============================================

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [
                  Expanded(
                    child: Text(
                      event.title,

                      style:
                          const TextStyle(
                        color:
                            textPrimary,

                        fontSize: 15,

                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),

                    decoration:
                        BoxDecoration(
                      color:
                          statusInfo.color
                              .withOpacity(
                                0.09,
                              ),

                      borderRadius:
                          BorderRadius
                              .circular(
                        20,
                      ),
                    ),

                    child: Row(
                      mainAxisSize:
                          MainAxisSize
                              .min,

                      children: [
                        Icon(
                          statusInfo.icon,

                          color:
                              statusInfo
                                  .color,

                          size: 11,
                        ),

                        const SizedBox(
                          width: 4,
                        ),

                        Text(
                          statusInfo.text,

                          style:
                              TextStyle(
                            color:
                                statusInfo
                                    .color,

                            fontSize: 8,

                            fontWeight:
                                FontWeight
                                    .w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 12,
              ),

              _infoRow(
                Icons
                    .location_on_outlined,

                event.locationName,
              ),

              const SizedBox(
                height: 7,
              ),

              _infoRow(
                Icons
                    .calendar_month_outlined,

                _formatEventTime(),
              ),

              const SizedBox(
                height: 7,
              ),

              _infoRow(
                Icons
                    .radar_rounded,

                'รัศมี ${event.checkinRadius.toStringAsFixed(0)} เมตร',
              ),

              if (event
                          .checkinStartAt !=
                      null &&
                  event.checkinEndAt !=
                      null) ...[
                const SizedBox(
                  height: 7,
                ),

                _infoRow(
                  Icons
                      .schedule_rounded,

                  'เช็กอิน ${_formatDateTime(event.checkinStartAt!)} - ${_formatTime(event.checkinEndAt!)}',
                ),
              ],

              // ===============================================
              // Checked in result
              // ===============================================

              if (status ==
                  'checked_in') ...[
                const SizedBox(
                  height: 13,
                ),

                Container(
                  width:
                      double.infinity,

                  padding:
                      const EdgeInsets
                          .all(
                    11,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        primaryColor
                            .withOpacity(
                              0.06,
                            ),

                    borderRadius:
                        BorderRadius
                            .circular(
                      12,
                    ),
                  ),

                  child: Wrap(
                    spacing: 15,
                    runSpacing: 6,

                    children: [
                      if (event
                              .checkedInAt !=
                          null)
                        _smallInfo(
                          Icons
                              .check_circle_outline_rounded,

                          'เช็กอิน ${_formatDateTime(event.checkedInAt!)}',
                        ),

                      if (event
                              .checkinDistance !=
                          null)
                        _smallInfo(
                          Icons
                              .straighten_rounded,

                          '${event.checkinDistance!.toStringAsFixed(1)} เมตร',
                        ),
                    ],
                  ),
                ),
              ],

              // ===============================================
              // Action
              // ===============================================

              const SizedBox(
                height: 14,
              ),

              _buildAction(),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // Action
  // =========================================================

  Widget _buildAction() {
    switch (status) {
      case 'ready':
        return SizedBox(
          width:
              double.infinity,

          height: 44,

          child:
              ElevatedButton.icon(
            onPressed:
                onCheckin,

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
                  13,
                ),
              ),
            ),

            icon:
                const Icon(
              Icons
                  .my_location_rounded,

              size: 18,
            ),

            label:
                const Text(
              'เช็กอินด้วย GPS',

              style:
                  TextStyle(
                fontWeight:
                    FontWeight
                        .w700,
              ),
            ),
          ),
        );

      case 'upcoming':
        return _disabledAction(
          icon:
              Icons
                  .schedule_rounded,

          text:
              event.checkinStartAt ==
                      null
                  ? 'ยังไม่ถึงเวลาเช็กอิน'
                  : 'เปิดเช็กอิน ${_formatDateTime(event.checkinStartAt!)}',

          color:
              warningColor,
        );

      case 'checked_in':
        return _disabledAction(
          icon:
              Icons
                  .check_circle_rounded,

          text:
              'เช็กอินเรียบร้อยแล้ว',

          color:
              primaryColor,
        );

      case 'missed':
        return _disabledAction(
          icon:
              Icons
                  .event_busy_rounded,

          text:
              'หมดเวลาเช็กอินแล้ว',

          color:
              dangerColor,
        );

      default:
        return _disabledAction(
          icon:
              Icons
                  .info_outline_rounded,

          text:
              'กิจกรรมนี้ไม่ได้กำหนดเวลาเช็กอิน',

          color:
              textSecondary,
        );
    }
  }

  Widget _disabledAction({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),

      decoration:
          BoxDecoration(
        color:
            color.withOpacity(
          0.06,
        ),

        borderRadius:
            BorderRadius.circular(
          13,
        ),
      ),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          Icon(
            icon,

            color: color,

            size: 16,
          ),

          const SizedBox(
            width: 7,
          ),

          Flexible(
            child: Text(
              text,

              textAlign:
                  TextAlign.center,

              style:
                  TextStyle(
                color: color,

                fontSize: 9,

                fontWeight:
                    FontWeight
                        .w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // Status
  // =========================================================

  _CheckinStatusInfo
      _statusInfo() {
    switch (status) {
      case 'ready':
        return const _CheckinStatusInfo(
          text:
              'เช็กอินได้',

          icon:
              Icons
                  .radar_rounded,

          color:
              primaryColor,
        );

      case 'upcoming':
        return const _CheckinStatusInfo(
          text:
              'รอเวลา',

          icon:
              Icons
                  .schedule_rounded,

          color:
              warningColor,
        );

      case 'checked_in':
        return const _CheckinStatusInfo(
          text:
              'เช็กอินแล้ว',

          icon:
              Icons
                  .check_circle_rounded,

          color:
              primaryColor,
        );

      case 'missed':
        return const _CheckinStatusInfo(
          text:
              'หมดเวลา',

          icon:
              Icons
                  .event_busy_rounded,

          color:
              dangerColor,
        );

      default:
        return const _CheckinStatusInfo(
          text:
              'ไม่กำหนดเวลา',

          icon:
              Icons
                  .info_outline_rounded,

          color:
              textSecondary,
        );
    }
  }

  // =========================================================
  // Info
  // =========================================================

  Widget _infoRow(
    IconData icon,
    String text,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Icon(
          icon,

          color:
              textSecondary,

          size: 14,
        ),

        const SizedBox(
          width: 7,
        ),

        Expanded(
          child: Text(
            text,

            style:
                const TextStyle(
              color:
                  textSecondary,

              fontSize: 9,

              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _smallInfo(
    IconData icon,
    String text,
  ) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,

      children: [
        Icon(
          icon,

          color:
              primaryColor,

          size: 13,
        ),

        const SizedBox(
          width: 5,
        ),

        Text(
          text,

          style:
              const TextStyle(
            color:
                textSecondary,

            fontSize: 9,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // Format Date
  // =========================================================

  String _formatEventTime() {
    final start =
        event.startAt;

    final end =
        event.endAt;

    if (start.year ==
            end.year &&
        start.month ==
            end.month &&
        start.day ==
            end.day) {
      return '${_two(start.day)}/${_two(start.month)}/${start.year} '
          '${_formatTime(start)} - ${_formatTime(end)}';
    }

    return '${_formatDateTime(start)} - ${_formatDateTime(end)}';
  }

  String _formatDateTime(
    DateTime date,
  ) {
    return '${_two(date.day)}/${_two(date.month)}/${date.year} '
        '${_formatTime(date)}';
  }

  String _formatTime(
    DateTime date,
  ) {
    return '${_two(date.hour)}:${_two(date.minute)}';
  }

  String _two(
    int value,
  ) {
    return value
        .toString()
        .padLeft(
          2,
          '0',
        );
  }
}

// =============================================================
// Status Info
// =============================================================

class _CheckinStatusInfo {
  final String text;
  final IconData icon;
  final Color color;

  const _CheckinStatusInfo({
    required this.text,
    required this.icon,
    required this.color,
  });
}