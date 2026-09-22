import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/admin_member.dart';
import '../../services/admin_user_service.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() =>
      _MembersScreenState();
}

class _MembersScreenState
    extends State<MembersScreen> {
  static const backgroundColor =
      Color(0xFF080D13);

  static const cardColor =
      Color(0xFF101720);

  static const fieldColor =
      Color(0xFF151E28);

  static const borderColor =
      Color(0xFF26313D);

  static const primaryColor =
      Color(0xFFB7F52B);

  static const textPrimary =
      Color(0xFFF3F5F7);

  static const textSecondary =
      Color(0xFF8B98A5);

  final TextEditingController
      _searchController =
      TextEditingController();

  Timer? _searchTimer;

  List<AdminMember> _members = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadMembers();
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchController.dispose();

    super.dispose();
  }

  // =========================================================
  // Load Members
  // =========================================================

  Future<void> _loadMembers() async {
    setState(() {
      _isLoading = true;
    });

    final result =
        await AdminUserService.getMembers(
      search: _searchController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      setState(() {
        _members =
            result['members']
                as List<AdminMember>;
      });

      return;
    }

    _showMessage(
      result['message'] ??
          'ไม่สามารถโหลดสมาชิกได้',
      error: true,
    );
  }

  // =========================================================
  // Search
  // =========================================================

  void _onSearchChanged(String value) {
    _searchTimer?.cancel();

    _searchTimer = Timer(
      const Duration(milliseconds: 450),
      () {
        _loadMembers();
      },
    );
  }

  // =========================================================
  // Add/Edit Member
  // =========================================================

  Future<void> _openMemberForm({
    AdminMember? member,
  }) async {
    final changed =
        await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent,
      builder: (context) {
        return _MemberFormSheet(
          member: member,
        );
      },
    );

    if (changed == true) {
      _loadMembers();
    }
  }

  // =========================================================
  // Delete
  // =========================================================

  Future<void> _deleteMember(
    AdminMember member,
  ) async {
    final confirm =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: const Text(
            'ลบสมาชิก?',
            style: TextStyle(
              color: textPrimary,
            ),
          ),
          content: Text(
            'ต้องการลบ ${member.fullName} ออกจากระบบหรือไม่?\n\nประวัติการลงทะเบียนและเช็กอินของสมาชิกคนนี้จะถูกลบด้วย',
            style: const TextStyle(
              color: textSecondary,
              height: 1.5,
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
              child: const Text(
                'ยกเลิก',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'ลบสมาชิก',
                style: TextStyle(
                  color:
                      Color(0xFFFF6262),
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

    final result =
        await AdminUserService
            .deleteMember(
      member.id,
    );

    if (!mounted) {
      return;
    }

    _showMessage(
      result['message'] ??
          'ดำเนินการเรียบร้อย',
      error: result['success'] != true,
    );

    if (result['success'] == true) {
      _loadMembers();
    }
  }

  void _showMessage(
    String message, {
    bool error = false,
  }) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
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
      backgroundColor:
          backgroundColor,

      floatingActionButton:
          FloatingActionButton(
        onPressed: () {
          _openMemberForm();
        },
        backgroundColor:
            primaryColor,
        foregroundColor:
            backgroundColor,
        child: const Icon(
          Icons.person_add_alt_1_rounded,
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // =================================================
            // Header
            // =================================================

            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                0,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration:
                            BoxDecoration(
                          color: primaryColor
                              .withOpacity(
                            0.10,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
                        ),
                        child: const Icon(
                          Icons
                              .groups_2_rounded,
                          color:
                              primaryColor,
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
                            const Text(
                              'จัดการสมาชิก',
                              style:
                                  TextStyle(
                                color:
                                    textPrimary,
                                fontSize: 22,
                                fontWeight:
                                    FontWeight
                                        .w700,
                              ),
                            ),
                            Text(
                              '${_members.length} สมาชิก',
                              style:
                                  const TextStyle(
                                color:
                                    textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 22,
                  ),

                  // =============================================
                  // Search
                  // =============================================

                  TextField(
                    controller:
                        _searchController,
                    onChanged:
                        _onSearchChanged,
                    style:
                        const TextStyle(
                      color: textPrimary,
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
                        fontSize: 12,
                      ),
                      prefixIcon:
                          const Icon(
                        Icons.search_rounded,
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

                                    setState(
                                      () {},
                                    );

                                    _loadMembers();
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
                      filled: true,
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
                ],
              ),
            ),

            const SizedBox(height: 18),

            // =================================================
            // Members
            // =================================================

            Expanded(
              child: _isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(
                        color:
                            primaryColor,
                      ),
                    )
                  : _members.isEmpty
                      ? _emptyState()
                      : RefreshIndicator(
                          color:
                              primaryColor,
                          onRefresh:
                              _loadMembers,
                          child:
                              ListView
                                  .separated(
                            padding:
                                const EdgeInsets
                                    .fromLTRB(
                              20,
                              0,
                              20,
                              110,
                            ),
                            itemCount:
                                _members
                                    .length,
                            separatorBuilder:
                                (
                              context,
                              index,
                            ) =>
                                    const SizedBox(
                              height: 10,
                            ),
                            itemBuilder:
                                (
                              context,
                              index,
                            ) {
                              return _memberCard(
                                _members[
                                    index],
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration:
                BoxDecoration(
              color: primaryColor
                  .withOpacity(0.07),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_search_rounded,
              color: primaryColor,
              size: 31,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'ไม่พบสมาชิก',
            style: TextStyle(
              color: textPrimary,
              fontSize: 17,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'ลองเปลี่ยนคำค้นหา หรือเพิ่มสมาชิกใหม่',
            style: TextStyle(
              color: textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _memberCard(
    AdminMember member,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration:
                BoxDecoration(
              color: primaryColor
                  .withOpacity(0.10),
              borderRadius:
                  BorderRadius.circular(
                15,
              ),
            ),
            child: Text(
              member.initials,
              style: const TextStyle(
                color: primaryColor,
                fontSize: 15,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  member.fullName,
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      const TextStyle(
                    color: textPrimary,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  member.email,
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      const TextStyle(
                    color:
                        textSecondary,
                    fontSize: 11,
                  ),
                ),

                if (member.studentId !=
                        null &&
                    member
                        .studentId!
                        .isNotEmpty) ...[
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    'รหัสนักศึกษา ${member.studentId}',
                    style:
                        const TextStyle(
                      color:
                          Color(
                        0xFF64717E,
                      ),
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
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
                _openMemberForm(
                  member: member,
                );
              }

              if (value == 'delete') {
                _deleteMember(
                  member,
                );
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(
                        Icons
                            .edit_outlined,
                        color:
                            textPrimary,
                        size: 19,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'แก้ไข',
                        style:
                            TextStyle(
                          color:
                              textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons
                            .delete_outline,
                        color:
                            Color(
                          0xFFFF6262,
                        ),
                        size: 19,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'ลบสมาชิก',
                        style:
                            TextStyle(
                          color:
                              Color(
                            0xFFFF6262,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }
}

// =============================================================
// Add / Edit Member Bottom Sheet
// =============================================================

class _MemberFormSheet
    extends StatefulWidget {
  final AdminMember? member;

  const _MemberFormSheet({
    this.member,
  });

  @override
  State<_MemberFormSheet>
      createState() =>
          _MemberFormSheetState();
}

class _MemberFormSheetState
    extends State<_MemberFormSheet> {
  final _formKey =
      GlobalKey<FormState>();

  late TextEditingController
      firstnameController;

  late TextEditingController
      lastnameController;

  late TextEditingController
      studentIdController;

  late TextEditingController
      emailController;

  late TextEditingController
      passwordController;

  bool isLoading = false;
  bool obscurePassword = true;

  bool get isEditing =>
      widget.member != null;

  @override
  void initState() {
    super.initState();

    firstnameController =
        TextEditingController(
      text:
          widget.member?.firstname ??
              '',
    );

    lastnameController =
        TextEditingController(
      text:
          widget.member?.lastname ??
              '',
    );

    studentIdController =
        TextEditingController(
      text:
          widget.member?.studentId ??
              '',
    );

    emailController =
        TextEditingController(
      text:
          widget.member?.email ??
              '',
    );

    passwordController =
        TextEditingController();
  }

  @override
  void dispose() {
    firstnameController.dispose();
    lastnameController.dispose();
    studentIdController.dispose();
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  Future<void> _submit() async {
    if (isLoading) {
      return;
    }

    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> result;

    if (isEditing) {
      result =
          await AdminUserService
              .updateMember(
        id: widget.member!.id,
        firstname:
            firstnameController.text,
        lastname:
            lastnameController.text,
        studentId:
            studentIdController.text,
        email:
            emailController.text,
        password:
            passwordController.text,
      );
    } else {
      result =
          await AdminUserService
              .createMember(
        firstname:
            firstnameController.text,
        lastname:
            lastnameController.text,
        studentId:
            studentIdController.text,
        email:
            emailController.text,
        password:
            passwordController.text,
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      isLoading = false;
    });

    if (result['success'] == true) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            result['message'],
          ),
        ),
      );

      Navigator.pop(
        context,
        true,
      );

      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          result['message'] ??
              'เกิดข้อผิดพลาด',
        ),
        backgroundColor:
            const Color(0xFFD94A4A),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor =
        Color(0xFF101720);

    const fieldColor =
        Color(0xFF151E28);

    const borderColor =
        Color(0xFF26313D);

    const primaryColor =
        Color(0xFFB7F52B);

    const textPrimary =
        Color(0xFFF3F5F7);

    const textSecondary =
        Color(0xFF8B98A5);

    return Padding(
      padding: EdgeInsets.only(
        bottom:
            MediaQuery.of(context)
                .viewInsets
                .bottom,
      ),
      child: Container(
        constraints:
            const BoxConstraints(
          maxHeight: 650,
        ),
        padding:
            const EdgeInsets.fromLTRB(
          20,
          13,
          20,
          22,
        ),
        decoration:
            const BoxDecoration(
          color: backgroundColor,
          borderRadius:
              BorderRadius.vertical(
            top:
                Radius.circular(28),
          ),
        ),
        child: Form(
          key: _formKey,
          child:
              SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration:
                        BoxDecoration(
                      color:
                          borderColor,
                      borderRadius:
                          BorderRadius
                              .circular(
                        10,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                Text(
                  isEditing
                      ? 'แก้ไขสมาชิก'
                      : 'เพิ่มสมาชิก',
                  style:
                      const TextStyle(
                    color:
                        textPrimary,
                    fontSize: 21,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  isEditing
                      ? 'แก้ไขข้อมูลสมาชิกในระบบ'
                      : 'สร้างบัญชีสมาชิกใหม่',
                  style:
                      const TextStyle(
                    color:
                        textSecondary,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                Row(
                  children: [
                    Expanded(
                      child:
                          _input(
                        firstnameController,
                        'ชื่อ',
                        Icons
                            .person_outline,
                      ),
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    Expanded(
                      child:
                          _input(
                        lastnameController,
                        'นามสกุล',
                        Icons
                            .person_outline,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 11,
                ),

                _input(
                  studentIdController,
                  'รหัสนักศึกษา',
                  Icons
                      .badge_outlined,
                  required: false,
                ),

                const SizedBox(
                  height: 11,
                ),

                _input(
                  emailController,
                  'อีเมล',
                  Icons
                      .email_outlined,
                  email: true,
                ),

                const SizedBox(
                  height: 11,
                ),

                TextFormField(
                  controller:
                      passwordController,
                  obscureText:
                      obscurePassword,
                  style:
                      const TextStyle(
                    color:
                        textPrimary,
                  ),
                  decoration:
                      InputDecoration(
                    hintText: isEditing
                        ? 'รหัสผ่านใหม่ (ไม่เปลี่ยนให้เว้นว่าง)'
                        : 'รหัสผ่าน',
                    hintStyle:
                        const TextStyle(
                      color:
                          textSecondary,
                      fontSize: 12,
                    ),
                    prefixIcon:
                        const Icon(
                      Icons
                          .lock_outline,
                      color:
                          textSecondary,
                    ),
                    suffixIcon:
                        IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword =
                              !obscurePassword;
                        });
                      },
                      icon: Icon(
                        obscurePassword
                            ? Icons
                                .visibility_off_outlined
                            : Icons
                                .visibility_outlined,
                        color:
                            textSecondary,
                      ),
                    ),
                    filled: true,
                    fillColor:
                        fieldColor,
                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),
                      borderSide:
                          const BorderSide(
                        color:
                            borderColor,
                      ),
                    ),
                  ),
                  validator:
                      (value) {
                    if (!isEditing &&
                        (value == null ||
                            value
                                .isEmpty)) {
                      return 'กรุณากรอกรหัสผ่าน';
                    }

                    if (value !=
                            null &&
                        value
                            .isNotEmpty &&
                        value.length <
                            6) {
                      return 'อย่างน้อย 6 ตัวอักษร';
                    }

                    return null;
                  },
                ),

                const SizedBox(
                  height: 22,
                ),

                SizedBox(
                  height: 52,
                  child:
                      ElevatedButton(
                    onPressed:
                        isLoading
                            ? null
                            : _submit,
                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          primaryColor,
                      foregroundColor:
                          const Color(
                        0xFF080D13,
                      ),
                      disabledBackgroundColor:
                          primaryColor
                              .withOpacity(
                        0.5,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          15,
                        ),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child:
                                CircularProgressIndicator(
                              strokeWidth:
                                  2.5,
                              color:
                                  Color(
                                0xFF080D13,
                              ),
                            ),
                          )
                        : Text(
                            isEditing
                                ? 'บันทึกการแก้ไข'
                                : 'เพิ่มสมาชิก',
                            style:
                                const TextStyle(
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
      ),
    );
  }

  Widget _input(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool required = true,
    bool email = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: email
          ? TextInputType
              .emailAddress
          : TextInputType.text,
      style: const TextStyle(
        color: Color(0xFFF3F5F7),
      ),
      decoration:
          InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(
          color:
              Color(0xFF8B98A5),
          fontSize: 12,
        ),
        prefixIcon: Icon(
          icon,
          color:
              const Color(
            0xFF8B98A5,
          ),
        ),
        filled: true,
        fillColor:
            const Color(
          0xFF151E28,
        ),
        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          borderSide:
              const BorderSide(
            color:
                Color(
              0xFF26313D,
            ),
          ),
        ),
      ),
      validator: (value) {
        if (required &&
            (value == null ||
                value
                    .trim()
                    .isEmpty)) {
          return 'กรุณากรอกข้อมูล';
        }

        if (email &&
            value != null &&
            value.isNotEmpty &&
            !value.contains('@')) {
          return 'อีเมลไม่ถูกต้อง';
        }

        return null;
      },
    );
  }
}