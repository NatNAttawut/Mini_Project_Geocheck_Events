import 'package:flutter/material.dart';

import '../../models/user_history.dart';
import '../../services/user_event_service.dart';

class UserHistoryScreen
    extends StatefulWidget {
  const UserHistoryScreen({
    super.key,
  });

  @override
  State<UserHistoryScreen>
      createState() =>
          _UserHistoryScreenState();
}

class _UserHistoryScreenState
    extends State<UserHistoryScreen> {
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

  // =========================================================
  // State
  // =========================================================

  List<UserHistoryItem> _history = [];

  bool _isLoading = true;

  String _filter = 'all';

  // =========================================================
  // Init
  // =========================================================

  @override
  void initState() {
    super.initState();

    _loadHistory();
  }

  // =========================================================
  // Load
  // =========================================================

  Future<void> _loadHistory({
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
            .getHistory();

    if (!mounted) {
      return;
    }

    if (result['success'] == true) {
      setState(() {
        _history =
            result['history']
                as List<
                    UserHistoryItem>;

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
              'ไม่สามารถโหลดประวัติได้',
        ),

        backgroundColor:
            const Color(
          0xFFD94A4A,
        ),
      ),
    );
  }

  // =========================================================
  // Filter
  // =========================================================

  List<UserHistoryItem>
      get _filteredHistory {
    if (_filter == 'all') {
      return _history;
    }

    return _history.where(
      (item) {
        return item.historyStatus ==
            _filter;
      },
    ).toList();
  }

  // =========================================================
  // Build
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          backgroundColor,

      body: SafeArea(
        child:
            RefreshIndicator(
          color:
              primaryColor,

          onRefresh: () =>
              _loadHistory(
            showLoading:
                false,
          ),

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
                        width: 46,
                        height: 46,

                        decoration:
                            BoxDecoration(
                          color:
                              primaryColor
                                  .withOpacity(
                            0.09,
                          ),

                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
                        ),

                        child:
                            const Icon(
                          Icons
                              .history_rounded,

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
                              'ประวัติ',

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
                              'กิจกรรมที่คุณลงทะเบียนและเข้าร่วม',

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
                        onPressed: () {
                          _loadHistory(
                            showLoading:
                                false,
                          );
                        },

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
              // Summary
              // ===============================================

              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets
                          .fromLTRB(
                    20,
                    25,
                    20,
                    0,
                  ),

                  child:
                      _buildSummary(),
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
                    bottom: 16,
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

              else if (_filteredHistory
                  .isEmpty)
                SliverFillRemaining(
                  hasScrollBody:
                      false,

                  child:
                      _buildEmpty(),
                )

              // ===============================================
              // List
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
                        final item =
                            _filteredHistory[
                                index];

                        return Padding(
                          padding:
                              const EdgeInsets
                                  .only(
                            bottom: 12,
                          ),

                          child:
                              _HistoryCard(
                            item:
                                item,
                          ),
                        );
                      },

                      childCount:
                          _filteredHistory
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
  // Summary
  // =========================================================

  Widget _buildSummary() {
    final checked =
        _history
            .where(
              (item) =>
                  item.historyStatus ==
                  'checked_in',
            )
            .length;

    final upcoming =
        _history
            .where(
              (item) =>
                  item.historyStatus ==
                  'upcoming' ||
                  item.historyStatus ==
                  'waiting',
            )
            .length;

    final missed =
        _history
            .where(
              (item) =>
                  item.historyStatus ==
                  'missed',
            )
            .length;

    return Row(
      children: [
        Expanded(
          child: _SummaryItem(
            value:
                checked,

            label:
                'เข้าร่วมแล้ว',

            icon:
                Icons
                    .check_circle_rounded,
          ),
        ),

        const SizedBox(
          width: 9,
        ),

        Expanded(
          child: _SummaryItem(
            value:
                upcoming,

            label:
                'กำลังจะมาถึง',

            icon:
                Icons
                    .event_available_rounded,
          ),
        ),

        const SizedBox(
          width: 9,
        ),

        Expanded(
          child: _SummaryItem(
            value:
                missed,

            label:
                'พลาดเช็กอิน',

            icon:
                Icons
                    .event_busy_rounded,
          ),
        ),
      ],
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
            value:
                'all',

            text:
                'ทั้งหมด',
          ),

          _filterButton(
            value:
                'checked_in',

            text:
                'เช็กอินแล้ว',
          ),

          _filterButton(
            value:
                'upcoming',

            text:
                'กำลังจะมาถึง',
          ),

          _filterButton(
            value:
                'missed',

            text:
                'พลาดเช็กอิน',
          ),
        ],
      ),
    );
  }

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

      child: GestureDetector(
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
              25,
            ),

            border:
                Border.all(
              color: selected
                  ? primaryColor
                  : borderColor,
            ),
          ),

          child: Text(
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
  // Empty
  // =========================================================

  Widget _buildEmpty() {
    return Center(
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
                0.06,
              ),

              shape:
                  BoxShape.circle,
            ),

            child:
                const Icon(
              Icons
                  .history_toggle_off_rounded,

              color:
                  textSecondary,

              size:
                  35,
            ),
          ),

          const SizedBox(
            height: 15,
          ),

          const Text(
            'ยังไม่มีประวัติ',

            style:
                TextStyle(
              color:
                  textPrimary,

              fontSize:
                  15,

              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          const Text(
            'กิจกรรมที่คุณลงทะเบียนจะแสดงที่นี่',

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
}

// =============================================================
// Summary Item
// =============================================================

class _SummaryItem
    extends StatelessWidget {
  final int value;
  final String label;
  final IconData icon;

  const _SummaryItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        vertical:
            15,

        horizontal:
            6,
      ),

      decoration:
          BoxDecoration(
        color:
            _UserHistoryScreenState
                .cardColor,

        borderRadius:
            BorderRadius.circular(
          17,
        ),

        border:
            Border.all(
          color:
              _UserHistoryScreenState
                  .borderColor,
        ),
      ),

      child: Column(
        children: [
          Icon(
            icon,

            color:
                _UserHistoryScreenState
                    .primaryColor,

            size: 18,
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            '$value',

            style:
                const TextStyle(
              color:
                  _UserHistoryScreenState
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
            label,

            textAlign:
                TextAlign.center,

            style:
                const TextStyle(
              color:
                  _UserHistoryScreenState
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
// History Card
// =============================================================

class _HistoryCard
    extends StatelessWidget {
  final UserHistoryItem item;

  const _HistoryCard({
    required this.item,
  });

  static const Color primaryColor =
      Color(0xFFB7F52B);

  static const Color warningColor =
      Color(0xFFFFB74D);

  static const Color dangerColor =
      Color(0xFFFF6262);

  static const Color textSecondary =
      Color(0xFF8B98A5);

  @override
  Widget build(BuildContext context) {
    final status =
        _statusInfo();

    return Container(
      padding:
          const EdgeInsets.all(
        17,
      ),

      decoration:
          BoxDecoration(
        color:
            _UserHistoryScreenState
                .cardColor,

        borderRadius:
            BorderRadius.circular(
          20,
        ),

        border:
            Border.all(
          color:
              item.isCheckedIn
                  ? primaryColor
                      .withOpacity(
                        0.20,
                      )
                  : _UserHistoryScreenState
                      .borderColor,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Expanded(
                child: Text(
                  item.title,

                  style:
                      const TextStyle(
                    color:
                        _UserHistoryScreenState
                            .textPrimary,

                    fontSize:
                        15,

                    fontWeight:
                        FontWeight.w700,
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
                  horizontal: 9,
                  vertical: 5,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      status.color
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
                      MainAxisSize.min,

                  children: [
                    Icon(
                      status.icon,

                      color:
                          status.color,

                      size: 11,
                    ),

                    const SizedBox(
                      width: 4,
                    ),

                    Text(
                      status.text,

                      style:
                          TextStyle(
                        color:
                            status.color,

                        fontSize:
                            8,

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

          _info(
            Icons
                .location_on_outlined,

            item.locationName,
          ),

          const SizedBox(
            height: 7,
          ),

          _info(
            Icons
                .calendar_month_outlined,

            _formatEventDate(),
          ),

          if (item.isCheckedIn) ...[
            const SizedBox(
              height: 14,
            ),

            Container(
              width:
                  double.infinity,

              padding:
                  const EdgeInsets
                      .all(
                12,
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
                  13,
                ),
              ),

              child: Wrap(
                spacing: 18,
                runSpacing: 8,

                children: [
                  if (item.checkedInAt !=
                      null)
                    _smallInfo(
                      Icons
                          .schedule_rounded,

                      'เช็กอิน ${_formatDateTime(item.checkedInAt!)}',
                    ),

                  if (item.distanceMeters !=
                      null)
                    _smallInfo(
                      Icons
                          .straighten_rounded,

                      '${item.distanceMeters!.toStringAsFixed(1)} เมตร',
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _info(
    IconData icon,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,

          color:
              primaryColor,

          size: 15,
        ),

        const SizedBox(
          width: 7,
        ),

        Expanded(
          child: Text(
            value,

            style:
                const TextStyle(
              color:
                  textSecondary,

              fontSize:
                  10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _smallInfo(
    IconData icon,
    String value,
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
          value,

          style:
              const TextStyle(
            color:
                textSecondary,

            fontSize:
                9,
          ),
        ),
      ],
    );
  }

  _HistoryStatus _statusInfo() {
    switch (item.historyStatus) {
      case 'checked_in':
        return const _HistoryStatus(
          text:
              'เข้าร่วมแล้ว',

          icon:
              Icons
                  .check_circle_rounded,

          color:
              primaryColor,
        );

      case 'upcoming':
        return const _HistoryStatus(
          text:
              'กำลังจะมาถึง',

          icon:
              Icons
                  .event_available_rounded,

          color:
              warningColor,
        );

      case 'waiting':
        return const _HistoryStatus(
          text:
              'รอเช็กอิน',

          icon:
              Icons
                  .schedule_rounded,

          color:
              warningColor,
        );

      case 'missed':
        return const _HistoryStatus(
          text:
              'พลาดเช็กอิน',

          icon:
              Icons
                  .event_busy_rounded,

          color:
              dangerColor,
        );

      case 'cancelled':
        return const _HistoryStatus(
          text:
              'ยกเลิก',

          icon:
              Icons
                  .cancel_outlined,

          color:
              textSecondary,
        );

      default:
        return const _HistoryStatus(
          text:
              'ลงทะเบียนแล้ว',

          icon:
              Icons
                  .how_to_reg_rounded,

          color:
              warningColor,
        );
    }
  }

  String _formatEventDate() {
    if (item.startAt.year ==
            item.endAt.year &&
        item.startAt.month ==
            item.endAt.month &&
        item.startAt.day ==
            item.endAt.day) {
      return '${_two(item.startAt.day)}/${_two(item.startAt.month)}/${item.startAt.year} '
          '${_two(item.startAt.hour)}:${_two(item.startAt.minute)}'
          ' - '
          '${_two(item.endAt.hour)}:${_two(item.endAt.minute)}';
    }

    return '${_formatDateTime(item.startAt)} - ${_formatDateTime(item.endAt)}';
  }

  String _formatDateTime(
    DateTime date,
  ) {
    return '${_two(date.day)}/${_two(date.month)}/${date.year} '
        '${_two(date.hour)}:${_two(date.minute)}';
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
// History Status
// =============================================================

class _HistoryStatus {
  final String text;
  final IconData icon;
  final Color color;

  const _HistoryStatus({
    required this.text,
    required this.icon,
    required this.color,
  });
}