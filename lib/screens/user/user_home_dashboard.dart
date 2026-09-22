import 'package:flutter/material.dart';

import '../../models/user_home.dart';
import '../../models/user_event.dart';

import '../../services/user_home_service.dart';

import 'user_event_detail_screen.dart';
import 'user_checkin_screen.dart';

class UserHomeDashboard
    extends StatefulWidget {
  final VoidCallback onOpenEvents;
  final VoidCallback onOpenHistory;

  const UserHomeDashboard({
    super.key,
    required this.onOpenEvents,
    required this.onOpenHistory,
  });

  @override
  State<UserHomeDashboard>
      createState() =>
          UserHomeDashboardState();
}

class UserHomeDashboardState
    extends State<UserHomeDashboard> {
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

  UserHomeData? _home;

  bool _isLoading =
      true;

  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {
    super.initState();

    _loadHome();
  }

  // =========================================================
  // PUBLIC REFRESH
  // =========================================================

  Future<void> refreshHome() async {
    await _loadHome(
      showLoading: false,
    );
  }

  // =========================================================
  // LOAD
  // =========================================================

  Future<void> _loadHome({
    bool showLoading = true,
  }) async {
    if (showLoading &&
        mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final result =
        await UserHomeService
            .getHome();

    if (!mounted) {
      return;
    }

    if (result['success'] ==
        true) {
      setState(() {
        _home =
            result['home']
                as UserHomeData;

        _isLoading =
            false;
      });

      return;
    }

    setState(() {
      _isLoading =
          false;
    });

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(
          result['message'] ??
              'ไม่สามารถโหลดหน้าหลักได้',
        ),

        backgroundColor:
            const Color(
          0xFFD94A4A,
        ),
      ),
    );
  }

  // =========================================================
  // EVENT DETAIL
  // =========================================================

  Future<void> _openEvent(
    UserEvent event,
  ) async {
    await Navigator.push(
      context,

      MaterialPageRoute(
        builder: (_) =>
            UserEventDetailScreen(
          eventId:
              event.id,
        ),
      ),
    );

    if (mounted) {
      await refreshHome();
    }
  }

  // =========================================================
  // CHECK-IN
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
          event:
              event,
        ),
      ),
    );

    if (success == true &&
        mounted) {
      await refreshHome();
    }
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    if (_isLoading &&
        _home == null) {
      return const SafeArea(
        child: Center(
          child:
              CircularProgressIndicator(
            color:
                primaryColor,
          ),
        ),
      );
    }

    if (_home == null) {
      return _buildError();
    }

    return SafeArea(
      child:
          RefreshIndicator(
        color:
            primaryColor,

        onRefresh:
            refreshHome,

        child:
            _buildContent(),
      ),
    );
  }

  // =========================================================
  // CONTENT
  // =========================================================

  Widget _buildContent() {
    final home =
        _home!;

    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),

      padding:
          const EdgeInsets.fromLTRB(
        20,
        22,
        20,
        120,
      ),

      children: [
        // =====================================================
        // HEADER
        // =====================================================

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [
                  const Text(
                    'WELCOME BACK',

                    style:
                        TextStyle(
                      color:
                          primaryColor,

                      fontSize:
                          9,

                      letterSpacing:
                          2,

                      fontWeight:
                          FontWeight
                              .w700,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    'สวัสดี ${home.firstname} 👋',

                    style:
                        const TextStyle(
                      color:
                          textPrimary,

                      fontSize:
                          25,

                      fontWeight:
                          FontWeight
                              .w800,
                    ),
                  ),

                  const SizedBox(
                    height: 3,
                  ),

                  const Text(
                    'พร้อมสำหรับกิจกรรมวันนี้หรือยัง?',

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

            Material(
              color:
                  Colors.transparent,

              child:
                  InkWell(
                onTap:
                    refreshHome,

                borderRadius:
                    BorderRadius
                        .circular(
                  14,
                ),

                child:
                    Container(
                  width:
                      43,

                  height:
                      43,

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
                        textSecondary,

                    size:
                        20,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 26,
        ),

        // =====================================================
        // SUMMARY
        // =====================================================

        Row(
          children: [
            Expanded(
              child:
                  _SummaryCard(
                icon:
                    Icons
                        .how_to_reg_rounded,

                value:
                    home
                        .registeredTotal,

                label:
                    'ลงทะเบียน',
              ),
            ),

            const SizedBox(
              width: 9,
            ),

            Expanded(
              child:
                  _SummaryCard(
                icon:
                    Icons
                        .check_circle_rounded,

                value:
                    home
                        .checkedInTotal,

                label:
                    'เช็กอินแล้ว',
              ),
            ),

            const SizedBox(
              width: 9,
            ),

            Expanded(
              child:
                  _SummaryCard(
                icon:
                    Icons
                        .event_available_rounded,

                value:
                    home
                        .upcomingTotal,

                label:
                    'กำลังจะมาถึง',
              ),
            ),
          ],
        ),

        // =====================================================
        // CHECK-IN READY
        // =====================================================

        if (home
            .checkinReadyEvents
            .isNotEmpty) ...[
          const SizedBox(
            height: 26,
          ),

          Row(
            children: [
              Container(
                width:
                    8,

                height:
                    8,

                decoration:
                    const BoxDecoration(
                  color:
                      primaryColor,

                  shape:
                      BoxShape.circle,
                ),
              ),

              const SizedBox(
                width:
                    8,
              ),

              const Expanded(
                child: Text(
                  'พร้อมเช็กอินตอนนี้',

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
                '${home.checkinReadyTotal} กิจกรรม',

                style:
                    const TextStyle(
                  color:
                      primaryColor,

                  fontSize:
                      9,

                  fontWeight:
                      FontWeight
                          .w700,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          ...home
              .checkinReadyEvents
              .take(2)
              .map(
            (event) {
              return Padding(
                padding:
                    const EdgeInsets
                        .only(
                  bottom:
                      10,
                ),

                child:
                    _CheckinReadyCard(
                  event:
                      event,

                  onCheckin:
                      () {
                    _openCheckin(
                      event,
                    );
                  },
                ),
              );
            },
          ),
        ],

        // =====================================================
        // NEXT EVENT
        // =====================================================

        const SizedBox(
          height: 25,
        ),

        Row(
          children: [
            const Expanded(
              child:
                  Text(
                'กิจกรรมถัดไป',

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

            GestureDetector(
              onTap:
                  widget
                      .onOpenHistory,

              child:
                  const Text(
                'ประวัติ',

                style:
                    TextStyle(
                  color:
                      primaryColor,

                  fontSize:
                      10,

                  fontWeight:
                      FontWeight
                          .w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 12,
        ),

        if (home.nextEvent ==
            null)
          _buildNoUpcoming()
        else
          _NextEventCard(
            event:
                home.nextEvent!,

            onTap: () {
              _openEvent(
                home.nextEvent!,
              );
            },
          ),

        // =====================================================
        // OPEN EVENTS
        // =====================================================

        const SizedBox(
          height: 27,
        ),

        Row(
          children: [
            const Expanded(
              child: Text(
                'กิจกรรมที่เปิดรับ',

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
                      10,

                  fontWeight:
                      FontWeight
                          .w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 12,
        ),

        if (home
            .openEvents
            .isEmpty)
          _buildNoOpenEvents()
        else
          ...home.openEvents.map(
            (event) {
              return Padding(
                padding:
                    const EdgeInsets
                        .only(
                  bottom:
                      10,
                ),

                child:
                    _OpenEventCard(
                  event:
                      event,

                  onTap:
                      () {
                    _openEvent(
                      event,
                    );
                  },
                ),
              );
            },
          ),
      ],
    );
  }

  // =========================================================
  // EMPTY
  // =========================================================

  Widget _buildNoUpcoming() {
    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.all(
        20,
      ),

      decoration:
          BoxDecoration(
        color:
            cardColor,

        borderRadius:
            BorderRadius.circular(
          19,
        ),

        border:
            Border.all(
          color:
              borderColor,
        ),
      ),

      child:
          const Row(
        children: [
          Icon(
            Icons
                .event_available_outlined,

            color:
                textSecondary,

            size:
                25,
          ),

          SizedBox(
            width:
                12,
          ),

          Expanded(
            child: Text(
              'ยังไม่มีกิจกรรมที่กำลังจะมาถึง',

              style:
                  TextStyle(
                color:
                    textSecondary,

                fontSize:
                    10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoOpenEvents() {
    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.all(
        20,
      ),

      decoration:
          BoxDecoration(
        color:
            cardColor,

        borderRadius:
            BorderRadius.circular(
          19,
        ),

        border:
            Border.all(
          color:
              borderColor,
        ),
      ),

      child:
          const Text(
        'ขณะนี้ยังไม่มีกิจกรรมใหม่ที่เปิดรับสมัคร',

        textAlign:
            TextAlign.center,

        style:
            TextStyle(
          color:
              textSecondary,

          fontSize:
              10,
        ),
      ),
    );
  }

  // =========================================================
  // ERROR
  // =========================================================

  Widget _buildError() {
    return SafeArea(
      child:
          ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),

        children: [
          SizedBox(
            height:
                MediaQuery.of(context)
                        .size
                        .height *
                    0.65,

            child:
                Center(
              child:
                  Column(
                mainAxisSize:
                    MainAxisSize.min,

                children: [
                  const Icon(
                    Icons
                        .cloud_off_rounded,

                    color:
                        textSecondary,

                    size:
                        42,
                  ),

                  const SizedBox(
                    height:
                        12,
                  ),

                  const Text(
                    'ไม่สามารถโหลดหน้าหลักได้',

                    style:
                        TextStyle(
                      color:
                          textPrimary,

                      fontWeight:
                          FontWeight
                              .w700,
                    ),
                  ),

                  const SizedBox(
                    height:
                        8,
                  ),

                  TextButton(
                    onPressed:
                        () {
                      _loadHome();
                    },

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
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// SUMMARY
// =============================================================

class _SummaryCard
    extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;

  const _SummaryCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        vertical:
            15,

        horizontal:
            5,
      ),

      decoration:
          BoxDecoration(
        color:
            UserHomeDashboardState
                .cardColor,

        borderRadius:
            BorderRadius.circular(
          17,
        ),

        border:
            Border.all(
          color:
              UserHomeDashboardState
                  .borderColor,
        ),
      ),

      child:
          Column(
        children: [
          Icon(
            icon,

            color:
                UserHomeDashboardState
                    .primaryColor,

            size:
                18,
          ),

          const SizedBox(
            height:
                6,
          ),

          Text(
            '$value',

            style:
                const TextStyle(
              color:
                  UserHomeDashboardState
                      .textPrimary,

              fontSize:
                  20,

              fontWeight:
                  FontWeight
                      .w800,
            ),
          ),

          const SizedBox(
            height:
                2,
          ),

          Text(
            label,

            textAlign:
                TextAlign.center,

            style:
                const TextStyle(
              color:
                  UserHomeDashboardState
                      .textSecondary,

              fontSize:
                  8,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// CHECK-IN READY
// =============================================================

class _CheckinReadyCard
    extends StatelessWidget {
  final UserEvent event;
  final VoidCallback onCheckin;

  const _CheckinReadyCard({
    required this.event,
    required this.onCheckin,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(
        16,
      ),

      decoration:
          BoxDecoration(
        color:
            UserHomeDashboardState
                .primaryColor
                .withOpacity(
                  0.06,
                ),

        borderRadius:
            BorderRadius.circular(
          20,
        ),

        border:
            Border.all(
          color:
              UserHomeDashboardState
                  .primaryColor
                  .withOpacity(
                    0.25,
                  ),
        ),
      ),

      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            event.title,

            style:
                const TextStyle(
              color:
                  UserHomeDashboardState
                      .textPrimary,

              fontSize:
                  15,

              fontWeight:
                  FontWeight
                      .w700,
            ),
          ),

          const SizedBox(
            height:
                6,
          ),

          Row(
            children: [
              const Icon(
                Icons
                    .location_on_outlined,

                color:
                    UserHomeDashboardState
                        .textSecondary,

                size:
                    14,
              ),

              const SizedBox(
                width:
                    5,
              ),

              Expanded(
                child:
                    Text(
                  event
                      .locationName,

                  style:
                      const TextStyle(
                    color:
                        UserHomeDashboardState
                            .textSecondary,

                    fontSize:
                        9,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height:
                14,
          ),

          SizedBox(
            width:
                double.infinity,

            height:
                43,

            child:
                ElevatedButton.icon(
              onPressed:
                  onCheckin,

              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    UserHomeDashboardState
                        .primaryColor,

                foregroundColor:
                    UserHomeDashboardState
                        .backgroundColor,

                elevation:
                    0,

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

                size:
                    18,
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
          ),
        ],
      ),
    );
  }
}

// =============================================================
// NEXT EVENT
// =============================================================

class _NextEventCard
    extends StatelessWidget {
  final UserEvent event;
  final VoidCallback onTap;

  const _NextEventCard({
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Material(
      color:
          Colors.transparent,

      child:
          InkWell(
        onTap:
            onTap,

        borderRadius:
            BorderRadius.circular(
          21,
        ),

        child:
            Container(
          padding:
              const EdgeInsets.all(
            17,
          ),

          decoration:
              BoxDecoration(
            color:
                UserHomeDashboardState
                    .cardColor,

            borderRadius:
                BorderRadius.circular(
              21,
            ),

            border:
                Border.all(
              color:
                  UserHomeDashboardState
                      .primaryColor
                      .withOpacity(
                        0.20,
                      ),
            ),
          ),

          child:
              Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              const Row(
                children: [
                  Icon(
                    Icons
                        .bookmark_added_rounded,

                    color:
                        UserHomeDashboardState
                            .primaryColor,

                    size:
                        16,
                  ),

                  SizedBox(
                    width:
                        6,
                  ),

                  Text(
                    'ลงทะเบียนแล้ว',

                    style:
                        TextStyle(
                      color:
                          UserHomeDashboardState
                              .primaryColor,

                      fontSize:
                          9,

                      fontWeight:
                          FontWeight
                              .w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height:
                    11,
              ),

              Text(
                event.title,

                style:
                    const TextStyle(
                  color:
                      UserHomeDashboardState
                          .textPrimary,

                  fontSize:
                      16,

                  fontWeight:
                      FontWeight
                          .w700,
                ),
              ),

              const SizedBox(
                height:
                    10,
              ),

              _HomeEventInfo(
                icon:
                    Icons
                        .location_on_outlined,

                text:
                    event
                        .locationName,
              ),

              const SizedBox(
                height:
                    7,
              ),

              _HomeEventInfo(
                icon:
                    Icons
                        .calendar_month_outlined,

                text:
                    _formatDate(
                  event.startAt,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================
// OPEN EVENT
// =============================================================

class _OpenEventCard
    extends StatelessWidget {
  final UserEvent event;
  final VoidCallback onTap;

  const _OpenEventCard({
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final participantText =
        event.maxParticipants ==
                null
            ? '${event.registeredCount} คนลงทะเบียน'
            : '${event.registeredCount}/${event.maxParticipants} คน';

    return Material(
      color:
          Colors.transparent,

      child:
          InkWell(
        onTap:
            onTap,

        borderRadius:
            BorderRadius.circular(
          18,
        ),

        child:
            Container(
          padding:
              const EdgeInsets.all(
            15,
          ),

          decoration:
              BoxDecoration(
            color:
                UserHomeDashboardState
                    .cardColor,

            borderRadius:
                BorderRadius.circular(
              18,
            ),

            border:
                Border.all(
              color:
                  UserHomeDashboardState
                      .borderColor,
            ),
          ),

          child:
              Row(
            children: [
              Container(
                width:
                    47,

                height:
                    47,

                decoration:
                    BoxDecoration(
                  color:
                      UserHomeDashboardState
                          .primaryColor
                          .withOpacity(
                            0.08,
                          ),

                  borderRadius:
                      BorderRadius
                          .circular(
                    13,
                  ),
                ),

                child:
                    const Icon(
                  Icons
                      .event_rounded,

                  color:
                      UserHomeDashboardState
                          .primaryColor,

                  size:
                      22,
                ),
              ),

              const SizedBox(
                width:
                    12,
              ),

              Expanded(
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    Text(
                      event.title,

                      maxLines:
                          1,

                      overflow:
                          TextOverflow
                              .ellipsis,

                      style:
                          const TextStyle(
                        color:
                            UserHomeDashboardState
                                .textPrimary,

                        fontSize:
                            13,

                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),

                    const SizedBox(
                      height:
                          4,
                    ),

                    Text(
                      _formatDate(
                        event
                            .startAt,
                      ),

                      style:
                          const TextStyle(
                        color:
                            UserHomeDashboardState
                                .textSecondary,

                        fontSize:
                            9,
                      ),
                    ),

                    const SizedBox(
                      height:
                          2,
                    ),

                    Text(
                      participantText,

                      style:
                          const TextStyle(
                        color:
                            UserHomeDashboardState
                                .textSecondary,

                        fontSize:
                            8,
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
                    14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================
// EVENT INFO
// =============================================================

class _HomeEventInfo
    extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HomeEventInfo({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      children: [
        Icon(
          icon,

          color:
              UserHomeDashboardState
                  .primaryColor,

          size:
              14,
        ),

        const SizedBox(
          width:
              6,
        ),

        Expanded(
          child:
              Text(
            text,

            maxLines:
                1,

            overflow:
                TextOverflow.ellipsis,

            style:
                const TextStyle(
              color:
                  UserHomeDashboardState
                      .textSecondary,

              fontSize:
                  9,
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================
// FORMAT DATE
// =============================================================

String _formatDate(
  DateTime date,
) {
  String two(
    int number,
  ) {
    return number
        .toString()
        .padLeft(
          2,
          '0',
        );
  }

  return '${two(date.day)}/${two(date.month)}/${date.year} '
      '${two(date.hour)}:${two(date.minute)}';
}