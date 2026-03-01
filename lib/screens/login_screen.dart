import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_final_project_app_with_full_ui_and_api_crud_integration/widgets/TextTheme.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/auth_provider.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/glass_container.dart';

/// Tiimo-style login screen with email/password + GitHub sign-in.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSub;

  /// GitHub OAuth Client ID (must match .env on server)
  static const _githubClientId = 'Ov23li1ZMCSp7fR4ETjC';
  static const _githubRedirectUri =
      'http://127.0.0.1:8000/login/oauth2/code/github';

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _initDeepLinkListener();
  }

  /// Listen for incoming deep links (taskflow://auth?token=XXX)
  void _initDeepLinkListener() {
    _linkSub = _appLinks.uriLinkStream.listen((Uri uri) {
      _handleDeepLink(uri);
    });

    // Also check if the app was launched via a deep link
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) _handleDeepLink(uri);
    });
  }

  /// Process the taskflow://auth?token=XXX deep link
  Future<void> _handleDeepLink(Uri uri) async {
    if (uri.scheme == 'taskflow' && uri.host == 'auth') {
      final token = uri.queryParameters['token'];
      if (token != null && token.isNotEmpty) {
        final auth = context.read<AuthProvider>();
        try {
          // Set token and fetch user info
          ApiService.setToken(token);
          await auth.loginWithToken(token);

          if (mounted) {
            Navigator.pushReplacementNamed(context, '/');
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'GitHub login failed: ${e.toString().replaceFirst('Exception: ', '')}',
                  style: AppFonts.of(context),
                ),
                backgroundColor: AppConstants.errorColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    try {
      await auth.login(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      // Set token on ApiService for authenticated requests
      ApiService.setToken(auth.token);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceFirst('Exception: ', ''),
              style: AppFonts.of(context),
            ),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    AppConstants.darkBackground,
                    const Color(0xFF2C2C2C).withValues(alpha: 0.85),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.92),
                    const Color(0xFFF5F5F5).withValues(alpha: 0.88),
                    const Color(0xFFE0E0E0).withValues(alpha: 0.80),
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Logo ──
                  GlassContainer(
                    borderRadius: 40,
                    padding: const EdgeInsets.all(20),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 40,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppConstants.appName,
                    style: AppFonts.of(context, 
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppConstants.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Welcome back',
                    style: AppFonts.of(context, 
                      fontSize: 14,
                      color: isDark
                          ? Colors.white54
                          : AppConstants.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // ── Form Card ──
                  GlassContainer(
                    borderRadius: AppConstants.cardRadius,
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _emailCtrl,
                            label: 'Email',
                            hint: 'Enter your email',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.email,
                          ),
                          // Password field with toggle
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: TextFormField(
                              controller: _passwordCtrl,
                              obscureText: _obscurePassword,
                              validator: Validators.required,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : AppConstants.textPrimary,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                hintText: 'Enter your password',
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                  onPressed: () {
                                    setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    );
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: isDark
                                    ? AppConstants.glassInputDark
                                    : AppConstants.glassInputLight,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // ── Login Button ──
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: auth.isLoading ? null : _handleLogin,
                              child: auth.isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Log In',
                                      style: AppFonts.of(context, 
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Divider ──
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: isDark
                              ? Colors.white24
                              : AppConstants.textLight,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or',
                          style: AppFonts.of(context, 
                            color: isDark
                                ? Colors.white54
                                : AppConstants.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: isDark
                              ? Colors.white24
                              : AppConstants.textLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── GitHub Sign-In ──
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      icon: FaIcon(
                        FontAwesomeIcons.github,
                        size: 22,
                        color: isDark ? Colors.white : AppConstants.textPrimary,
                      ),
                      label: Text(
                        'Sign in with GitHub',
                        style: AppFonts.of(context, 
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : AppConstants.textPrimary,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isDark
                              ? Colors.white24
                              : AppConstants.textLight,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.defaultRadius,
                          ),
                        ),
                      ),
                      onPressed: auth.isLoading
                          ? null
                          : () async {
                              // Launch GitHub OAuth in browser
                              final url = Uri.parse(
                                'https://github.com/login/oauth/authorize'
                                '?client_id=$_githubClientId'
                                '&redirect_uri=${Uri.encodeComponent(_githubRedirectUri)}'
                                '&scope=user:email',
                              );
                              if (await canLaunchUrl(url)) {
                                await launchUrl(
                                  url,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Register link ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppFonts.of(context, 
                          color: isDark
                              ? Colors.white54
                              : AppConstants.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/register');
                        },
                        child: Text(
                          'Register',
                          style: AppFonts.of(context, 
                            color: AppConstants.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
