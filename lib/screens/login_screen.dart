import 'package:flutter/material.dart';
import '../utils/page_transition.dart';
import '../widgets/animated_action_button.dart';
import 'register_screen.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'admin/admin_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  late AnimationController _radarController;

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

    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await AuthService.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    // =========================================================
    // Login ไม่สำเร็จ
    // =========================================================

    if (result['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'เข้าสู่ระบบไม่สำเร็จ'),
          backgroundColor: const Color(0xFFFF5252),
        ),
      );

      return;
    }

    // =========================================================
    // Login สำเร็จ
    // =========================================================

    final user = result['user'] as Map<String, dynamic>;

    final role = user['role'];

    if (role != 'user' && role != 'admin' && role != 'super_admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('บัญชีนี้ไม่มีสิทธิ์เข้าใช้งานระบบ'),
          backgroundColor: Color(0xFFFF5252),
        ),
      );

      return;
    }

    // =========================================================
    // Admin
    // =========================================================

    if (role == 'admin' || role == 'super_admin') {
      Navigator.pushReplacement(
        context,
        AppPageRoute(page: const AdminHomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        AppPageRoute(page: const HomeScreen()),
      );
    }
  }

  void _openRegister() {
    Navigator.push(context, AppPageRoute(page: const RegisterScreen()));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // =========================================================
          // Background decoration
          // =========================================================
          Positioned(
            top: -120,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.08),
                    blurRadius: 120,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 280,
              height: 280,
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

          // =========================================================
          // Main Content
          // =========================================================
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // =================================================
                        // Header
                        // =================================================
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: const Icon(
                                Icons.location_on_rounded,
                                color: backgroundColor,
                                size: 23,
                              ),
                            ),

                            const SizedBox(width: 11),

                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'GeoCheck',
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                Text(
                                  'EVENT CHECK-IN',
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
                                horizontal: 10,
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
                                  _StatusDot(),
                                  SizedBox(width: 7),
                                  Text(
                                    'GPS READY',
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

                        const SizedBox(height: 38),

                        // =================================================
                        // Radar
                        // =================================================
                        _buildRadar(),

                        const SizedBox(height: 15),

                        // =================================================
                        // Login Card
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
                              const Text(
                                'เข้าสู่ระบบ',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 5),

                              const Text(
                                'กรอกข้อมูลบัญชี GeoCheck ของคุณ',
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 12,
                                ),
                              ),

                              const SizedBox(height: 24),

                              // =================================================
                              // Email
                              // =================================================
                              const Text(
                                'อีเมล',
                                style: TextStyle(
                                  color: Color(0xFFA4AFBA),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

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

                              // =================================================
                              // Password
                              // =================================================
                              const Text(
                                'รหัสผ่าน',
                                style: TextStyle(
                                  color: Color(0xFFA4AFBA),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 8),

                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) {
                                  _handleLogin();
                                },
                                style: const TextStyle(
                                  color: textPrimary,
                                  fontSize: 14,
                                ),
                                decoration: _inputDecoration(
                                  hint: '••••••••',
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

                              const SizedBox(height: 5),

                              // =================================================
                              // Forgot Password
                              // =================================================
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'ระบบลืมรหัสผ่านจะพัฒนาในภายหลัง',
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'ลืมรหัสผ่าน?',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              // =================================================
                              // Login Button
                              // =================================================
                              AnimatedActionButton(
                                text: 'เข้าสู่ระบบ',
                                icon: Icons.arrow_forward_rounded,
                                backgroundColor: primaryColor,
                                foregroundColor: backgroundColor,
                                onPressed: _handleLogin,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        // =================================================
                        // Register
                        // =================================================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'ยังไม่มีบัญชี? ',
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            GestureDetector(
                              onTap: _openRegister,
                              child: const Text(
                                'สมัครสมาชิก',
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
                          'LOCATION • EVENT • CHECK-IN',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF384451),
                            fontSize: 9,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
  // Radar
  // =============================================================

  Widget _buildRadar() {
    return SizedBox(
      width: 170,
      height: 170,
      child: AnimatedBuilder(
        animation: _radarController,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Radar pulse
              Transform.scale(
                scale: 0.8 + (_radarController.value * 0.5),
                child: Opacity(
                  opacity: 1 - _radarController.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryColor, width: 1.0),
                    ),
                  ),
                ),
              ),

              // Outer circle
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF1C2732)),
                ),
              ),

              // Middle circle
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF26313C)),
                ),
              ),

              // Inner circle
              Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF33404C)),
                ),
              ),

              // Horizontal radar line
              Container(width: 145, height: 1, color: const Color(0xFF1C2732)),

              // Vertical radar line
              Container(width: 1, height: 145, color: const Color(0xFF1C2732)),

              // Center Glow
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.18),
                      blurRadius: 35,
                      spreadRadius: 7,
                    ),
                  ],
                ),
              ),

              // Center Location
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: backgroundColor,
                  size: 25,
                ),
              ),

              // Detected Location Point
              Positioned(
                top: 43,
                right: 37,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.7),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// =============================================================
// GPS Status Dot
// =============================================================

class _StatusDot extends StatefulWidget {
  const _StatusDot();

  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.4,
      upperBound: 1,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: controller,
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          color: _LoginScreenState.primaryColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
