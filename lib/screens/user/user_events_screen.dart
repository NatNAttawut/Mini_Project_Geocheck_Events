import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/user_event.dart';
import '../../services/user_event_service.dart';
import 'user_event_detail_screen.dart';

class UserEventsScreen extends StatefulWidget {
  const UserEventsScreen({super.key});

  @override
  State<UserEventsScreen> createState() => _UserEventsScreenState();
}

class _UserEventsScreenState extends State<UserEventsScreen> {
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

  // =========================================================
  // State
  // =========================================================

  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;

  List<UserEvent> _events = [];

  String _status = 'all';

  bool _isLoading = true;

  // =========================================================
  // Init
  // =========================================================

  @override
  void initState() {
    super.initState();

    _loadEvents();

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();

    _searchController.dispose();

    super.dispose();
  }

  // =========================================================
  // Search
  // =========================================================

  void _onSearchChanged() {
    _searchDebounce?.cancel();

    setState(() {});

    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      _loadEvents(showLoading: false);
    });
  }

  // =========================================================
  // Load
  // =========================================================

  Future<void> _loadEvents({bool showLoading = true}) async {
    if (showLoading && mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final result = await UserEventService.getEvents(
      search: _searchController.text,

      status: _status,
    );

    if (!mounted) {
      return;
    }

    if (result['success'] == true) {
      setState(() {
        _events = result['events'] as List<UserEvent>;

        _isLoading = false;
      });

      return;
    }

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] ?? 'ไม่สามารถโหลดกิจกรรมได้'),

        backgroundColor: const Color(0xFFD94A4A),
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

      body: SafeArea(
        child: RefreshIndicator(
          color: primaryColor,

          onRefresh: () => _loadEvents(showLoading: false),

          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),

            slivers: [
              // ===============================================
              // Header
              // ===============================================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),

                  child: _buildHeader(),
                ),
              ),

              // ===============================================
              // Search
              // ===============================================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),

                  child: _buildSearch(),
                ),
              ),

              // ===============================================
              // Filters
              // ===============================================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 13, bottom: 20),

                  child: _buildFilters(),
                ),
              ),

              // ===============================================
              // Loading
              // ===============================================
              if (_isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,

                  child: Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  ),
                )
              // ===============================================
              // Empty
              // ===============================================
              else if (_events.isEmpty)
                SliverFillRemaining(hasScrollBody: false, child: _buildEmpty())
              // ===============================================
              // Events
              // ===============================================
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),

                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final event = _events[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 13),

                        child: _EventCard(
                          event: event,

                          onTap: () async {
                            final changed = await Navigator.push<bool>(
                              context,

                              MaterialPageRoute(
                                builder: (_) =>
                                    UserEventDetailScreen(eventId: event.id),
                              ),
                            );

                            if (changed == true && mounted) {
                              _loadEvents(showLoading: false);
                            }
                          },
                        ),
                      );
                    }, childCount: _events.length),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // Header
  // =========================================================

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,

      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                'กิจกรรม',

                style: TextStyle(
                  color: textPrimary,

                  fontSize: 27,

                  fontWeight: FontWeight.w800,
                ),
              ),

              SizedBox(height: 3),

              Text(
                'ค้นหาและเลือกกิจกรรมที่คุณสนใจ',

                style: TextStyle(color: textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.08),

            borderRadius: BorderRadius.circular(20),
          ),

          child: Text(
            '${_events.length} กิจกรรม',

            style: const TextStyle(
              color: primaryColor,

              fontSize: 9,

              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // Search
  // =========================================================

  Widget _buildSearch() {
    return TextField(
      controller: _searchController,

      style: const TextStyle(color: textPrimary, fontSize: 13),

      decoration: InputDecoration(
        hintText: 'ค้นหาชื่อกิจกรรมหรือสถานที่',

        hintStyle: const TextStyle(color: Color(0xFF596673), fontSize: 11),

        prefixIcon: const Icon(Icons.search_rounded, color: textSecondary),

        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  _searchController.clear();
                },

                icon: const Icon(Icons.close_rounded, color: textSecondary),
              ),

        filled: true,

        fillColor: fieldColor,

        contentPadding: const EdgeInsets.symmetric(vertical: 16),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),

          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),

          borderSide: const BorderSide(color: borderColor),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),

          borderSide: const BorderSide(color: primaryColor),
        ),
      ),
    );
  }

  // =========================================================
  // Filters
  // =========================================================

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,

      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: Row(
        children: [
          _filterChip(value: 'all', text: 'ทั้งหมด'),

          _filterChip(value: 'open', text: 'เปิดรับสมัคร'),

          _filterChip(value: 'closed', text: 'ปิดรับสมัคร'),

          _filterChip(value: 'completed', text: 'เสร็จสิ้น'),
        ],
      ),
    );
  }

  Widget _filterChip({required String value, required String text}) {
    final selected = _status == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),

      child: GestureDetector(
        onTap: () {
          if (_status == value) {
            return;
          }

          setState(() {
            _status = value;
          });

          _loadEvents();
        },

        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),

          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),

          decoration: BoxDecoration(
            color: selected ? primaryColor : cardColor,

            borderRadius: BorderRadius.circular(30),

            border: Border.all(color: selected ? primaryColor : borderColor),
          ),

          child: Text(
            text,

            style: TextStyle(
              color: selected ? backgroundColor : textSecondary,

              fontSize: 10,

              fontWeight: FontWeight.w600,
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
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Container(
              width: 75,
              height: 75,

              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.07),

                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.event_busy_outlined,

                color: textSecondary,

                size: 34,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'ไม่พบกิจกรรม',

              style: TextStyle(
                color: textPrimary,

                fontSize: 16,

                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'ลองค้นหาใหม่หรือเลือกสถานะอื่น',

              textAlign: TextAlign.center,

              style: TextStyle(color: textSecondary, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // Temporary Detail
  // =========================================================

  void _showNextStepMessage() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ขั้นต่อไปเราจะทำหน้ารายละเอียดกิจกรรม')),
    );
  }
}

// =============================================================
// Event Card
// =============================================================

class _EventCard extends StatelessWidget {
  final UserEvent event;

  final VoidCallback onTap;

  const _EventCard({required this.event, required this.onTap});

  static const Color cardColor = Color(0xFF101720);

  static const Color borderColor = Color(0xFF26313D);

  static const Color primaryColor = Color(0xFFB7F52B);

  static const Color textPrimary = Color(0xFFF3F5F7);

  static const Color textSecondary = Color(0xFF8B98A5);

  @override
  Widget build(BuildContext context) {
    final availableText = _availableText();

    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(21),

        child: Container(
          padding: const EdgeInsets.all(17),

          decoration: BoxDecoration(
            color: cardColor,

            borderRadius: BorderRadius.circular(21),

            border: Border.all(
              color: event.isRegistered
                  ? primaryColor.withOpacity(0.25)
                  : borderColor,
            ),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ===============================================
              // Status + Registered
              // ===============================================
              Row(
                children: [
                  _statusBadge(),

                  if (event.isRegistered) ...[
                    const SizedBox(width: 7),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),

                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.08),

                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: const Row(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          Icon(
                            Icons.check_circle_rounded,

                            color: primaryColor,

                            size: 11,
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

                  const Spacer(),

                  const Icon(
                    Icons.arrow_forward_ios_rounded,

                    color: Color(0xFF596673),

                    size: 14,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ===============================================
              // Title
              // ===============================================
              Text(
                event.title,

                maxLines: 2,

                overflow: TextOverflow.ellipsis,

                style: const TextStyle(
                  color: textPrimary,

                  fontSize: 17,

                  height: 1.3,

                  fontWeight: FontWeight.w700,
                ),
              ),

              if (event.description != null &&
                  event.description!.trim().isNotEmpty) ...[
                const SizedBox(height: 6),

                Text(
                  event.description!,

                  maxLines: 2,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    color: textSecondary,

                    fontSize: 10,

                    height: 1.4,
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // ===============================================
              // Location
              // ===============================================
              _infoRow(Icons.location_on_outlined, event.locationName),

              const SizedBox(height: 9),

              // ===============================================
              // Date
              // ===============================================
              _infoRow(Icons.calendar_month_outlined, _formatEventDate()),

              const SizedBox(height: 9),

              // ===============================================
              // Participants
              // ===============================================
              _infoRow(Icons.groups_2_outlined, availableText),

              const SizedBox(height: 15),

              Container(height: 1, color: borderColor),

              const SizedBox(height: 13),

              // ===============================================
              // Footer
              // ===============================================
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event.maxParticipants == null
                          ? 'ลงทะเบียนแล้ว ${event.registeredCount} คน'
                          : '${event.registeredCount}/${event.maxParticipants} คน',

                      style: const TextStyle(
                        color: textSecondary,

                        fontSize: 10,
                      ),
                    ),
                  ),

                  Text(
                    event.isFull ? 'เต็มแล้ว' : 'ดูรายละเอียด',

                    style: TextStyle(
                      color: event.isFull
                          ? const Color(0xFFFFB74D)
                          : primaryColor,

                      fontSize: 10,

                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // Status
  // =========================================================

  Widget _statusBadge() {
    String text;

    Color color;

    switch (event.status) {
      case 'open':
        text = 'เปิดรับสมัคร';

        color = primaryColor;

        break;

      case 'closed':
        text = 'ปิดรับสมัคร';

        color = const Color(0xFFFFB74D);

        break;

      case 'completed':
        text = 'เสร็จสิ้น';

        color = textSecondary;

        break;

      default:
        text = event.status;

        color = textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),

      decoration: BoxDecoration(
        color: color.withOpacity(0.09),

        borderRadius: BorderRadius.circular(20),
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
  // Info
  // =========================================================

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Icon(icon, color: primaryColor, size: 16),

        const SizedBox(width: 8),

        Expanded(
          child: Text(
            text,

            maxLines: 2,

            overflow: TextOverflow.ellipsis,

            style: const TextStyle(
              color: textSecondary,

              fontSize: 10,

              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // Available
  // =========================================================

  String _availableText() {
    if (event.maxParticipants == null) {
      return 'ไม่จำกัดจำนวนผู้เข้าร่วม';
    }

    if (event.isFull) {
      return 'ผู้เข้าร่วมเต็มแล้ว';
    }

    return 'เหลือ ${event.remainingSlots} ที่นั่ง จาก ${event.maxParticipants} คน';
  }

  // =========================================================
  // Date
  // =========================================================

  String _formatEventDate() {
    final start = event.startAt;

    final end = event.endAt;

    final sameDay =
        start.year == end.year &&
        start.month == end.month &&
        start.day == end.day;

    if (sameDay) {
      return '${_two(start.day)}/${_two(start.month)}/${start.year} '
          '${_two(start.hour)}:${_two(start.minute)}'
          ' - '
          '${_two(end.hour)}:${_two(end.minute)}';
    }

    return '${_formatDate(start)} - ${_formatDate(end)}';
  }

  String _formatDate(DateTime date) {
    return '${_two(date.day)}/${_two(date.month)}/${date.year} '
        '${_two(date.hour)}:${_two(date.minute)}';
  }

  String _two(int value) {
    return value.toString().padLeft(2, '0');
  }
}
