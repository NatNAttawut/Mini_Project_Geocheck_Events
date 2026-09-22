import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/animated_action_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  late AnimationController _pulseController;

  static const Color backgroundColor = Color(0xFF080D13);
  static const Color cardColor = Color(0xFF101720);
  static const Color fieldColor = Color(0xFF151E28);
  static const Color borderColor = Color(0xFF26313D);

  static const Color primaryColor = Color(0xFFB7F52B);
  static const Color textPrimary = Color(0xFFF3F5F7);
  static const Color textSecondary = Color(0xFF8B98A5);

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();

    _firstnameController.dispose();
    _lastnameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_isLoading) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final firstname = _firstnameController.text.trim();

    final lastname = _lastnameController.text.trim();

    final studentId = _studentIdController.text.trim();

    final email = _emailController.text.trim();

    final password = _passwordController.text;

    final confirmPassword = _confirmPasswordController.text;

    // =========================================================
    // ตรวจ Password
    // =========================================================

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('รหัสผ่านและยืนยันรหัสผ่านไม่ตรงกัน'),
          backgroundColor: Color(0xFFD94A4A),
        ),
      );

      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร'),
          backgroundColor: Color(0xFFD94A4A),
        ),
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await AuthService.register(
      firstname: firstname,
      lastname: lastname,
      studentId: studentId,
      email: email,
      password: password,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    // =========================================================
    // Register ไม่สำเร็จ
    // =========================================================

    if (result['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'สร้างบัญชีไม่สำเร็จ'),
          backgroundColor: const Color(0xFFD94A4A),
        ),
      );

      return;
    }

    // =========================================================
    // Register สำเร็จ
    // =========================================================

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFFB7F52B)),

            const SizedBox(width: 10),

            Expanded(
              child: Text(result['message'] ?? 'สร้างบัญชีเรียบร้อยแล้ว'),
            ),
          ],
        ),

        backgroundColor: const Color(0xFF1B2A16),
      ),
    );

    // กลับหน้า Login
    Navigator.pop(context);
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF53606D), fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFF667483), size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: fieldColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 17, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: primaryColor, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFFF6262)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFFF6262), width: 1.4),
      ),
      errorStyle: const TextStyle(color: Color(0xFFFF7979)),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFA4AFBA),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // =========================================================
          // Background Glow
          // =========================================================
          Positioned(
            top: -120,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.07),
                    blurRadius: 120,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: -120,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF37A5FF).withOpacity(0.04),
                    blurRadius: 120,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // =================================================
                        // Top Navigation
                        // =================================================
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(13),
                                border: Border.all(color: borderColor),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: textPrimary,
                                  size: 20,
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'GeoCheck',
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'CREATE ACCOUNT',
                                  style: TextStyle(
                                    color: Color(0xFF566371),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),

                            const Spacer(),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.07),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: primaryColor.withOpacity(0.22),
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.shield_outlined,
                                    color: primaryColor,
                                    size: 14,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'SECURE',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // =================================================
                        // Profile / Location Identity
                        // =================================================
                        _buildProfileIdentity(),

                        const SizedBox(height: 25),

                        const Text(
                          'สร้าง GeoCheck ID',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 27,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 7),

                        const Text(
                          'สร้างบัญชีเพื่อเข้าร่วมกิจกรรม\nและเช็กอินด้วยตำแหน่งของคุณ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 14,
                            height: 1.55,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // =================================================
                        // Register Card
                        // =================================================
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: const Color(0xFF202A35)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.30),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // ===========================================
                              // Card Header
                              // ===========================================
                              Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.10),
                                      borderRadius: BorderRadius.circular(11),
                                    ),
                                    child: const Icon(
                                      Icons.person_add_alt_1_rounded,
                                      color: primaryColor,
                                      size: 20,
                                    ),
                                  ),

                                  const SizedBox(width: 11),

                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'ข้อมูลบัญชี',
                                          style: TextStyle(
                                            color: textPrimary,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'กรอกข้อมูลสำหรับสร้างบัญชีใหม่',
                                          style: TextStyle(
                                            color: textSecondary,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 25),

                              // ===========================================
                              // Firstname + Lastname
                              // ===========================================
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        _fieldLabel('ชื่อ'),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _firstnameController,
                                          textInputAction: TextInputAction.next,
                                          style: const TextStyle(
                                            color: textPrimary,
                                            fontSize: 14,
                                          ),
                                          decoration: _inputDecoration(
                                            hint: 'ชื่อ',
                                            icon: Icons.person_outline_rounded,
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.trim().isEmpty) {
                                              return 'กรุณากรอกชื่อ';
                                            }

                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        _fieldLabel('นามสกุล'),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _lastnameController,
                                          textInputAction: TextInputAction.next,
                                          style: const TextStyle(
                                            color: textPrimary,
                                            fontSize: 14,
                                          ),
                                          decoration: _inputDecoration(
                                            hint: 'นามสกุล',
                                            icon: Icons.person_outline_rounded,
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.trim().isEmpty) {
                                              return 'กรุณากรอกนามสกุล';
                                            }

                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 18),

                              // ===========================================
                              // Student ID
                              // ===========================================
                              _fieldLabel('รหัสนักศึกษา'),

                              const SizedBox(height: 8),

                              TextFormField(
                                controller: _studentIdController,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                style: const TextStyle(
                                  color: textPrimary,
                                  fontSize: 14,
                                ),
                                decoration: _inputDecoration(
                                  hint: 'กรอกรหัสนักศึกษา',
                                  icon: Icons.badge_outlined,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'กรุณากรอกรหัสนักศึกษา';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 18),

                              // ===========================================
                              // Email
                              // ===========================================
                              _fieldLabel('อีเมล'),

                              const SizedBox(height: 8),

                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                style: const TextStyle(
                                  color: textPrimary,
                                  fontSize: 14,
                                ),
                                decoration: _inputDecoration(
                                  hint: 'Example@email.com',
                                  icon: Icons.email_rounded,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'กรุณากรอกอีเมล';
                                  }

                                  if (!value.contains('@')) {
                                    return 'รูปแบบอีเมลไม่ถูกต้อง';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 18),

                              // ===========================================
                              // Password
                              // ===========================================
                              _fieldLabel('รหัสผ่าน'),

                              const SizedBox(height: 8),

                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.next,
                                style: const TextStyle(
                                  color: textPrimary,
                                  fontSize: 14,
                                ),
                                decoration: _inputDecoration(
                                  hint: 'อย่างน้อย 6 ตัวอักษร',
                                  icon: Icons.lock_outline_rounded,
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: const Color(0xFF667483),
                                      size: 20,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'กรุณากรอกรหัสผ่าน';
                                  }

                                  if (value.length < 6) {
                                    return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 18),

                              // ===========================================
                              // Confirm Password
                              // ===========================================
                              _fieldLabel('ยืนยันรหัสผ่าน'),

                              const SizedBox(height: 8),

                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) {
                                  _handleRegister();
                                },
                                style: const TextStyle(
                                  color: textPrimary,
                                  fontSize: 14,
                                ),
                                decoration: _inputDecoration(
                                  hint: 'กรอกรหัสผ่านอีกครั้ง',
                                  icon: Icons.lock_reset_rounded,
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                    },
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: const Color(0xFF667483),
                                      size: 20,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'กรุณายืนยันรหัสผ่าน';
                                  }

                                  if (value != _passwordController.text) {
                                    return 'รหัสผ่านไม่ตรงกัน';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 27),

                              // ===========================================
                              // Create Account Button
                              // ===========================================
                              AnimatedActionButton(
                                text: 'สร้างบัญชี',
                                icon: Icons.person_add_rounded,
                                backgroundColor: primaryColor,
                                foregroundColor: backgroundColor,
                                onPressed: _handleRegister,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        // =================================================
                        // Back to Login
                        // =================================================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'มีบัญชีอยู่แล้ว? ',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'เข้าสู่ระบบ',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        const Text(
                          'CREATE • LOCATE • CHECK-IN',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF384451),
                            fontSize: 9,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================================================
  // Profile Identity
  // =============================================================

  Widget _buildProfileIdentity() {
    return SizedBox(
      width: 145,
      height: 145,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Pulse
              Transform.scale(
                scale: 0.72 + (_pulseController.value * 0.45),
                child: Opacity(
                  opacity: 1 - _pulseController.value,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryColor, width: 1),
                    ),
                  ),
                ),
              ),

              // Outer Ring
              Container(
                width: 125,
                height: 125,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF1E2934)),
                ),
              ),

              // Middle Ring
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2B3743)),
                ),
              ),

              // Glow
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.17),
                      blurRadius: 35,
                      spreadRadius: 8,
                    ),
                  ],
                ),
              ),

              // Main Profile Icon
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: backgroundColor,
                  size: 28,
                ),
              ),

              // Small Pin
              Positioned(
                right: 20,
                bottom: 25,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: cardColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryColor, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: primaryColor,
                    size: 15,
                  ),
                ),
              ),

              // Decorative point 1
              Positioned(top: 26, left: 25, child: _buildSmallPoint()),

              // Decorative point 2
              Positioned(top: 48, right: 14, child: _buildSmallPoint(size: 5)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSmallPoint({double size = 6}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: primaryColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: primaryColor.withOpacity(0.6), blurRadius: 7),
        ],
      ),
    );
  }
}
