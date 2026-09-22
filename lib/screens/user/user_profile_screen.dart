import 'package:flutter/material.dart';

import '../../models/user_profile.dart';
import '../../services/profile_service.dart';
import '../../services/auth_service.dart';

import '../login_screen.dart';

class UserProfileScreen
    extends StatefulWidget {
  const UserProfileScreen({
    super.key,
  });

  @override
  State<UserProfileScreen>
      createState() =>
          _UserProfileScreenState();
}

class _UserProfileScreenState
    extends State<UserProfileScreen> {
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

  UserProfile? _profile;

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
  // Load Profile
  // =========================================================

  Future<void> _loadProfile({
    bool showLoading = true,
  }) async {
    if (showLoading &&
        mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final result =
        await ProfileService
            .getProfile();

    if (!mounted) {
      return;
    }

    if (result['success'] ==
        true) {
      setState(() {
        _profile =
            result['profile']
                as UserProfile;

        _isLoading = false;
      });

      return;
    }

    setState(() {
      _isLoading = false;
    });

    _showMessage(
      result['message'] ??
          'ไม่สามารถโหลดโปรไฟล์ได้',

      error: true,
    );
  }

  // =========================================================
  // Edit Profile
  // =========================================================

  Future<void>
      _showEditProfile() async {
    if (_profile == null) {
      return;
    }

    final firstnameController =
        TextEditingController(
      text:
          _profile!.firstname,
    );

    final lastnameController =
        TextEditingController(
      text:
          _profile!.lastname,
    );

    final studentIdController =
        TextEditingController(
      text:
          _profile!.studentId ??
          '',
    );

    final formKey =
        GlobalKey<FormState>();

    bool saving =
        false;

    await showModalBottomSheet(
      context: context,

      isScrollControlled:
          true,

      backgroundColor:
          cardColor,

      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top:
              Radius.circular(
            25,
          ),
        ),
      ),

      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (
            context,
            setSheetState,
          ) {
            return Padding(
              padding:
                  EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,

                bottom:
                    MediaQuery.of(
                      context,
                    )
                        .viewInsets
                        .bottom +
                    25,
              ),

              child:
                  SingleChildScrollView(
                child: Form(
                  key:
                      formKey,

                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,

                    crossAxisAlignment:
                        CrossAxisAlignment
                            .stretch,

                    children: [
                      // =====================================
                      // Handle
                      // =====================================

                      Center(
                        child:
                            Container(
                          width:
                              42,

                          height:
                              4,

                          decoration:
                              BoxDecoration(
                            color:
                                borderColor,

                            borderRadius:
                                BorderRadius
                                    .circular(
                              20,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height:
                            20,
                      ),

                      const Text(
                        'แก้ไขข้อมูลส่วนตัว',

                        style:
                            TextStyle(
                          color:
                              textPrimary,

                          fontSize:
                              20,

                          fontWeight:
                              FontWeight
                                  .w800,
                        ),
                      ),

                      const SizedBox(
                        height:
                            5,
                      ),

                      const Text(
                        'แก้ไขชื่อ นามสกุล และรหัสนักศึกษา',

                        style:
                            TextStyle(
                          color:
                              textSecondary,

                          fontSize:
                              10,
                        ),
                      ),

                      const SizedBox(
                        height:
                            22,
                      ),

                      _formField(
                        controller:
                            firstnameController,

                        label:
                            'ชื่อ',

                        icon:
                            Icons
                                .person_outline_rounded,

                        validator:
                            (value) {
                          if (value ==
                                  null ||
                              value
                                  .trim()
                                  .isEmpty) {
                            return 'กรุณากรอกชื่อ';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(
                        height:
                            12,
                      ),

                      _formField(
                        controller:
                            lastnameController,

                        label:
                            'นามสกุล',

                        icon:
                            Icons
                                .badge_outlined,

                        validator:
                            (value) {
                          if (value ==
                                  null ||
                              value
                                  .trim()
                                  .isEmpty) {
                            return 'กรุณากรอกนามสกุล';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(
                        height:
                            12,
                      ),

                      _formField(
                        controller:
                            studentIdController,

                        label:
                            'รหัสนักศึกษา',

                        icon:
                            Icons
                                .school_outlined,

                        keyboardType:
                            TextInputType
                                .number,
                      ),

                      const SizedBox(
                        height:
                            22,
                      ),

                      SizedBox(
                        height:
                            53,

                        child:
                            ElevatedButton(
                          onPressed:
                              saving
                                  ? null
                                  : () async {
                                      if (!formKey
                                          .currentState!
                                          .validate()) {
                                        return;
                                      }

                                      setSheetState(
                                        () {
                                          saving =
                                              true;
                                        },
                                      );

                                      final result =
                                          await ProfileService
                                              .updateProfile(
                                        firstname:
                                            firstnameController
                                                .text
                                                .trim(),

                                        lastname:
                                            lastnameController
                                                .text
                                                .trim(),

                                        studentId:
                                            studentIdController
                                                    .text
                                                    .trim()
                                                    .isEmpty
                                                ? null
                                                : studentIdController
                                                    .text
                                                    .trim(),
                                      );

                                      if (!mounted) {
                                        return;
                                      }

                                      if (result[
                                              'success'] ==
                                          true) {
                                        Navigator.pop(
                                          sheetContext,
                                        );

                                        _showMessage(
                                          result['message'] ??
                                              'แก้ไขข้อมูลเรียบร้อยแล้ว',
                                        );

                                        await _loadProfile(
                                          showLoading:
                                              false,
                                        );

                                        return;
                                      }

                                      setSheetState(
                                        () {
                                          saving =
                                              false;
                                        },
                                      );

                                      _showMessage(
                                        result['message'] ??
                                            'ไม่สามารถแก้ไขข้อมูลได้',

                                        error:
                                            true,
                                      );
                                    },

                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                primaryColor,

                            foregroundColor:
                                backgroundColor,

                            elevation:
                                0,

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                15,
                              ),
                            ),
                          ),

                          child:
                              saving
                                  ? const SizedBox(
                                      width:
                                          22,

                                      height:
                                          22,

                                      child:
                                          CircularProgressIndicator(
                                        color:
                                            backgroundColor,

                                        strokeWidth:
                                            2.5,
                                      ),
                                    )
                                  : const Text(
                                      'บันทึกการแก้ไข',

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
                ),
              ),
            );
          },
        );
      },
    );

    firstnameController
        .dispose();

    lastnameController
        .dispose();

    studentIdController
        .dispose();
  }

  // =========================================================
  // Change Password
  // =========================================================

  Future<void> _showChangePassword() async {
  final currentController =
      TextEditingController();

  final newController =
      TextEditingController();

  final confirmController =
      TextEditingController();

  final formKey =
      GlobalKey<FormState>();

  bool saving = false;

  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  String? apiError;

  final changed =
      await showModalBottomSheet<bool>(
    context: context,

    isScrollControlled: true,

    backgroundColor: cardColor,

    shape:
        const RoundedRectangleBorder(
      borderRadius:
          BorderRadius.vertical(
        top: Radius.circular(25),
      ),
    ),

    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (
          context,
          setSheetState,
        ) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,

              bottom:
                  MediaQuery.of(context)
                          .viewInsets
                          .bottom +
                      25,
            ),

            child: SingleChildScrollView(
              child: Form(
                key: formKey,

                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,

                  crossAxisAlignment:
                      CrossAxisAlignment
                          .stretch,

                  children: [
                    // =========================================
                    // Handle
                    // =========================================

                    Center(
                      child: Container(
                        width: 42,
                        height: 4,

                        decoration:
                            BoxDecoration(
                          color: borderColor,

                          borderRadius:
                              BorderRadius
                                  .circular(20),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // =========================================
                    // Header
                    // =========================================

                    const Row(
                      children: [
                        Icon(
                          Icons
                              .lock_reset_rounded,

                          color:
                              primaryColor,

                          size: 25,
                        ),

                        SizedBox(
                          width: 10,
                        ),

                        Expanded(
                          child: Text(
                            'เปลี่ยนรหัสผ่าน',

                            style:
                                TextStyle(
                              color:
                                  textPrimary,

                              fontSize: 20,

                              fontWeight:
                                  FontWeight
                                      .w800,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    const Text(
                      'กรอกรหัสผ่านปัจจุบันก่อนตั้งรหัสผ่านใหม่',

                      style: TextStyle(
                        color:
                            textSecondary,

                        fontSize: 10,
                      ),
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    // =========================================
                    // Current Password
                    // =========================================

                    _passwordField(
                      controller:
                          currentController,

                      label:
                          'รหัสผ่านปัจจุบัน',

                      obscure:
                          obscureCurrent,

                      onToggle: () {
                        setSheetState(() {
                          obscureCurrent =
                              !obscureCurrent;
                        });
                      },

                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return 'กรุณากรอกรหัสผ่านปัจจุบัน';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    // =========================================
                    // New Password
                    // =========================================

                    _passwordField(
                      controller:
                          newController,

                      label:
                          'รหัสผ่านใหม่',

                      obscure:
                          obscureNew,

                      onToggle: () {
                        setSheetState(() {
                          obscureNew =
                              !obscureNew;
                        });
                      },

                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return 'กรุณากรอกรหัสผ่านใหม่';
                        }

                        if (value.length < 6) {
                          return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                        }

                        if (value ==
                            currentController
                                .text) {
                          return 'รหัสผ่านใหม่ต้องไม่เหมือนรหัสผ่านเดิม';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    // =========================================
                    // Confirm Password
                    // =========================================

                    _passwordField(
                      controller:
                          confirmController,

                      label:
                          'ยืนยันรหัสผ่านใหม่',

                      obscure:
                          obscureConfirm,

                      onToggle: () {
                        setSheetState(() {
                          obscureConfirm =
                              !obscureConfirm;
                        });
                      },

                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return 'กรุณายืนยันรหัสผ่านใหม่';
                        }

                        if (value !=
                            newController.text) {
                          return 'รหัสผ่านใหม่ไม่ตรงกัน';
                        }

                        return null;
                      },
                    ),

                    // =========================================
                    // API Error
                    // =========================================

                    if (apiError !=
                        null) ...[
                      const SizedBox(
                        height: 15,
                      ),

                      Container(
                        padding:
                            const EdgeInsets
                                .all(13),

                        decoration:
                            BoxDecoration(
                          color:
                              dangerColor
                                  .withOpacity(
                                    0.08,
                                  ),

                          borderRadius:
                              BorderRadius
                                  .circular(13),

                          border:
                              Border.all(
                            color:
                                dangerColor
                                    .withOpacity(
                                      0.25,
                                    ),
                          ),
                        ),

                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [
                            const Icon(
                              Icons
                                  .error_outline_rounded,

                              color:
                                  dangerColor,

                              size: 19,
                            ),

                            const SizedBox(
                              width: 9,
                            ),

                            Expanded(
                              child: Text(
                                apiError!,

                                style:
                                    const TextStyle(
                                  color:
                                      dangerColor,

                                  fontSize: 11,

                                  height: 1.4,

                                  fontWeight:
                                      FontWeight
                                          .w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(
                      height: 22,
                    ),

                    // =========================================
                    // Save
                    // =========================================

                    SizedBox(
                      height: 53,

                      child:
                          ElevatedButton(
                        onPressed:
                            saving
                                ? null
                                : () async {
                                    // ซ่อนข้อความ Error เก่าก่อน
                                    setSheetState(
                                      () {
                                        apiError =
                                            null;
                                      },
                                    );

                                    // ตรวจข้อมูลใน Form
                                    if (!formKey
                                        .currentState!
                                        .validate()) {
                                      return;
                                    }

                                    setSheetState(
                                      () {
                                        saving =
                                            true;
                                      },
                                    );

                                    final result =
                                        await ProfileService
                                            .changePassword(
                                      currentPassword:
                                          currentController
                                              .text,

                                      newPassword:
                                          newController
                                              .text,

                                      confirmPassword:
                                          confirmController
                                              .text,
                                    );

                                    if (!mounted) {
                                      return;
                                    }

                                    // =========================
                                    // Success
                                    // =========================

                                    if (result[
                                            'success'] ==
                                        true) {
                                      Navigator.pop(
                                        sheetContext,
                                        true,
                                      );

                                      return;
                                    }

                                    // =========================
                                    // Failed
                                    // =========================

                                    setSheetState(
                                      () {
                                        saving =
                                            false;

                                        apiError =
                                            result[
                                                'message'] ??
                                            'ไม่สามารถเปลี่ยนรหัสผ่านได้';
                                      },
                                    );
                                  },

                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              primaryColor,

                          foregroundColor:
                              backgroundColor,

                          disabledBackgroundColor:
                              primaryColor
                                  .withOpacity(
                                    0.45,
                                  ),

                          elevation: 0,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(15),
                          ),
                        ),

                        child: saving
                            ? const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,

                                children: [
                                  SizedBox(
                                    width: 21,
                                    height: 21,

                                    child:
                                        CircularProgressIndicator(
                                      color:
                                          backgroundColor,

                                      strokeWidth:
                                          2.5,
                                    ),
                                  ),

                                  SizedBox(
                                    width: 10,
                                  ),

                                  Text(
                                    'กำลังตรวจสอบ...',
                                  ),
                                ],
                              )
                            : const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,

                                children: [
                                  Icon(
                                    Icons
                                        .lock_reset_rounded,

                                    size: 19,
                                  ),

                                  SizedBox(
                                    width: 8,
                                  ),

                                  Text(
                                    'เปลี่ยนรหัสผ่าน',

                                    style:
                                        TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .w700,
                                    ),
                                  ),
                                ],
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

  // =========================================================
  // Success Message
  // =========================================================

  if (changed == true &&
      mounted) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(
              Icons
                  .check_circle_rounded,

              color: Color(
                0xFFB7F52B,
              ),
            ),

            SizedBox(
              width: 10,
            ),

            Expanded(
              child: Text(
                'เปลี่ยนรหัสผ่านเรียบร้อยแล้ว',
              ),
            ),
          ],
        ),

        backgroundColor:
            Color(
          0xFF1B2A16,
        ),

        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }
}

  // =========================================================
  // Logout
  // =========================================================

  Future<void> _logout() async {
    final confirm =
        await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor:
              cardColor,

          title:
              const Text(
            'ออกจากระบบ',

            style:
                TextStyle(
              color:
                  textPrimary,
            ),
          ),

          content:
              const Text(
            'ต้องการออกจากระบบใช่หรือไม่?',

            style:
                TextStyle(
              color:
                  textSecondary,
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },

              child:
                  const Text(
                'ยกเลิก',

                style:
                    TextStyle(
                  color:
                      textSecondary,
                ),
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },

              child:
                  const Text(
                'ออกจากระบบ',

                style:
                    TextStyle(
                  color:
                      dangerColor,

                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    await AuthService.logout();

    if (!mounted) {
      return;
    }

    Navigator.of(context)
        .pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) =>
            const LoginScreen(),
      ),

      (route) => false,
    );
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
        child:
            RefreshIndicator(
          color:
              primaryColor,

          onRefresh: () =>
              _loadProfile(
            showLoading:
                false,
          ),

          child:
              _isLoading &&
                      _profile == null
                  ? const Center(
                      child:
                          CircularProgressIndicator(
                        color:
                            primaryColor,
                      ),
                    )
                  : _profile ==
                          null
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
    final profile =
        _profile!;

    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),

      padding:
          const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        120,
      ),

      children: [
        // =====================================================
        // Header
        // =====================================================

        const Text(
          'โปรไฟล์',

          style:
              TextStyle(
            color:
                textPrimary,

            fontSize:
                26,

            fontWeight:
                FontWeight.w800,
          ),
        ),

        const SizedBox(
          height: 4,
        ),

        const Text(
          'จัดการข้อมูลบัญชีของคุณ',

          style:
              TextStyle(
            color:
                textSecondary,

            fontSize:
                10,
          ),
        ),

        const SizedBox(
          height: 27,
        ),

        // =====================================================
        // Profile Card
        // =====================================================

        Container(
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
              24,
            ),

            border:
                Border.all(
              color:
                  primaryColor
                      .withOpacity(
                0.18,
              ),
            ),
          ),

          child: Column(
            children: [
              Container(
                width: 82,
                height: 82,

                alignment:
                    Alignment.center,

                decoration:
                    BoxDecoration(
                  color:
                      primaryColor
                          .withOpacity(
                    0.10,
                  ),

                  shape:
                      BoxShape.circle,

                  border:
                      Border.all(
                    color:
                        primaryColor
                            .withOpacity(
                      0.30,
                    ),

                    width:
                        2,
                  ),
                ),

                child: Text(
                  profile.initials,

                  style:
                      const TextStyle(
                    color:
                        primaryColor,

                    fontSize:
                        27,

                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              Text(
                profile.fullName,

                style:
                    const TextStyle(
                  color:
                      textPrimary,

                  fontSize:
                      20,

                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(
                height: 4,
              ),

              Text(
                profile.email,

                style:
                    const TextStyle(
                  color:
                      textSecondary,

                  fontSize:
                      10,
                ),
              ),

              if (profile.studentId !=
                      null &&
                  profile
                      .studentId!
                      .isNotEmpty) ...[
                const SizedBox(
                  height: 4,
                ),

                Text(
                  'รหัสนักศึกษา ${profile.studentId}',

                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF687582,
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
          height: 13,
        ),

        // =====================================================
        // Stats
        // =====================================================

        Row(
          children: [
            Expanded(
              child:
                  _ProfileStatCard(
                icon:
                    Icons
                        .event_available_rounded,

                value:
                    profile
                        .registeredEvents,

                label:
                    'ลงทะเบียน',
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            Expanded(
              child:
                  _ProfileStatCard(
                icon:
                    Icons
                        .location_on_rounded,

                value:
                    profile
                        .checkedInEvents,

                label:
                    'เช็กอินแล้ว',
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 26,
        ),

        // =====================================================
        // Information
        // =====================================================

        const Text(
          'ข้อมูลส่วนตัว',

          style:
              TextStyle(
            color:
                textPrimary,

            fontSize:
                16,

            fontWeight:
                FontWeight.w700,
          ),
        ),

        const SizedBox(
          height: 11,
        ),

        Container(
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

          child: Column(
            children: [
              _profileInfo(
                icon:
                    Icons
                        .person_outline_rounded,

                title:
                    'ชื่อ',

                value:
                    profile.firstname,
              ),

              _line(),

              _profileInfo(
                icon:
                    Icons
                        .badge_outlined,

                title:
                    'นามสกุล',

                value:
                    profile.lastname,
              ),

              _line(),

              _profileInfo(
                icon:
                    Icons
                        .school_outlined,

                title:
                    'รหัสนักศึกษา',

                value:
                    profile.studentId ??
                        '-',
              ),

              _line(),

              _profileInfo(
                icon:
                    Icons
                        .email_outlined,

                title:
                    'อีเมล',

                value:
                    profile.email,
              ),
            ],
          ),
        ),

        const SizedBox(
          height: 12,
        ),

        _settingButton(
          icon:
              Icons
                  .edit_outlined,

          title:
              'แก้ไขข้อมูลส่วนตัว',

          subtitle:
              'เปลี่ยนชื่อ นามสกุล หรือรหัสนักศึกษา',

          onTap:
              _showEditProfile,
        ),

        const SizedBox(
          height: 26,
        ),

        // =====================================================
        // Account
        // =====================================================

        const Text(
          'บัญชี',

          style:
              TextStyle(
            color:
                textPrimary,

            fontSize:
                16,

            fontWeight:
                FontWeight.w700,
          ),
        ),

        const SizedBox(
          height: 11,
        ),

        _settingButton(
          icon:
              Icons
                  .lock_outline_rounded,

          title:
              'เปลี่ยนรหัสผ่าน',

          subtitle:
              'อัปเดตรหัสผ่านสำหรับเข้าสู่ระบบ',

          onTap:
              _showChangePassword,
        ),

        const SizedBox(
          height: 10,
        ),

        _settingButton(
          icon:
              Icons
                  .logout_rounded,

          title:
              'ออกจากระบบ',

          subtitle:
              'ออกจากบัญชี GeoCheck',

          danger:
              true,

          onTap:
              _logout,
        ),
      ],
    );
  }

  // =========================================================
  // Profile Info
  // =========================================================

  Widget _profileInfo({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding:
          const EdgeInsets.all(
        15,
      ),

      child: Row(
        children: [
          Icon(
            icon,

            color:
                primaryColor,

            size:
                19,
          ),

          const SizedBox(
            width: 12,
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
                        textSecondary,

                    fontSize:
                        9,
                  ),
                ),

                const SizedBox(
                  height:
                      2,
                ),

                Text(
                  value,

                  style:
                      const TextStyle(
                    color:
                        textPrimary,

                    fontSize:
                        12,

                    fontWeight:
                        FontWeight.w600,
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
      color:
          borderColor,

      height:
          1,

      indent:
          15,

      endIndent:
          15,
    );
  }

  // =========================================================
  // Setting Button
  // =========================================================

  Widget _settingButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool danger = false,
  }) {
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
                cardColor,

            borderRadius:
                BorderRadius.circular(
              18,
            ),

            border:
                Border.all(
              color: danger
                  ? dangerColor
                      .withOpacity(
                        0.20,
                      )
                  : borderColor,
            ),
          ),

          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,

                decoration:
                    BoxDecoration(
                  color: danger
                      ? dangerColor
                          .withOpacity(
                            0.08,
                          )
                      : primaryColor
                          .withOpacity(
                            0.08,
                          ),

                  borderRadius:
                      BorderRadius
                          .circular(
                    13,
                  ),
                ),

                child: Icon(
                  icon,

                  color: danger
                      ? dangerColor
                      : primaryColor,

                  size: 20,
                ),
              ),

              const SizedBox(
                width: 12,
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
                          TextStyle(
                        color: danger
                            ? dangerColor
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
                      subtitle,

                      style:
                          const TextStyle(
                        color:
                            textSecondary,

                        fontSize:
                            9,
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

  // =========================================================
  // Form Field
  // =========================================================

  Widget _formField({
    required TextEditingController
        controller,

    required String label,

    required IconData icon,

    String? Function(String?)?
        validator,

    TextInputType?
        keyboardType,
  }) {
    return TextFormField(
      controller:
          controller,

      keyboardType:
          keyboardType,

      validator:
          validator,

      style:
          const TextStyle(
        color:
            textPrimary,
      ),

      decoration:
          InputDecoration(
        labelText:
            label,

        labelStyle:
            const TextStyle(
          color:
              textSecondary,
        ),

        prefixIcon:
            Icon(
          icon,

          color:
              textSecondary,
        ),

        filled:
            true,

        fillColor:
            fieldColor,

        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),

          borderSide:
              BorderSide.none,
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            14,
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
              BorderRadius.circular(
            14,
          ),

          borderSide:
              const BorderSide(
            color:
                primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController
        controller,

    required String label,

    required bool obscure,

    required VoidCallback onToggle,

    String? Function(String?)?
        validator,
  }) {
    return TextFormField(
      controller:
          controller,

      obscureText:
          obscure,

      validator: validator ??
          (value) {
            if (value == null ||
                value.isEmpty) {
              return 'กรุณากรอก$label';
            }

            return null;
          },

      style:
          const TextStyle(
        color:
            textPrimary,
      ),

      decoration:
          InputDecoration(
        labelText:
            label,

        labelStyle:
            const TextStyle(
          color:
              textSecondary,
        ),

        prefixIcon:
            const Icon(
          Icons
              .lock_outline_rounded,

          color:
              textSecondary,
        ),

        suffixIcon:
            IconButton(
          onPressed:
              onToggle,

          icon: Icon(
            obscure
                ? Icons
                    .visibility_off_outlined
                : Icons
                    .visibility_outlined,

            color:
                textSecondary,
          ),
        ),

        filled:
            true,

        fillColor:
            fieldColor,

        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),

          borderSide:
              BorderSide.none,
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            14,
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
              BorderRadius.circular(
            14,
          ),

          borderSide:
              const BorderSide(
            color:
                primaryColor,
          ),
        ),
      ),
    );
  }

  // =========================================================
  // Error
  // =========================================================

  Widget _buildError() {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),

      children: [
        SizedBox(
          height:
              MediaQuery.of(context)
                      .size
                      .height *
                  0.65,

          child: Center(
            child: Column(
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
                  height:
                      12,
                ),

                const Text(
                  'ไม่สามารถโหลดโปรไฟล์ได้',

                  style:
                      TextStyle(
                    color:
                        textPrimary,
                  ),
                ),

                const SizedBox(
                  height:
                      10,
                ),

                TextButton(
                  onPressed:
                      _loadProfile,

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
            Text(message),

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
// Profile Stat
// =============================================================

class _ProfileStatCard
    extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;

  const _ProfileStatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        vertical:
            15,
      ),

      decoration:
          BoxDecoration(
        color:
            _UserProfileScreenState
                .cardColor,

        borderRadius:
            BorderRadius.circular(
          17,
        ),

        border:
            Border.all(
          color:
              _UserProfileScreenState
                  .borderColor,
        ),
      ),

      child: Column(
        children: [
          Icon(
            icon,

            color:
                _UserProfileScreenState
                    .primaryColor,

            size:
                18,
          ),

          const SizedBox(
            height:
                5,
          ),

          Text(
            '$value',

            style:
                const TextStyle(
              color:
                  _UserProfileScreenState
                      .textPrimary,

              fontSize:
                  20,

              fontWeight:
                  FontWeight.w800,
            ),
          ),

          Text(
            label,

            style:
                const TextStyle(
              color:
                  _UserProfileScreenState
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