import 'package:flutter/material.dart';

class GeoCheckBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const GeoCheckBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<GeoCheckBottomNav> createState() => _GeoCheckBottomNavState();
}

class _GeoCheckBottomNavState extends State<GeoCheckBottomNav> {
  static const Color backgroundColor = Color(0xFF080D13);
  static const Color navColor = Color(0xFF101720);
  static const Color borderColor = Color(0xFF26313D);

  static const Color primaryColor = Color(0xFFB7F52B);
  static const Color iconColor = Color(0xFF7D8995);
  static const Color textColor = Color(0xFFF3F5F7);

  final List<_NavItem> items = const [
    _NavItem(
      icon: Icons.home_rounded,
      label: 'หน้าหลัก',
    ),
    _NavItem(
      icon: Icons.calendar_month_outlined,
      label: 'กิจกรรม',
    ),
    _NavItem(
      icon: Icons.location_searching_rounded,
      label: 'เช็กอิน',
    ),
    _NavItem(
      icon: Icons.history_rounded,
      label: 'ประวัติ',
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      label: 'โปรไฟล์',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: backgroundColor,
        padding: const EdgeInsets.fromLTRB(
          14,
          0,
          14,
          12,
        ),
        child: SizedBox(
          height: 92,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth =
                  constraints.maxWidth / items.length;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // =================================================
                  // Navigation Background
                  // =================================================

                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 72,
                    child: Container(
                      decoration: BoxDecoration(
                        color: navColor,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: borderColor,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.35),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // =================================================
                  // Selected Floating Circle
                  // =================================================

                  AnimatedPositioned(
                    duration:
                        const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    left:
                        (itemWidth * widget.currentIndex) +
                            ((itemWidth - 58) / 2),
                    top: 0,
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor,
                        border: Border.all(
                          color: backgroundColor,
                          width: 6,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                primaryColor.withOpacity(0.20),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        items[widget.currentIndex].icon,
                        color: backgroundColor,
                        size: 25,
                      ),
                    ),
                  ),

                  // =================================================
                  // Menu Items
                  // =================================================

                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 72,
                    child: Row(
                      children: List.generate(
                        items.length,
                        (index) {
                          final item = items[index];

                          final selected =
                              widget.currentIndex == index;

                          return Expanded(
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.circular(20),
                              onTap: () {
                                widget.onTap(index);
                              },
                              child: SizedBox(
                                height: 72,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // ---------------------------------
                                    // Normal Icon
                                    // ---------------------------------

                                    AnimatedPositioned(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      curve: Curves.easeOutCubic,
                                      top: selected ? 30 : 17,
                                      child: AnimatedOpacity(
                                        duration: const Duration(
                                          milliseconds: 180,
                                        ),
                                        opacity:
                                            selected ? 0 : 1,
                                        child: Icon(
                                          item.icon,
                                          color: iconColor,
                                          size: 23,
                                        ),
                                      ),
                                    ),

                                    // ---------------------------------
                                    // Selected Label
                                    // ---------------------------------

                                    AnimatedPositioned(
                                      duration: const Duration(
                                        milliseconds: 280,
                                      ),
                                      curve: Curves.easeOutCubic,
                                      bottom: selected ? 8 : 0,
                                      child: AnimatedOpacity(
                                        duration: const Duration(
                                          milliseconds: 250,
                                        ),
                                        opacity:
                                            selected ? 1 : 0,
                                        child: Text(
                                          item.label,
                                          style: const TextStyle(
                                            color: primaryColor,
                                            fontSize: 11,
                                            fontWeight:
                                                FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.label,
  });
}