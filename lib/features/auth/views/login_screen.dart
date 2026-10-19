import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gradient_ring.dart';
import '../../../core/widgets/aurora_background.dart';
import '../../../core/widgets/live_qr_logo.dart';
import '../../../core/utils/validators.dart';
import '../view_models/auth_view_model.dart';
import 'widgets/floating_tiles.dart';
import 'widgets/login_hero.dart';

const _fieldBorder = Color(0xFFE2E8F0);

/// Sign in or create an account. Opened on top of another screen, it closes itself
/// with `true` as soon as the user is signed in, so the caller can carry on.
class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  /// Opens the login screen; completes with true once the user has signed in.
  static Future<bool> open(BuildContext context) async =>
      await Navigator.of(
        context,
      ).push<bool>(MaterialPageRoute(builder: (_) => const LoginScreen())) ??
      false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authUserProvider, (_, next) {
      if (next.value != null && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      }
    });
    final isSignUp = useState(false);
    void toggleMode() => isSignUp.value = !isSignUp.value;

    return Scaffold(
      backgroundColor: AppColors.sky,
      body: AuroraBackground(
        child: Stack(
          children: [
            if (MediaQuery.sizeOf(context).width >= 720)
              const Positioned.fill(child: FloatingTiles()),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 1100;
                final topBar = _TopBar(
                  isSignUp: isSignUp.value,
                  onToggle: toggleMode,
                  showPrompt: constraints.maxWidth >= 600,
                );
                // The page never scrolls: the card shrinks to fit the height that is left.
                Widget fitted(double width) => Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: width,
                      child: _AuthCard(isSignUp: isSignUp.value),
                    ),
                  ),
                );

                if (!wide) {
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: Column(
                        children: [
                          topBar,
                          const SizedBox(height: 16),
                          Expanded(
                            child: fitted(
                              (constraints.maxWidth - 32).clamp(0, 520),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.fromLTRB(80, 24, 48, 24),
                  child: Column(
                    children: [
                      topBar,
                      const SizedBox(height: 16),
                      Expanded(
                        child: Row(
                          children: [
                            // The showcase takes all the room up to the card, so the scene centres in the gap.
                            const Expanded(child: LoginShowcase()),
                            const SizedBox(width: 40),
                            SizedBox(width: 500, child: fitted(500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.isSignUp,
    required this.onToggle,
    required this.showPrompt,
  });

  final bool isSignUp;
  final VoidCallback onToggle;
  final bool showPrompt;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (Navigator.of(context).canPop()) ...[
          IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).pop(false),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 8),
        ],
        const LiveQrLogo(size: 46),
        const Spacer(),
        if (showPrompt) ...[
          Text(
            isSignUp ? 'Already have an account?' : 'New to Live QR?',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(width: 14),
        ],
        OutlinedButton(
          onPressed: onToggle,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            backgroundColor: Colors.white.withValues(alpha: 0.6),
            side: BorderSide(color: AppColors.primary.withValues(alpha: 0.18)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          child: Text(isSignUp ? 'Sign in' : 'Create an account'),
        ),
      ],
    );
  }
}

class _AuthCard extends HookConsumerWidget {
  const _AuthCard({required this.isSignUp});

  final bool isSignUp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailCtrl = useTextEditingController();
    final passwordCtrl = useTextEditingController();
    final obscure = useState(true);
    final formKey = useMemoized(GlobalKey<FormState>.new);

    final isLoading = ref.watch(authViewModelProvider);
    final vm = ref.read(authViewModelProvider.notifier);

    void submit() {
      if (isLoading || formKey.currentState?.validate() != true) return;
      final email = emailCtrl.text.trim();
      isSignUp
          ? vm.signUpWithEmail(email, passwordCtrl.text)
          : vm.signInWithEmail(email, passwordCtrl.text);
    }

    void forgotPassword() {
      final email = emailCtrl.text.trim();
      if (Validators.email(email) != null) {
        formKey.currentState?.validate();
        return;
      }
      vm.sendPasswordReset(email);
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    final compact = screenWidth < 480;

    return GradientRing(
      radius: 30,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          compact ? 20 : 36,
          compact ? 32 : 44,
          compact ? 20 : 36,
          compact ? 24 : 32,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .94),
          borderRadius: BorderRadius.circular(28.5),
        ),
        child: AutofillGroup(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isSignUp ? 'Create your account' : 'Welcome back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTheme.displayFont,
                    fontSize: compact ? 30 : 40,
                    fontWeight: FontWeight.w700,
                    letterSpacing: compact ? -1.2 : -1.6,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isSignUp
                      ? 'Start building your QR page in minutes'
                      : 'Sign in to your account to continue',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                const _FieldLabel('Email address'),
                TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  enabled: !isLoading,
                  decoration: _decoration(
                    hint: 'you@company.com',
                    icon: Icons.mail_outline_rounded,
                  ),
                  validator: Validators.email,
                ),
                const SizedBox(height: 22),
                const _FieldLabel('Password'),
                TextFormField(
                  controller: passwordCtrl,
                  obscureText: obscure.value,
                  autofillHints: [
                    isSignUp
                        ? AutofillHints.newPassword
                        : AutofillHints.password,
                  ],
                  enabled: !isLoading,
                  onFieldSubmitted: (_) => submit(),
                  decoration: _decoration(
                    hint: isSignUp
                        ? 'At least 6 characters'
                        : 'Enter your password',
                    icon: Icons.lock_outline_rounded,
                    suffix: IconButton(
                      tooltip: obscure.value
                          ? 'Show password'
                          : 'Hide password',
                      icon: Icon(
                        obscure.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textHint,
                      ),
                      onPressed: () => obscure.value = !obscure.value,
                    ),
                  ),
                  // Firebase's minimum password length is 6.
                  validator: (v) => Validators.password(v, minLength: 6),
                ),
                if (isSignUp)
                  const SizedBox(height: 28)
                else
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TextButton(
                        onPressed: isLoading ? null : forgotPassword,
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                _GradientButton(
                  label: isSignUp ? 'Create account' : 'Sign in',
                  isLoading: isLoading,
                  onPressed: submit,
                ),
                const SizedBox(height: 28),
                const Row(
                  children: [
                    Expanded(child: Divider(color: _fieldBorder)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    Expanded(child: Divider(color: _fieldBorder)),
                  ],
                ),
                const SizedBox(height: 24),
                _SocialButtons(
                  onGoogle: isLoading ? null : vm.signInWithGoogle,
                  onApple: isLoading ? null : vm.signInWithApple,
                ),
                const SizedBox(height: 24),
                const Divider(color: _fieldBorder),
                const SizedBox(height: 20),
                // ponytail: Terms/Privacy are styled but not linked; add URLs once those pages exist.
                const Text.rich(
                  TextSpan(
                    text: 'By continuing, you agree to our ',
                    children: [
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(color: AppColors.primary),
                      ),
                      TextSpan(text: '\nand '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(color: AppColors.primary),
                      ),
                      TextSpan(text: '.'),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static InputDecoration _decoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textHint),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 16, right: 10),
        child: Icon(icon, color: AppColors.textHint),
      ),
      suffixIcon: suffix == null
          ? null
          : Padding(padding: const EdgeInsets.only(right: 6), child: suffix),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 20),
      border: border(_fieldBorder),
      enabledBorder: border(_fieldBorder),
      disabledBorder: border(_fieldBorder),
      focusedBorder: border(AppColors.primary, 1.5),
      errorBorder: border(AppColors.error),
      focusedErrorBorder: border(AppColors.error, 1.5),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(30);
    return Semantics(
      button: true,
      enabled: !isLoading,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          height: 58,
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: radius,
          ),
          child: InkWell(
            borderRadius: radius,
            onTap: isLoading ? null : onPressed,
            child: Center(
              child: isLoading
                  ? const SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-width "Continue with" buttons: white for Google, black for Apple (each brand's own style).
class _SocialButtons extends StatelessWidget {
  const _SocialButtons({required this.onGoogle, required this.onApple});

  final VoidCallback? onGoogle;
  final VoidCallback? onApple;

  @override
  Widget build(BuildContext context) {
    ButtonStyle style({
      required Color background,
      required Color foreground,
      Color? border,
    }) => ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size.fromHeight(54)),
      // Desktop defaults to compact density, which would shave the height.
      visualDensity: VisualDensity.standard,
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      side: WidgetStatePropertyAll(BorderSide(color: border ?? background)),
      // Dim instead of the default grey-out while a sign-in is in progress.
      backgroundColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.disabled)
            ? background.withValues(alpha: .6)
            : background,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.disabled)
            ? foreground.withValues(alpha: .6)
            : foreground,
      ),
      overlayColor: WidgetStatePropertyAll(foreground.withValues(alpha: .06)),
      elevation: const WidgetStatePropertyAll(0),
      shadowColor: const WidgetStatePropertyAll(Colors.transparent),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(
          fontFamily: AppTheme.bodyFont,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withValues(alpha: .06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: OutlinedButton.icon(
            onPressed: onGoogle,
            style: style(
              background: Colors.white,
              foreground: AppColors.textPrimary,
              border: _fieldBorder,
            ),
            icon: Opacity(
              opacity: onGoogle == null ? .6 : 1,
              child: SvgPicture.asset(
                'assets/svg/google_logo.svg',
                width: 20,
                height: 20,
              ),
            ),
            label: const Text('Continue with Google'),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: onApple,
          style: style(background: Colors.black, foreground: Colors.white),
          icon: const Icon(Icons.apple, size: 24),
          label: const Text('Continue with Apple'),
        ),
      ],
    );
  }
}
