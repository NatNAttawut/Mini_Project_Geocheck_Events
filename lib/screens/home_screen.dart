import 'package:flutter/material.dart';

import '../widgets/geocheck_bottom_nav.dart';
import 'user/user_events_screen.dart';
import 'user/user_history_screen.dart';
import 'user/user_profile_screen.dart';
import 'user/user_home_dashboard.dart';
import 'user/user_checkin_center_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  static const Color backgroundColor = Color(0xFF080D13);

  static const Color cardColor = Color(0xFF101720);

  static const Color fieldColor = Color(0xFF151E28);

  static const Color borderColor = Color(0xFF26313D);

  static const Color primaryColor = Color(0xFFB7F52B);

  static const Color textPrimary = Color(0xFFF3F5F7);

  static const Color textSecondary = Color(0xFF8B98A5);

  void _changePage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: IndexedStack(
        index: _currentIndex,
        children: [
          UserHomeDashboard(
            onOpenEvents: () {
              _changePage(1);
            },
            onOpenHistory: () {
              _changePage(3);
            },
          ),

          const UserEventsScreen(),

          const UserCheckinCenterScreen(),

          const UserHistoryScreen(),

          const UserProfileScreen(),
        ],
      ),

      bottomNavigationBar: GeoCheckBottomNav(
        currentIndex: _currentIndex,
        onTap: _changePage,
      ),
    );
  }
}

// =============================================================
// Home Content
// =============================================================

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  static const Color backgroundColor = Color(0xFF080D13);

  static const Color cardColor = Color(0xFF101720);

  static const Color borderColor = Color(0xFF26313D);

  static const Color primaryColor = Color(0xFFB7F52B);

  static const Color textPrimary = Color(0xFFF3F5F7);

  static const Color textSecondary = Color(0xFF8B98A5);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =================================================
            // Header
            // =================================================
            Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: backgroundColor,
                    size: 25,
                  ),
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GeoCheck',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'EVENT CHECK-IN',
                        style: TextStyle(
                          color: Color(0xFF586572),
                          fontSize: 9,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor),
                  ),
                  child: Stack(
                    children: [
                      const Center(
                        child: Icon(
                          Icons.notifications_none_rounded,
                          color: textPrimary,
                          size: 22,
                        ),
                      ),

                      Positioned(
                        top: 9,
                        right: 10,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // =================================================
            // Welcome
            // =================================================
            const SizedBox(height: 4),

            const Text(
              'GeoCheck Event Check-in',
              style: TextStyle(
                color: textPrimary,
                fontSize: 30,
                height: 1.18,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 24),

            // =================================================
            // Location Hero
            // =================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: borderColor),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    top: -30,
                    child: Container(
                      width: 145,
                      height: 145,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: primaryColor.withOpacity(0.08),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    right: 5,
                    top: -5,
                    child: Container(
                      width: 95,
                      height: 95,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: primaryColor.withOpacity(0.13),
                        ),
                      ),
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.09),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: primaryColor.withOpacity(0.23),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _LiveDot(),
                            SizedBox(width: 7),
                            Text(
                              'LOCATION READY',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      const Text(
                        'พร้อมเช็กอิน',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 23,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        'ค้นหากิจกรรมที่อยู่ใกล้ตำแหน่งของคุณ',
                        style: TextStyle(color: textSecondary, fontSize: 13),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        height: 48,
                        child: FilledButton(
                          onPressed: () {
                            // จะเชื่อมหน้า
                            // Check-in ภายหลัง
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: backgroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.my_location_rounded, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'ค้นหากิจกรรมใกล้ฉัน',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // =================================================
            // Quick Menu
            // =================================================
            const Row(
              children: [
                Expanded(
                  child: Text(
                    'เมนูลัด',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  'GeoCheck',
                  style: TextStyle(color: Color(0xFF4F5B67), fontSize: 11),
                ),
              ],
            ),

            const SizedBox(height: 14),

            const Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.calendar_month_outlined,
                    title: 'กิจกรรม',
                    subtitle: 'ค้นหา',
                  ),
                ),

                SizedBox(width: 12),

                Expanded(
                  child: _QuickAction(
                    icon: Icons.location_on_outlined,
                    title: 'เช็กอิน',
                    subtitle: 'ตำแหน่ง',
                  ),
                ),

                SizedBox(width: 12),

                Expanded(
                  child: _QuickAction(
                    icon: Icons.history_rounded,
                    title: 'ประวัติ',
                    subtitle: 'ย้อนหลัง',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // =================================================
            // Upcoming Event
            // =================================================
            const Row(
              children: [
                Expanded(
                  child: Text(
                    'กิจกรรมที่กำลังจะมาถึง',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                Text(
                  'ดูทั้งหมด',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            const _UpcomingEventCard(),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// Quick Action
// =============================================================

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 10),
      decoration: BoxDecoration(
        color: _HomeContent.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _HomeContent.borderColor),
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _HomeContent.primaryColor.withOpacity(0.09),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: _HomeContent.primaryColor, size: 21),
          ),

          const SizedBox(height: 10),

          Text(
            title,
            style: const TextStyle(
              color: _HomeContent.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            subtitle,
            style: const TextStyle(
              color: _HomeContent.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================
// Upcoming Event Mock Card
// =============================================================

class _UpcomingEventCard extends StatelessWidget {
  const _UpcomingEventCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: _HomeContent.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _HomeContent.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 67,
            decoration: BoxDecoration(
              color: _HomeContent.primaryColor.withOpacity(0.09),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '21',
                  style: TextStyle(
                    color: _HomeContent.primaryColor,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'SEP',
                  style: TextStyle(
                    color: _HomeContent.textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 15),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'กิจกรรมตัวอย่าง',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _HomeContent.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(height: 7),

                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      color: _HomeContent.textSecondary,
                      size: 14,
                    ),
                    SizedBox(width: 5),
                    Text(
                      '09:00 - 12:00',
                      style: TextStyle(
                        color: _HomeContent.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 4),

                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: _HomeContent.textSecondary,
                      size: 14,
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'สถานที่จัดกิจกรรม',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _HomeContent.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Color(0xFF53606D),
            size: 15,
          ),
        ],
      ),
    );
  }
}

// =============================================================
// Empty pages for other navigation tabs
// =============================================================

class _PlaceholderPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PlaceholderPage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: _HomeScreenState.primaryColor.withOpacity(0.09),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _HomeScreenState.primaryColor.withOpacity(0.22),
                ),
              ),
              child: Icon(icon, color: _HomeScreenState.primaryColor, size: 32),
            ),

            const SizedBox(height: 18),

            Text(
              title,
              style: const TextStyle(
                color: _HomeScreenState.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              subtitle,
              style: const TextStyle(
                color: _HomeScreenState.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================
// Animated Location Status
// =============================================================

class _LiveDot extends StatefulWidget {
  const _LiveDot();

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.35,
      upperBound: 1,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          color: _HomeContent.primaryColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
