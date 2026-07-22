import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/functions/system/get_app_version.dart';
import '../../../../core/theme/app_text_style.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_brand_panel.dart';
import '../widgets/auth_form_card.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  static final Uri _recoveryWebsiteUri = Uri.parse('https://recoveryjo.com/');

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  final Future<String> _appVersionFuture = getAppVersion();
  String? _lastSyncedSelectedEmail;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _submit(AuthState state) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final bloc = context.read<AuthBloc>();

    if (state.isSignIn) {
      bloc.add(AuthSignInSubmitted(email: email, password: password));
    } else {
      bloc.add(AuthSignUpSubmitted(email: email, password: password));
    }
  }

  void _syncSelectedAccount(AuthState state) {
    final selectedEmail = state.selectedAccountEmail;
    if (selectedEmail == _lastSyncedSelectedEmail) {
      return;
    }

    _lastSyncedSelectedEmail = selectedEmail;
    _passwordController.clear();

    if (selectedEmail == null) {
      _emailController.clear();
      return;
    }

    _emailController.text = selectedEmail;
  }

  Future<void> _openRecoveryWebsite() async {
    final launched = await launchUrl(
      _recoveryWebsiteUri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open recoveryjo.com')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        _syncSelectedAccount(state);
        final colorScheme = Theme.of(context).colorScheme;

        return Scaffold(
          body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1020),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 820;
                        final form = AuthFormCard(
                          formKey: _formKey,
                          state: state,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          passwordFocusNode: _passwordFocusNode,
                          onSubmit: () => _submit(state),
                        );

                        if (!isWide) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const AuthBrandPanel(compact: true),
                              const SizedBox(height: 24),
                              form,
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Expanded(child: AuthBrandPanel()),
                            const SizedBox(width: 32),
                            Expanded(child: form),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: _openRecoveryWebsite,
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.onSurfaceVariant,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: AppTextStyle.style13Medium,
                  ),
                  child: Text(
                    'Recovery – Application Design and Marketing',
                    textAlign: TextAlign.center,
                    style: AppTextStyle.style13Medium.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                FutureBuilder<String>(
                  future: _appVersionFuture,
                  builder: (context, snapshot) {
                    final versionText =
                        snapshot.connectionState == ConnectionState.waiting ||
                            snapshot.hasError
                        ? 'v ...'
                        : 'v ${snapshot.data}';

                    return Text(
                      versionText,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
                      style: AppTextStyle.style13Medium.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
