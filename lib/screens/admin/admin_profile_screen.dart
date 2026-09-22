import 'package:flutter/material.dart';

import '../../models/admin_profile.dart';
import '../../services/admin_profile_service.dart';
import '../../services/auth_service.dart';

import '../login_screen.dart';
import 'admin_access_screen.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => AdminProfileScreenState();
}

class AdminProfileScreenState extends State<AdminProfileScreen> {
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

  static const Color dangerColor = Color(0xFFFF6262);

  // =========================================================
  // State
  // =========================================================

  AdminProfile? _profile;

  bool _isLoading = true;

  // =========================================================
  // Init
  // =========================================================

  @override
  void initState() {
    super.initState();

    _loadProfile();
  }

  // =========================================================
  // Public Refresh
  // =========================================================

  Future<void> refresh() async {
    await _loadProfile(showLoading: false);
  }

  // =========================================================
  // Load
  // =========================================================

  Future<void> _loadProfile({bool showLoading = true}) async {
    if (showLoading && mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final result = await AdminProfileService.getProfile();

    if (!mounted) {
      return;
    }

    if (result['success'] == true) {
      setState(() {
        _profile = result['profile'] as AdminProfile;

        _isLoading = false;
      });

      return;
    }

    setState(() {
      _isLoading = false;
    });

    _showMessage(result['message'] ?? 'ไม่สามารถโหลดข้อมูลได้', error: true);
  }

  // =========================================================
  // Edit Profile
  // =========================================================

  Future<void> _showEditProfile() async {
    if (_profile == null) {
      return;
    }

    final firstnameController = TextEditingController(
      text: _profile!.firstname,
    );

    final lastnameController = TextEditingController(text: _profile!.lastname);

    final formKey = GlobalKey<FormState>();

    bool saving = false;

    String? apiError;

    final changed = await showModalBottomSheet<bool>(
      context: context,

      isScrollControlled: true,

      backgroundColor: cardColor,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),

      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,

                bottom: MediaQuery.of(context).viewInsets.bottom + 25,
              ),

              child: SingleChildScrollView(
                child: Form(
                  key: formKey,

                  child: Column(
                    mainAxisSize: MainAxisSize.min,

                    crossAxisAlignment: CrossAxisAlignment.stretch,

                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,

                          decoration: BoxDecoration(
                            color: borderColor,

                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Row(
                        children: [
                          Icon(
                            Icons.admin_panel_settings_outlined,

                            color: primaryColor,
                          ),

                          SizedBox(width: 9),

                          Text(
                            'แก้ไขข้อมูลผู้ดูแลระบบ',

                            style: TextStyle(
                              color: textPrimary,

                              fontSize: 19,

                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      _textField(
                        controller: firstnameController,

                        label: 'ชื่อ',

                        icon: Icons.person_outline_rounded,

                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'กรุณากรอกชื่อ';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      _textField(
                        controller: lastnameController,

                        label: 'นามสกุล',

                        icon: Icons.badge_outlined,

                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'กรุณากรอกนามสกุล';
                          }

                          return null;
                        },
                      ),

                      if (apiError != null) ...[
                        const SizedBox(height: 14),

                        _errorBox(apiError!),
                      ],

                      const SizedBox(height: 22),

                      SizedBox(
                        height: 52,

                        child: ElevatedButton(
                          onPressed: saving
                              ? null
                              : () async {
                                  setSheetState(() {
                                    apiError = null;
                                  });

                                  if (!formKey.currentState!.validate()) {
                                    return;
                                  }

                                  setSheetState(() {
                                    saving = true;
                                  });

                                  final result =
                                      await AdminProfileService.updateProfile(
                                        firstname: firstnameController.text,

                                        lastname: lastnameController.text,
                                      );

                                  if (!mounted) {
                                    return;
                                  }

                                  if (result['success'] == true) {
                                    Navigator.pop(sheetContext, true);

                                    return;
                                  }

                                  setSheetState(() {
                                    saving = false;

                                    apiError =
                                        result['message'] ??
                                        'ไม่สามารถแก้ไขข้อมูลได้';
                                  });
                                },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,

                            foregroundColor: backgroundColor,

                            elevation: 0,

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),

                          child: saving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,

                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,

                                    color: backgroundColor,
                                  ),
                                )
                              : const Text(
                                  'บันทึกการแก้ไข',

                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    firstnameController.dispose();

    lastnameController.dispose();

    if (changed == true && mounted) {
      _showMessage('แก้ไขข้อมูลเรียบร้อยแล้ว');

      await refresh();
    }
  }

  // =========================================================
  // Change Password
  // =========================================================

  Future<void> _showChangePassword() async {
    final currentController = TextEditingController();

    final newController = TextEditingController();

    final confirmController = TextEditingController();

    final formKey = GlobalKey<FormState>();

    bool saving = false;

    bool obscureCurrent = true;

    bool obscureNew = true;

    bool obscureConfirm = true;

    String? apiError;

    final changed = await showModalBottomSheet<bool>(
      context: context,

      isScrollControlled: true,

      backgroundColor: cardColor,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),

      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,

                bottom: MediaQuery.of(context).viewInsets.bottom + 25,
              ),

              child: SingleChildScrollView(
                child: Form(
                  key: formKey,

                  child: Column(
                    mainAxisSize: MainAxisSize.min,

                    crossAxisAlignment: CrossAxisAlignment.stretch,

                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,

                          decoration: BoxDecoration(
                            color: borderColor,

                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Row(
                        children: [
                          Icon(Icons.lock_reset_rounded, color: primaryColor),

                          SizedBox(width: 9),

                          Text(
                            'เปลี่ยนรหัสผ่าน',

                            style: TextStyle(
                              color: textPrimary,

                              fontSize: 19,

                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      _passwordField(
                        controller: currentController,

                        label: 'รหัสผ่านปัจจุบัน',

                        obscure: obscureCurrent,

                        onToggle: () {
                          setSheetState(() {
                            obscureCurrent = !obscureCurrent;
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      _passwordField(
                        controller: newController,

                        label: 'รหัสผ่านใหม่',

                        obscure: obscureNew,

                        onToggle: () {
                          setSheetState(() {
                            obscureNew = !obscureNew;
                          });
                        },

                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                          }

                          if (value == currentController.text) {
                            return 'รหัสผ่านใหม่ต้องไม่เหมือนรหัสเดิม';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      _passwordField(
                        controller: confirmController,

                        label: 'ยืนยันรหัสผ่านใหม่',

                        obscure: obscureConfirm,

                        onToggle: () {
                          setSheetState(() {
                            obscureConfirm = !obscureConfirm;
                          });
                        },

                        validator: (value) {
                          if (value != newController.text) {
                            return 'รหัสผ่านใหม่ไม่ตรงกัน';
                          }

                          return null;
                        },
                      ),

                      if (apiError != null) ...[
                        const SizedBox(height: 14),

                        _errorBox(apiError!),
                      ],

                      const SizedBox(height: 22),

                      SizedBox(
                        height: 52,

                        child: ElevatedButton(
                          onPressed: saving
                              ? null
                              : () async {
                                  setSheetState(() {
                                    apiError = null;
                                  });

                                  if (!formKey.currentState!.validate()) {
                                    return;
                                  }

                                  setSheetState(() {
                                    saving = true;
                                  });

                                  final result =
                                      await AdminProfileService.changePassword(
                                        currentPassword: currentController.text,

                                        newPassword: newController.text,

                                        confirmPassword: confirmController.text,
                                      );

                                  if (!mounted) {
                                    return;
                                  }

                                  if (result['success'] == true) {
                                    Navigator.pop(sheetContext, true);

                                    return;
                                  }

                                  setSheetState(() {
                                    saving = false;

                                    apiError =
                                        result['message'] ??
                                        'ไม่สามารถเปลี่ยนรหัสผ่านได้';
                                  });
                                },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,

                            foregroundColor: backgroundColor,

                            elevation: 0,

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),

                          child: saving
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,

                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,

                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,

                                        color: backgroundColor,
                                      ),
                                    ),

                                    SizedBox(width: 9),

                                    Text('กำลังตรวจสอบ...'),
                                  ],
                                )
                              : const Text(
                                  'เปลี่ยนรหัสผ่าน',

                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    currentController.dispose();
    newController.dispose();
    confirmController.dispose();

    if (changed == true && mounted) {
      _showMessage('เปลี่ยนรหัสผ่านเรียบร้อยแล้ว');
    }
  }

  // =========================================================
  // Logout
  // =========================================================

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardColor,

          title: const Text('ออกจากระบบ', style: TextStyle(color: textPrimary)),

          content: const Text(
            'ต้องการออกจากระบบผู้ดูแลใช่หรือไม่?',

            style: TextStyle(color: textSecondary),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },

              child: const Text(
                'ยกเลิก',

                style: TextStyle(color: textSecondary),
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },

              child: const Text(
                'ออกจากระบบ',

                style: TextStyle(
                  color: dangerColor,

                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await AuthService.logout();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),

      (route) => false,
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

          onRefresh: refresh,

          child: _isLoading && _profile == null
              ? const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                )
              : _profile == null
              ? _buildError()
              : _buildContent(),
        ),
      ),
    );
  }

  // =========================================================
  // Content
  // =========================================================

  Widget _buildContent() {
    final profile = _profile!;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),

      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),

      children: [
        // =====================================================
        // Header
        // =====================================================
        const Text(
          'โปรไฟล์ผู้ดูแล',

          style: TextStyle(
            color: textPrimary,

            fontSize: 25,

            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 3),

        const Text(
          'จัดการข้อมูลบัญชีและความปลอดภัย',

          style: TextStyle(color: textSecondary, fontSize: 10),
        ),

        const SizedBox(height: 25),

        // =====================================================
        // Admin Card
        // =====================================================
        Container(
          width: double.infinity,

          padding: const EdgeInsets.all(22),

          decoration: BoxDecoration(
            color: cardColor,

            borderRadius: BorderRadius.circular(24),

            border: Border.all(color: primaryColor.withOpacity(0.20)),
          ),

          child: Column(
            children: [
              Container(
                width: 82,
                height: 82,

                alignment: Alignment.center,

                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.10),

                  shape: BoxShape.circle,

                  border: Border.all(
                    color: primaryColor.withOpacity(0.32),

                    width: 2,
                  ),
                ),

                child: Text(
                  profile.initials,

                  style: const TextStyle(
                    color: primaryColor,

                    fontSize: 27,

                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Text(
                profile.fullName,

                style: const TextStyle(
                  color: textPrimary,

                  fontSize: 20,

                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                profile.email,

                style: const TextStyle(color: textSecondary, fontSize: 10),
              ),

              const SizedBox(height: 13),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.08),

                  borderRadius: BorderRadius.circular(30),

                  border: Border.all(color: primaryColor.withOpacity(0.18)),
                ),

                child: Row(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    Icon(
                      Icons.verified_user_rounded,

                      color: primaryColor,

                      size: 13,
                    ),

                    SizedBox(width: 5),

                    Text(
                      profile.role == 'super_admin'
                          ? 'SUPER ADMIN'
                          : 'ADMINISTRATOR',

                      style: const TextStyle(
                        color: primaryColor,

                        fontSize: 8,

                        letterSpacing: 1,

                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 13),

        // =====================================================
        // Stats
        // =====================================================
        Row(
          children: [
            Expanded(
              child: _AdminStat(
                icon: Icons.people_alt_outlined,

                value: profile.totalUsers,

                label: 'สมาชิก',
              ),
            ),

            const SizedBox(width: 9),

            Expanded(
              child: _AdminStat(
                icon: Icons.event_note_rounded,

                value: profile.totalEvents,

                label: 'กิจกรรม',
              ),
            ),
          ],
        ),

        const SizedBox(height: 9),

        Row(
          children: [
            Expanded(
              child: _AdminStat(
                icon: Icons.event_available_rounded,

                value: profile.openEvents,

                label: 'กำลังเปิด',
              ),
            ),

            const SizedBox(width: 9),

            Expanded(
              child: _AdminStat(
                icon: Icons.my_location_rounded,

                value: profile.todayCheckins,

                label: 'เช็กอินวันนี้',
              ),
            ),
          ],
        ),

        const SizedBox(height: 27),

        // =====================================================
        // Account
        // =====================================================
        const Text(
          'ข้อมูลบัญชี',

          style: TextStyle(
            color: textPrimary,

            fontSize: 16,

            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 11),

        Container(
          decoration: BoxDecoration(
            color: cardColor,

            borderRadius: BorderRadius.circular(20),

            border: Border.all(color: borderColor),
          ),

          child: Column(
            children: [
              _infoRow(
                icon: Icons.person_outline_rounded,

                title: 'ชื่อ',

                value: profile.firstname,
              ),

              _line(),

              _infoRow(
                icon: Icons.badge_outlined,

                title: 'นามสกุล',

                value: profile.lastname,
              ),

              _line(),

              _infoRow(
                icon: Icons.email_outlined,

                title: 'อีเมล',

                value: profile.email,
              ),

              _line(),

              _infoRow(
                icon: Icons.admin_panel_settings_outlined,

                title: 'สิทธิ์',

                value: 'ผู้ดูแลระบบ',
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        _menuButton(
          icon: Icons.edit_outlined,

          title: 'แก้ไขข้อมูลส่วนตัว',

          subtitle: 'เปลี่ยนชื่อและนามสกุล',

          onTap: _showEditProfile,
        ),

        if (profile.role == 'super_admin') ...[
          const SizedBox(height: 27),

          const Text(
            'การจัดการระบบ',
            style: TextStyle(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 11),

          _menuButton(
            icon: Icons.admin_panel_settings_rounded,
            title: 'จัดการสิทธิ์ผู้ดูแล',
            subtitle: 'เพิ่มอาจารย์ เจ้าหน้าที่ หรือกำหนดสิทธิ์ Admin',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminAccessScreen()),
              );

              if (mounted) {
                await refresh();
              }
            },
          ),
        ],

        const SizedBox(height: 27),

        const Text(
          'ความปลอดภัย',

          style: TextStyle(
            color: textPrimary,

            fontSize: 16,

            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 11),

        _menuButton(
          icon: Icons.lock_outline_rounded,

          title: 'เปลี่ยนรหัสผ่าน',

          subtitle: 'เปลี่ยนรหัสผ่านสำหรับบัญชีผู้ดูแล',

          onTap: _showChangePassword,
        ),

        const SizedBox(height: 10),

        _menuButton(
          icon: Icons.logout_rounded,

          title: 'ออกจากระบบ',

          subtitle: 'ออกจาก GeoCheck Admin',

          danger: true,

          onTap: _logout,
        ),
      ],
    );
  }

  // =========================================================
  // Info Row
  // =========================================================

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.all(15),

      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 19),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: const TextStyle(color: textSecondary, fontSize: 9),
                ),

                const SizedBox(height: 2),

                Text(
                  value,

                  style: const TextStyle(
                    color: textPrimary,

                    fontSize: 12,

                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _line() {
    return const Divider(
      height: 1,

      color: borderColor,

      indent: 15,
      endIndent: 15,
    );
  }

  // =========================================================
  // Menu Button
  // =========================================================

  Widget _menuButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,

    bool danger = false,
  }) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(18),

        child: Container(
          padding: const EdgeInsets.all(15),

          decoration: BoxDecoration(
            color: cardColor,

            borderRadius: BorderRadius.circular(18),

            border: Border.all(
              color: danger ? dangerColor.withOpacity(0.20) : borderColor,
            ),
          ),

          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,

                decoration: BoxDecoration(
                  color: danger
                      ? dangerColor.withOpacity(0.08)
                      : primaryColor.withOpacity(0.08),

                  borderRadius: BorderRadius.circular(13),
                ),

                child: Icon(
                  icon,

                  color: danger ? dangerColor : primaryColor,

                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,

                      style: TextStyle(
                        color: danger ? dangerColor : textPrimary,

                        fontSize: 13,

                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,

                      style: const TextStyle(color: textSecondary, fontSize: 9),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios_rounded,

                color: Color(0xFF596673),

                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // Fields
  // =========================================================

  Widget _textField({
    required TextEditingController controller,

    required String label,

    required IconData icon,

    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,

      validator: validator,

      style: const TextStyle(color: textPrimary),

      decoration: InputDecoration(
        labelText: label,

        labelStyle: const TextStyle(color: textSecondary),

        prefixIcon: Icon(icon, color: textSecondary),

        filled: true,

        fillColor: fieldColor,

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),

          borderSide: const BorderSide(color: borderColor),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),

          borderSide: const BorderSide(color: primaryColor),
        ),

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,

    required String label,

    required bool obscure,

    required VoidCallback onToggle,

    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,

      obscureText: obscure,

      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'กรุณากรอก$label';
            }

            return null;
          },

      style: const TextStyle(color: textPrimary),

      decoration: InputDecoration(
        labelText: label,

        labelStyle: const TextStyle(color: textSecondary),

        prefixIcon: const Icon(
          Icons.lock_outline_rounded,

          color: textSecondary,
        ),

        suffixIcon: IconButton(
          onPressed: onToggle,

          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,

            color: textSecondary,
          ),
        ),

        filled: true,

        fillColor: fieldColor,

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),

          borderSide: const BorderSide(color: borderColor),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),

          borderSide: const BorderSide(color: primaryColor),
        ),

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  // =========================================================
  // Error Box
  // =========================================================

  Widget _errorBox(String message) {
    return Container(
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: dangerColor.withOpacity(0.08),

        borderRadius: BorderRadius.circular(12),

        border: Border.all(color: dangerColor.withOpacity(0.22)),
      ),

      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: dangerColor, size: 18),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              message,

              style: const TextStyle(
                color: dangerColor,

                fontSize: 10,

                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // Error Page
  // =========================================================

  Widget _buildError() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),

      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,

          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                const Icon(
                  Icons.error_outline_rounded,

                  color: dangerColor,

                  size: 43,
                ),

                const SizedBox(height: 12),

                const Text(
                  'ไม่สามารถโหลดโปรไฟล์ได้',

                  style: TextStyle(
                    color: textPrimary,

                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                TextButton(
                  onPressed: _loadProfile,

                  child: const Text(
                    'ลองอีกครั้ง',

                    style: TextStyle(color: primaryColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // Message
  // =========================================================

  void _showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,

        content: Text(message),

        backgroundColor: error
            ? const Color(0xFFD94A4A)
            : const Color(0xFF253512),
      ),
    );
  }
}

// =============================================================
// Admin Stat
// =============================================================

class _AdminStat extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;

  const _AdminStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),

      decoration: BoxDecoration(
        color: AdminProfileScreenState.cardColor,

        borderRadius: BorderRadius.circular(17),

        border: Border.all(color: AdminProfileScreenState.borderColor),
      ),

      child: Column(
        children: [
          Icon(icon, color: AdminProfileScreenState.primaryColor, size: 18),

          const SizedBox(height: 5),

          Text(
            '$value',

            style: const TextStyle(
              color: AdminProfileScreenState.textPrimary,

              fontSize: 20,

              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            label,

            style: const TextStyle(
              color: AdminProfileScreenState.textSecondary,

              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }
}
