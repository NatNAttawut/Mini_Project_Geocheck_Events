import 'package:flutter/material.dart';

import '../../models/access_account.dart';
import '../../services/admin_access_service.dart';

class AdminAccessScreen
    extends StatefulWidget {
  const AdminAccessScreen({
    super.key,
  });

  @override
  State<AdminAccessScreen>
      createState() =>
          _AdminAccessScreenState();
}

class _AdminAccessScreenState
    extends State<AdminAccessScreen> {
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

  static const dangerColor =
      Color(0xFFFF6262);

  List<AccessAccount>
      _accounts = [];

  bool _loading =
      true;

  String _filter =
      'admin';

  // =========================================================

  @override
  void initState() {
    super.initState();

    _load();
  }

  Future<void> _load() async {
    final result =
        await AdminAccessService
            .getAccounts();

    if (!mounted) {
      return;
    }

    if (result['success'] ==
        true) {
      setState(() {
        _accounts =
            result['accounts']
                as List<
                    AccessAccount>;

        _loading =
            false;
      });

      return;
    }

    setState(() {
      _loading =
          false;
    });

    _message(
      result['message'],
      error: true,
    );
  }

  // =========================================================

  List<AccessAccount>
      get _visible {
    if (_filter ==
        'admin') {
      return _accounts.where(
        (user) =>
            user.role ==
                'admin' ||
            user.role ==
                'super_admin',
      ).toList();
    }

    return _accounts.where(
      (user) =>
          user.role ==
          'user',
    ).toList();
  }

  // =========================================================
  // Change Role
  // =========================================================

  Future<void> _changeRole(
    AccessAccount user,
  ) async {
    if (user.isSuperAdmin) {
      return;
    }

    final makeAdmin =
        user.isUser;

    final confirmed =
        await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor:
              cardColor,

          title: Text(
            makeAdmin
                ? 'แต่งตั้งผู้ดูแลระบบ'
                : 'ถอนสิทธิ์ผู้ดูแลระบบ',

            style:
                const TextStyle(
              color:
                  textPrimary,
            ),
          ),

          content: Text(
            makeAdmin
                ? 'ต้องการแต่งตั้ง ${user.fullName} เป็น Admin ใช่หรือไม่?'
                : 'ต้องการถอนสิทธิ์ Admin ของ ${user.fullName} ใช่หรือไม่?',

            style:
                const TextStyle(
              color:
                  textSecondary,
            ),
          ),

          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                false,
              ),

              child:
                  const Text(
                'ยกเลิก',
              ),
            ),

            TextButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                true,
              ),

              child:
                  Text(
                makeAdmin
                    ? 'แต่งตั้ง'
                    : 'ถอนสิทธิ์',

                style:
                    TextStyle(
                  color:
                      makeAdmin
                          ? primaryColor
                          : dangerColor,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed !=
        true) {
      return;
    }

    final result =
        await AdminAccessService
            .changeRole(
      userId:
          user.id,

      role:
          makeAdmin
              ? 'admin'
              : 'user',
    );

    if (!mounted) {
      return;
    }

    _message(
      result['message'],
      error:
          result['success'] !=
          true,
    );

    if (result['success'] ==
        true) {
      await _load();
    }
  }

  // =========================================================
  // Create Admin
  // =========================================================

  Future<void>
      _createAdmin() async {
    final first =
        TextEditingController();

    final last =
        TextEditingController();

    final email =
        TextEditingController();

    final password =
        TextEditingController();

    final formKey =
        GlobalKey<FormState>();

    bool loading =
        false;

    String? error;

    final created =
        await showModalBottomSheet<bool>(
      context: context,

      isScrollControlled:
          true,

      backgroundColor:
          cardColor,

      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (
            context,
            setSheetState,
          ) {
            return Padding(
              padding:
                  EdgeInsets.fromLTRB(
                20,
                20,
                20,
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
                      const Text(
                        'เพิ่มผู้ดูแลระบบ',

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
                        height: 5,
                      ),

                      const Text(
                        'สำหรับอาจารย์หรือเจ้าหน้าที่ที่ดูแลกิจกรรม',

                        style:
                            TextStyle(
                          color:
                              textSecondary,

                          fontSize:
                              10,
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      _field(
                        first,
                        'ชื่อ',
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      _field(
                        last,
                        'นามสกุล',
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      _field(
                        email,
                        'อีเมล',
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      _field(
                        password,
                        'รหัสผ่านเริ่มต้น',
                        obscure:
                            true,
                      ),

                      if (error !=
                          null) ...[
                        const SizedBox(
                          height: 12,
                        ),

                        Text(
                          error!,

                          style:
                              const TextStyle(
                            color:
                                dangerColor,

                            fontSize:
                                10,
                          ),
                        ),
                      ],

                      const SizedBox(
                        height: 20,
                      ),

                      SizedBox(
                        height: 50,

                        child:
                            ElevatedButton(
                          onPressed:
                              loading
                                  ? null
                                  : () async {
                                      if (!formKey
                                          .currentState!
                                          .validate()) {
                                        return;
                                      }

                                      setSheetState(
                                        () {
                                          loading =
                                              true;

                                          error =
                                              null;
                                        },
                                      );

                                      final result =
                                          await AdminAccessService
                                              .createAdmin(
                                        firstname:
                                            first.text
                                                .trim(),

                                        lastname:
                                            last.text
                                                .trim(),

                                        email:
                                            email.text
                                                .trim(),

                                        password:
                                            password
                                                .text,
                                      );

                                      if (result[
                                              'success'] ==
                                          true) {
                                        if (sheetContext
                                            .mounted) {
                                          Navigator.pop(
                                            sheetContext,
                                            true,
                                          );
                                        }

                                        return;
                                      }

                                      setSheetState(
                                        () {
                                          loading =
                                              false;

                                          error =
                                              result[
                                                  'message'];
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
                          ),

                          child:
                              loading
                                  ? const SizedBox(
                                      width:
                                          20,
                                      height:
                                          20,

                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth:
                                            2,

                                        color:
                                            backgroundColor,
                                      ),
                                    )
                                  : const Text(
                                      'สร้างบัญชี Admin',
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

    first.dispose();
    last.dispose();
    email.dispose();
    password.dispose();

    if (created == true &&
        mounted) {
      _message(
        'เพิ่มผู้ดูแลระบบเรียบร้อยแล้ว',
      );

      await _load();
    }
  }

  // =========================================================

  Widget _field(
    TextEditingController controller,
    String label, {
    bool obscure = false,
  }) {
    return TextFormField(
      controller:
          controller,

      obscureText:
          obscure,

      style:
          const TextStyle(
        color:
            textPrimary,
      ),

      validator: (value) {
        if (value == null ||
            value.trim().isEmpty) {
          return 'กรุณากรอก$label';
        }

        if (label ==
                'รหัสผ่านเริ่มต้น' &&
            value.length < 6) {
          return 'อย่างน้อย 6 ตัวอักษร';
        }

        return null;
      },

      decoration:
          InputDecoration(
        labelText:
            label,

        labelStyle:
            const TextStyle(
          color:
              textSecondary,
        ),

        filled: true,

        fillColor:
            fieldColor,

        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            14,
          ),
        ),
      ),
    );
  }

  // =========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          backgroundColor,

      appBar: AppBar(
        backgroundColor:
            backgroundColor,

        foregroundColor:
            textPrimary,

        title:
            const Text(
          'จัดการสิทธิ์',

          style:
              TextStyle(
            fontWeight:
                FontWeight.w700,
          ),
        ),

        actions: [
          IconButton(
            onPressed:
                _createAdmin,

            icon:
                const Icon(
              Icons
                  .person_add_alt_1_rounded,

              color:
                  primaryColor,
            ),
          ),
        ],
      ),

      body:
          RefreshIndicator(
        color:
            primaryColor,

        onRefresh:
            _load,

        child:
            _loading
                ? const Center(
                    child:
                        CircularProgressIndicator(
                      color:
                          primaryColor,
                    ),
                  )
                : ListView(
                    padding:
                        const EdgeInsets
                            .fromLTRB(
                      20,
                      15,
                      20,
                      30,
                    ),

                    children: [
                      const Text(
                        'สิทธิ์การใช้งาน',

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
                        height: 5,
                      ),

                      const Text(
                        'Super Admin สามารถแต่งตั้งหรือถอนสิทธิ์ผู้ดูแลระบบได้',

                        style:
                            TextStyle(
                          color:
                              textSecondary,

                          fontSize:
                              10,
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      Row(
                        children: [
                          _filterButton(
                            'admin',
                            'ผู้ดูแลระบบ',
                          ),

                          const SizedBox(
                            width: 8,
                          ),

                          _filterButton(
                            'user',
                            'สมาชิก',
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 15,
                      ),

                      if (_visible
                          .isEmpty)
                        const Padding(
                          padding:
                              EdgeInsets
                                  .all(
                            30,
                          ),

                          child: Center(
                            child:
                                Text(
                              'ไม่พบข้อมูล',

                              style:
                                  TextStyle(
                                color:
                                    textSecondary,
                              ),
                            ),
                          ),
                        )
                      else
                        ..._visible.map(
                          _accountCard,
                        ),
                    ],
                  ),
      ),
    );
  }

  Widget _filterButton(
    String value,
    String label,
  ) {
    final selected =
        _filter == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _filter =
              value;
        });
      },

      child: Container(
        padding:
            const EdgeInsets
                .symmetric(
          horizontal: 15,
          vertical: 9,
        ),

        decoration:
            BoxDecoration(
          color:
              selected
                  ? primaryColor
                  : cardColor,

          borderRadius:
              BorderRadius
                  .circular(
            30,
          ),

          border:
              Border.all(
            color:
                selected
                    ? primaryColor
                    : borderColor,
          ),
        ),

        child: Text(
          label,

          style:
              TextStyle(
            color:
                selected
                    ? backgroundColor
                    : textSecondary,

            fontWeight:
                FontWeight.w600,

            fontSize: 10,
          ),
        ),
      ),
    );
  }

  Widget _accountCard(
    AccessAccount user,
  ) {
    final roleText =
        user.isSuperAdmin
            ? 'SUPER ADMIN'
            : user.isAdmin
                ? 'ADMIN'
                : 'MEMBER';

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),

      padding:
          const EdgeInsets.all(
        15,
      ),

      decoration:
          BoxDecoration(
        color:
            cardColor,

        borderRadius:
            BorderRadius
                .circular(
          18,
        ),

        border:
            Border.all(
          color:
              user.isSuperAdmin
                  ? primaryColor
                      .withOpacity(
                        0.25,
                      )
                  : borderColor,
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,

            decoration:
                BoxDecoration(
              color:
                  primaryColor
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
              user.isUser
                  ? Icons
                      .person_outline_rounded
                  : Icons
                      .shield_outlined,

              color:
                  primaryColor,
            ),
          ),

          const SizedBox(
            width: 11,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [
                Text(
                  user.fullName,

                  style:
                      const TextStyle(
                    color:
                        textPrimary,

                    fontSize:
                        13,

                    fontWeight:
                        FontWeight
                            .w700,
                  ),
                ),

                const SizedBox(
                  height: 2,
                ),

                Text(
                  user.email,

                  style:
                      const TextStyle(
                    color:
                        textSecondary,

                    fontSize: 9,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  roleText,

                  style:
                      const TextStyle(
                    color:
                        primaryColor,

                    fontSize: 8,

                    fontWeight:
                        FontWeight
                            .w700,
                  ),
                ),
              ],
            ),
          ),

          if (!user
              .isSuperAdmin)
            TextButton(
              onPressed:
                  () =>
                      _changeRole(
                user,
              ),

              child: Text(
                user.isUser
                    ? 'แต่งตั้ง'
                    : 'ถอนสิทธิ์',

                style:
                    TextStyle(
                  color:
                      user.isUser
                          ? primaryColor
                          : dangerColor,

                  fontSize: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _message(
    dynamic message, {
    bool error = false,
  }) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(
          message?.toString() ??
              'เกิดข้อผิดพลาด',
        ),

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