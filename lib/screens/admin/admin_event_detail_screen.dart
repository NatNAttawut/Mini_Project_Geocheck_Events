import 'package:flutter/material.dart';

import '../../models/admin_event_detail.dart';
import '../../services/admin_event_service.dart';

class AdminEventDetailScreen
    extends StatefulWidget {
  final int eventId;

  const AdminEventDetailScreen({
    super.key,
    required this.eventId,
  });

  @override
  State<AdminEventDetailScreen>
      createState() =>
          _AdminEventDetailScreenState();
}

class _AdminEventDetailScreenState
    extends State<
        AdminEventDetailScreen> {
  // =========================================================
  // Colors
  // =========================================================

  static const Color backgroundColor =
      Color(0xFF080D13);

  static const Color cardColor =
      Color(0xFF101720);

  static const Color fieldColor =
      Color(0xFF151E28);

  static const Color borderColor =
      Color(0xFF26313D);

  static const Color primaryColor =
      Color(0xFFB7F52B);

  static const Color textPrimary =
      Color(0xFFF3F5F7);

  static const Color textSecondary =
      Color(0xFF8B98A5);

  static const Color dangerColor =
      Color(0xFFFF6262);

  // =========================================================
  // State
  // =========================================================

  final TextEditingController
      _searchController =
      TextEditingController();

  AdminEventDetail? _detail;

  bool _isLoading = true;

  String _filter = 'all';

  // =========================================================
  // Init
  // =========================================================

  @override
  void initState() {
    super.initState();

    _loadDetail();

    _searchController
        .addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  // =========================================================
  // Load
  // =========================================================

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
    });

    final result =
        await AdminEventService
            .getEventDetail(
      widget.eventId,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      setState(() {
        _detail =
            result['detail']
                as AdminEventDetail;
      });

      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          result['message'] ??
              'ไม่สามารถโหลดรายละเอียดกิจกรรมได้',
        ),
        backgroundColor:
            const Color(
          0xFFD94A4A,
        ),
      ),
    );
  }

  // =========================================================
  // Filtered Participants
  // =========================================================

  List<EventParticipant>
      get _participants {
    if (_detail == null) {
      return [];
    }

    Iterable<EventParticipant>
        result =
        _detail!.participants;

    if (_filter == 'checked') {
      result = result.where(
        (item) =>
            item.checkedIn,
      );
    }

    if (_filter == 'pending') {
      result = result.where(
        (item) =>
            !item.checkedIn,
      );
    }

    final search =
        _searchController.text
            .trim()
            .toLowerCase();

    if (search.isNotEmpty) {
      result = result.where(
        (item) {
          return item.fullName
                  .toLowerCase()
                  .contains(
                    search,
                  ) ||
              item.email
                  .toLowerCase()
                  .contains(
                    search,
                  ) ||
              (item.studentId ?? '')
                  .toLowerCase()
                  .contains(
                    search,
                  );
        },
      );
    }

    return result.toList();
  }

  // =========================================================
  // Build
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          backgroundColor,

      appBar: AppBar(
        backgroundColor:
            backgroundColor,

        elevation: 0,

        leading:
            IconButton(
          onPressed: () {
            Navigator.pop(
              context,
            );
          },

          icon:
              const Icon(
            Icons
                .arrow_back_ios_new_rounded,

            color:
                textPrimary,

            size:
                20,
          ),
        ),

        title:
            const Text(
          'รายละเอียดกิจกรรม',

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

        actions: [
          IconButton(
            onPressed:
                _loadDetail,

            icon:
                const Icon(
              Icons
                  .refresh_rounded,

              color:
                  textPrimary,
            ),
          ),
        ],
      ),

      body: _isLoading &&
              _detail == null
          ? const Center(
              child:
                  CircularProgressIndicator(
                color:
                    primaryColor,
              ),
            )
          : _detail == null
              ? _buildError()
              : RefreshIndicator(
                  color:
                      primaryColor,

                  onRefresh:
                      _loadDetail,

                  child:
                      _buildContent(),
                ),
    );
  }

  // =========================================================
  // Content
  // =========================================================

  Widget _buildContent() {
    final detail =
        _detail!;

    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),

      padding:
          const EdgeInsets.fromLTRB(
        20,
        10,
        20,
        35,
      ),

      children: [
        // =====================================================
        // Event Header
        // =====================================================

        Container(
          padding:
              const EdgeInsets.all(
            18,
          ),

          decoration:
              BoxDecoration(
            color:
                cardColor,

            borderRadius:
                BorderRadius.circular(
              22,
            ),

            border:
                Border.all(
              color:
                  borderColor,
            ),
          ),

          child:
              Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [
                  Expanded(
                    child:
                        Text(
                      detail.title,

                      style:
                          const TextStyle(
                        color:
                            textPrimary,

                        fontSize:
                            20,

                        height:
                            1.25,

                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  _statusBadge(
                    detail.status,
                  ),
                ],
              ),

              if (detail.description !=
                      null &&
                  detail
                      .description!
                      .isNotEmpty) ...[
                const SizedBox(
                  height: 10,
                ),

                Text(
                  detail.description!,

                  style:
                      const TextStyle(
                    color:
                        textSecondary,

                    fontSize:
                        11,

                    height:
                        1.5,
                  ),
                ),
              ],

              const SizedBox(
                height: 18,
              ),

              _infoRow(
                Icons
                    .location_on_outlined,

                detail.locationName,
              ),

              const SizedBox(
                height: 10,
              ),

              _infoRow(
                Icons
                    .calendar_month_outlined,

                '${_formatDateTime(detail.startAt)} - ${_formatTime(detail.endAt)}',
              ),

              const SizedBox(
                height: 10,
              ),

              _infoRow(
                Icons.radar_rounded,

                'รัศมีเช็กอิน ${detail.checkinRadius} เมตร',
              ),

              if (detail.maxParticipants !=
                  null) ...[
                const SizedBox(
                  height: 10,
                ),

                _infoRow(
                  Icons
                      .groups_2_outlined,

                  'รองรับสูงสุด ${detail.maxParticipants} คน',
                ),
              ],

              if (detail.checkinStartAt !=
                      null &&
                  detail.checkinEndAt !=
                      null) ...[
                const SizedBox(
                  height: 10,
                ),

                _infoRow(
                  Icons
                      .location_searching_rounded,

                  'เช็กอิน ${_formatDateTime(detail.checkinStartAt!)} - ${_formatTime(detail.checkinEndAt!)}',
                ),
              ],
            ],
          ),
        ),

        const SizedBox(
          height: 22,
        ),

        // =====================================================
        // Summary
        // =====================================================

        const Text(
          'สรุปผู้เข้าร่วม',

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
          height: 12,
        ),

        Row(
          children: [
            Expanded(
              child:
                  _SummaryCard(
                icon:
                    Icons
                        .how_to_reg_rounded,

                value:
                    detail
                        .registeredCount,

                title:
                    'ลงทะเบียน',
              ),
            ),

            const SizedBox(
              width: 8,
            ),

            Expanded(
              child:
                  _SummaryCard(
                icon:
                    Icons
                        .location_on_rounded,

                value:
                    detail
                        .checkinCount,

                title:
                    'เช็กอินแล้ว',

                highlight:
                    true,
              ),
            ),

            const SizedBox(
              width: 8,
            ),

            Expanded(
              child:
                  _SummaryCard(
                icon:
                    Icons
                        .schedule_rounded,

                value:
                    detail
                        .pendingCount,

                title:
                    'ยังไม่มา',
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 26,
        ),

        // =====================================================
        // Participant Header
        // =====================================================

        Row(
          children: [
            const Expanded(
              child:
                  Text(
                'ผู้ลงทะเบียน',

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
              '${detail.registeredCount} คน',

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
          height: 12,
        ),

        // =====================================================
        // Search
        // =====================================================

        TextField(
          controller:
              _searchController,

          style:
              const TextStyle(
            color:
                textPrimary,

            fontSize:
                13,
          ),

          decoration:
              InputDecoration(
            hintText:
                'ค้นหาชื่อ อีเมล หรือรหัสนักศึกษา',

            hintStyle:
                const TextStyle(
              color:
                  Color(
                0xFF596673,
              ),

              fontSize:
                  11,
            ),

            prefixIcon:
                const Icon(
              Icons
                  .search_rounded,

              color:
                  textSecondary,
            ),

            suffixIcon:
                _searchController
                        .text
                        .isNotEmpty
                    ? IconButton(
                        onPressed:
                            () {
                          _searchController
                              .clear();
                        },

                        icon:
                            const Icon(
                          Icons
                              .close_rounded,

                          color:
                              textSecondary,
                        ),
                      )
                    : null,

            filled:
                true,

            fillColor:
                fieldColor,

            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius
                      .circular(
                16,
              ),

              borderSide:
                  BorderSide.none,
            ),

            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius
                      .circular(
                16,
              ),

              borderSide:
                  const BorderSide(
                color:
                    borderColor,
              ),
            ),

            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius
                      .circular(
                16,
              ),

              borderSide:
                  const BorderSide(
                color:
                    primaryColor,
              ),
            ),
          ),
        ),

        const SizedBox(
          height: 12,
        ),

        // =====================================================
        // Filters
        // =====================================================

        SingleChildScrollView(
          scrollDirection:
              Axis.horizontal,

          child:
              Row(
            children: [
              _filterButton(
                value:
                    'all',

                text:
                    'ทั้งหมด',
              ),

              _filterButton(
                value:
                    'checked',

                text:
                    'เช็กอินแล้ว',
              ),

              _filterButton(
                value:
                    'pending',

                text:
                    'ยังไม่เช็กอิน',
              ),
            ],
          ),
        ),

        const SizedBox(
          height: 15,
        ),

        // =====================================================
        // Participants
        // =====================================================

        if (_participants.isEmpty)
          _buildEmptyParticipants()
        else
          ..._participants.map(
            (participant) {
              return Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 10,
                ),

                child:
                    _ParticipantCard(
                  participant:
                      participant,
                ),
              );
            },
          ),
      ],
    );
  }

  // =========================================================
  // Filter Button
  // =========================================================

  Widget _filterButton({
    required String value,
    required String text,
  }) {
    final selected =
        _filter == value;

    return Padding(
      padding:
          const EdgeInsets.only(
        right: 8,
      ),

      child:
          GestureDetector(
        onTap: () {
          setState(() {
            _filter =
                value;
          });
        },

        child:
            AnimatedContainer(
          duration:
              const Duration(
            milliseconds:
                180,
          ),

          padding:
              const EdgeInsets
                  .symmetric(
            horizontal:
                14,

            vertical:
                8,
          ),

          decoration:
              BoxDecoration(
            color: selected
                ? primaryColor
                : cardColor,

            borderRadius:
                BorderRadius
                    .circular(
              30,
            ),

            border:
                Border.all(
              color: selected
                  ? primaryColor
                  : borderColor,
            ),
          ),

          child:
              Text(
            text,

            style:
                TextStyle(
              color: selected
                  ? backgroundColor
                  : textSecondary,

              fontSize:
                  10,

              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // Status
  // =========================================================

  Widget _statusBadge(
    String status,
  ) {
    String text;

    switch (status) {
      case 'open':
        text =
            'เปิดรับ';
        break;

      case 'closed':
        text =
            'ปิดรับ';
        break;

      case 'completed':
        text =
            'เสร็จสิ้น';
        break;

      case 'cancelled':
        text =
            'ยกเลิก';
        break;

      default:
        text =
            'แบบร่าง';
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal:
            10,

        vertical:
            5,
      ),

      decoration:
          BoxDecoration(
        color:
            primaryColor
                .withOpacity(
          0.08,
        ),

        borderRadius:
            BorderRadius.circular(
          30,
        ),
      ),

      child:
          Text(
        text,

        style:
            const TextStyle(
          color:
              primaryColor,

          fontSize:
              9,

          fontWeight:
              FontWeight.w700,
        ),
      ),
    );
  }

  // =========================================================
  // Info Row
  // =========================================================

  Widget _infoRow(
    IconData icon,
    String value,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Icon(
          icon,

          color:
              primaryColor,

          size:
              17,
        ),

        const SizedBox(
          width: 8,
        ),

        Expanded(
          child:
              Text(
            value,

            style:
                const TextStyle(
              color:
                  textSecondary,

              fontSize:
                  11,

              height:
                  1.4,
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // Empty
  // =========================================================

  Widget _buildEmptyParticipants() {
    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets.symmetric(
        vertical:
            40,

        horizontal:
            20,
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
                .person_search_rounded,

            color:
                textSecondary,

            size:
                40,
          ),

          SizedBox(
            height: 12,
          ),

          Text(
            'ไม่พบผู้เข้าร่วม',

            style:
                TextStyle(
              color:
                  textPrimary,

              fontWeight:
                  FontWeight.w700,
            ),
          ),

          SizedBox(
            height: 4,
          ),

          Text(
            'กิจกรรมนี้อาจยังไม่มีผู้ลงทะเบียน',

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
  // Error
  // =========================================================

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
                dangerColor,

            size:
                45,
          ),

          const SizedBox(
            height: 12,
          ),

          const Text(
            'ไม่สามารถโหลดข้อมูลกิจกรรมได้',

            style:
                TextStyle(
              color:
                  textPrimary,
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          TextButton(
            onPressed:
                _loadDetail,

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

  // =========================================================
  // Date
  // =========================================================

  String _formatDateTime(
    DateTime date,
  ) {
    return '${_two(date.day)}/${_two(date.month)}/${date.year} '
        '${_two(date.hour)}:${_two(date.minute)}';
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
// Summary Card
// =============================================================

class _SummaryCard
    extends StatelessWidget {
  final IconData icon;
  final int value;
  final String title;
  final bool highlight;

  const _SummaryCard({
    required this.icon,
    required this.value,
    required this.title,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 14,
      ),

      decoration:
          BoxDecoration(
        color:
            _AdminEventDetailScreenState
                .cardColor,

        borderRadius:
            BorderRadius.circular(
          17,
        ),

        border:
            Border.all(
          color: highlight
              ? _AdminEventDetailScreenState
                  .primaryColor
                  .withOpacity(
                    0.30,
                  )
              : _AdminEventDetailScreenState
                  .borderColor,
        ),
      ),

      child:
          Column(
        children: [
          Icon(
            icon,

            color:
                _AdminEventDetailScreenState
                    .primaryColor,

            size:
                19,
          ),

          const SizedBox(
            height: 7,
          ),

          Text(
            '$value',

            style:
                const TextStyle(
              color:
                  _AdminEventDetailScreenState
                      .textPrimary,

              fontSize:
                  20,

              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 2,
          ),

          Text(
            title,

            textAlign:
                TextAlign.center,

            style:
                const TextStyle(
              color:
                  _AdminEventDetailScreenState
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
// Participant Card
// =============================================================

class _ParticipantCard
    extends StatelessWidget {
  final EventParticipant
      participant;

  const _ParticipantCard({
    required this.participant,
  });

  @override
  Widget build(BuildContext context) {
    const primary =
        _AdminEventDetailScreenState
            .primaryColor;

    return Container(
      padding:
          const EdgeInsets.all(
        15,
      ),

      decoration:
          BoxDecoration(
        color:
            _AdminEventDetailScreenState
                .cardColor,

        borderRadius:
            BorderRadius.circular(
          18,
        ),

        border:
            Border.all(
          color:
              participant.checkedIn
                  ? primary
                      .withOpacity(
                        0.20,
                      )
                  : _AdminEventDetailScreenState
                      .borderColor,
        ),
      ),

      child:
          Column(
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // ===============================================
              // Avatar
              // ===============================================

              Container(
                width: 47,
                height: 47,

                alignment:
                    Alignment.center,

                decoration:
                    BoxDecoration(
                  color:
                      primary.withOpacity(
                    0.10,
                  ),

                  borderRadius:
                      BorderRadius
                          .circular(
                    14,
                  ),
                ),

                child:
                    Text(
                  participant.initials,

                  style:
                      const TextStyle(
                    color:
                        primary,

                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              // ===============================================
              // User
              // ===============================================

              Expanded(
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    Text(
                      participant
                          .fullName,

                      style:
                          const TextStyle(
                        color:
                            _AdminEventDetailScreenState
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
                      participant
                          .email,

                      style:
                          const TextStyle(
                        color:
                            _AdminEventDetailScreenState
                                .textSecondary,

                        fontSize:
                            10,
                      ),
                    ),

                    if (participant
                                .studentId !=
                            null &&
                        participant
                            .studentId!
                            .isNotEmpty) ...[
                      const SizedBox(
                        height: 3,
                      ),

                      Text(
                        'รหัสนักศึกษา ${participant.studentId}',

                        style:
                            const TextStyle(
                          color:
                              Color(
                            0xFF667481,
                          ),

                          fontSize:
                              9,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              // ===============================================
              // Status
              // ===============================================

              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal:
                      8,

                  vertical:
                      5,
                ),

                decoration:
                    BoxDecoration(
                  color: participant
                          .checkedIn
                      ? primary
                          .withOpacity(
                            0.08,
                          )
                      : const Color(
                          0xFFFFB74D,
                        ).withOpacity(
                          0.08,
                        ),

                  borderRadius:
                      BorderRadius
                          .circular(
                    20,
                  ),
                ),

                child:
                    Row(
                  mainAxisSize:
                      MainAxisSize.min,

                  children: [
                    Icon(
                      participant
                              .checkedIn
                          ? Icons
                              .check_circle_rounded
                          : Icons
                              .schedule_rounded,

                      color: participant
                              .checkedIn
                          ? primary
                          : const Color(
                              0xFFFFB74D,
                            ),

                      size:
                          12,
                    ),

                    const SizedBox(
                      width: 4,
                    ),

                    Text(
                      participant
                              .checkedIn
                          ? 'เช็กอินแล้ว'
                          : 'ยังไม่เช็กอิน',

                      style:
                          TextStyle(
                        color: participant
                                .checkedIn
                            ? primary
                            : const Color(
                                0xFFFFB74D,
                              ),

                        fontSize:
                            8,

                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // =================================================
          // Check-in Detail
          // =================================================

          if (participant.checkedIn) ...[
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
                    const Color(
                  0xFF0C131A,
                ),

                borderRadius:
                    BorderRadius
                        .circular(
                  12,
                ),
              ),

              child:
                  Wrap(
                spacing:
                    14,

                runSpacing:
                    7,

                children: [
                  if (participant
                          .checkedInAt !=
                      null)
                    _CheckinInfo(
                      icon:
                          Icons
                              .schedule_rounded,

                      text:
                          _formatCheckin(
                        participant
                            .checkedInAt!,
                      ),
                    ),

                  if (participant
                          .distanceMeters !=
                      null)
                    _CheckinInfo(
                      icon:
                          Icons
                              .straighten_rounded,

                      text:
                          '${participant.distanceMeters!.toStringAsFixed(1)} เมตร',
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatCheckin(
    DateTime date,
  ) {
    String two(
      int value,
    ) =>
        value
            .toString()
            .padLeft(
              2,
              '0',
            );

    return '${two(date.day)}/${two(date.month)}/${date.year} '
        '${two(date.hour)}:${two(date.minute)}';
  }
}

class _CheckinInfo
    extends StatelessWidget {
  final IconData icon;
  final String text;

  const _CheckinInfo({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,

      children: [
        const SizedBox(
          width: 0,
        ),

        Icon(
          icon,

          color:
              _AdminEventDetailScreenState
                  .primaryColor,

          size:
              14,
        ),

        const SizedBox(
          width: 5,
        ),

        Text(
          text,

          style:
              const TextStyle(
            color:
                _AdminEventDetailScreenState
                    .textSecondary,

            fontSize:
                9,
          ),
        ),
      ],
    );
  }
}