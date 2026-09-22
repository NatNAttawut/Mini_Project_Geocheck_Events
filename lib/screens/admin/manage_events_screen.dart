import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/admin_event.dart';
import '../../services/admin_event_service.dart';
import 'admin_event_detail_screen.dart';

import 'event_form_screen.dart';

class ManageEventsScreen extends StatefulWidget {
  const ManageEventsScreen({super.key});

  @override
  State<ManageEventsScreen> createState() => _ManageEventsScreenState();
}

class _ManageEventsScreenState extends State<ManageEventsScreen> {
  static const backgroundColor = Color(0xFF080D13);

  static const cardColor = Color(0xFF101720);

  static const fieldColor = Color(0xFF151E28);

  static const borderColor = Color(0xFF26313D);

  static const primaryColor = Color(0xFFB7F52B);

  static const textPrimary = Color(0xFFF3F5F7);

  static const textSecondary = Color(0xFF8B98A5);

  final _searchController = TextEditingController();

  Timer? _searchTimer;

  List<AdminEvent> _events = [];

  bool _isLoading = true;

  String _status = 'all';

  @override
  void initState() {
    super.initState();

    _loadEvents();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchController.dispose();

    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });

    final result = await AdminEventService.getEvents(
      search: _searchController.text,
      status: _status,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      setState(() {
        _events = result['events'] as List<AdminEvent>;
      });

      return;
    }

    _showMessage(result['message'] ?? 'โหลดข้อมูลไม่สำเร็จ', error: true);
  }

  void _onSearchChanged(String value) {
    _searchTimer?.cancel();

    _searchTimer = Timer(const Duration(milliseconds: 450), _loadEvents);
  }

  Future<void> _openEventForm({AdminEvent? event}) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EventFormScreen(event: event)),
    );

    if (changed == true) {
      _loadEvents();
    }
  }

  Future<void> _deleteEvent(AdminEvent event) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: cardColor,

          title: const Text('ลบกิจกรรม?', style: TextStyle(color: textPrimary)),

          content: Text(
            'ต้องการลบ "${event.title}" หรือไม่?\n\nข้อมูลการลงทะเบียนและเช็กอินของกิจกรรมนี้จะถูกลบด้วย',
            style: const TextStyle(color: textSecondary, height: 1.5),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('ยกเลิก'),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'ลบกิจกรรม',
                style: TextStyle(color: Color(0xFFFF6262)),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    final result = await AdminEventService.deleteEvent(event.id);

    if (!mounted) {
      return;
    }

    _showMessage(result['message'] ?? '', error: result['success'] != true);

    if (result['success'] == true) {
      _loadEvents();
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        foregroundColor: backgroundColor,
        onPressed: () {
          _openEventForm();
        },
        child: const Icon(Icons.add_rounded),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =========================================
                  // Header
                  // =========================================
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.event_note_rounded,
                          color: primaryColor,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'จัดการกิจกรรม',
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${_events.length} กิจกรรม',
                              style: const TextStyle(
                                color: textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // =========================================
                  // Search
                  // =========================================
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(color: textPrimary),
                    decoration: InputDecoration(
                      hintText: 'ค้นหากิจกรรม หรือสถานที่',
                      hintStyle: const TextStyle(
                        color: Color(0xFF596673),
                        fontSize: 12,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: textSecondary,
                      ),
                      filled: true,
                      fillColor: fieldColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: borderColor),
                      ),
                    ),
                  ),

                  const SizedBox(height: 13),

                  // =========================================
                  // Status Filter
                  // =========================================
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filter('all', 'ทั้งหมด'),
                        _filter('draft', 'แบบร่าง'),
                        _filter('open', 'เปิดรับ'),
                        _filter('closed', 'ปิดรับ'),
                        _filter('completed', 'เสร็จสิ้น'),
                        _filter('cancelled', 'ยกเลิก'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    )
                  : _events.isEmpty
                  ? _empty()
                  : RefreshIndicator(
                      color: primaryColor,
                      onRefresh: _loadEvents,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                        itemCount: _events.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final event = _events[index];

                          return _eventCard(event);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filter(String value, String text) {
    final selected = _status == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _status = value;
          });

          _loadEvents();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? primaryColor : cardColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: selected ? primaryColor : borderColor),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: selected ? backgroundColor : textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _eventCard(AdminEvent event) {
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminEventDetailScreen(eventId: event.id),
          ),
        );

        if (mounted) {
          _loadEvents();
        }

        // Step ต่อไป:
        // Event Detail
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                PopupMenuButton<String>(
                  color: cardColor,
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: textSecondary,
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _openEventForm(event: event);
                    }

                    if (value == 'delete') {
                      _deleteEvent(event);
                    }
                  },
                  itemBuilder: (_) {
                    return const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text(
                          'แก้ไขกิจกรรม',
                          style: TextStyle(color: textPrimary),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'ลบกิจกรรม',
                          style: TextStyle(color: Color(0xFFFF6262)),
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),

            const SizedBox(height: 10),

            _info(Icons.location_on_outlined, event.locationName),

            const SizedBox(height: 6),

            _info(Icons.calendar_month_outlined, _formatDate(event.startAt)),

            const SizedBox(height: 15),

            Row(
              children: [
                _statusBadge(event.status),

                const Spacer(),

                const Icon(
                  Icons.how_to_reg_rounded,
                  color: primaryColor,
                  size: 16,
                ),

                const SizedBox(width: 5),

                Text(
                  '${event.registeredCount}',
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(width: 14),

                const Icon(
                  Icons.location_on_rounded,
                  color: primaryColor,
                  size: 16,
                ),

                const SizedBox(width: 5),

                Text(
                  '${event.checkinCount}',
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: textSecondary, size: 15),

        const SizedBox(width: 7),

        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: textSecondary, fontSize: 11),
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(String status) {
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: primaryColor,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');

    return '${two(date.day)}/${two(date.month)}/${date.year}  '
        '${two(date.hour)}:${two(date.minute)}';
  }

  Widget _empty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_busy_rounded, color: primaryColor, size: 52),

          SizedBox(height: 14),

          Text(
            'ยังไม่มีกิจกรรม',
            style: TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 5),

          Text(
            'กด + เพื่อสร้างกิจกรรมใหม่',
            style: TextStyle(color: textSecondary),
          ),
        ],
      ),
    );
  }
}
