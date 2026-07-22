import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_text_style.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'auth_form_validators.dart';
import 'saved_accounts_panel.dart';

class AuthFormCard extends StatelessWidget {
  const AuthFormCard({
    required this.formKey,
    required this.state,
    required this.emailController,
    required this.passwordController,
    required this.passwordFocusNode,
    required this.onSubmit,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final AuthState state;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode passwordFocusNode;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bloc = context.read<AuthBloc>();

    return Card(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppTextStyle.surfaceGradient(
            colorScheme,
            tintColor: colorScheme.primary,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppSegmentedButton<AuthFormMode>(
                  selectedValue: state.formMode,
                  options: const [
                    AppSegmentedOption<AuthFormMode>(
                      value: AuthFormMode.signIn,
                      icon: Icon(Icons.login),
                      label: 'Sign in',
                    ),
                    AppSegmentedOption<AuthFormMode>(
                      value: AuthFormMode.signUp,
                      icon: Icon(Icons.person_add_alt),
                      label: 'Create',
                    ),
                  ],
                  onChanged: state.isSubmitting
                      ? null
                      : (mode) {
                          bloc.add(AuthFormModeChanged(mode));
                        },
                ),
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Text(
                    state.isSignIn ? 'Welcome back' : 'Create account',
                    key: ValueKey(state.formMode),
                    style: AppTextStyle.style24ExtraBold.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (state.isSignIn && state.savedAccounts.isNotEmpty) ...[
                  SavedAccountsPanel(
                    accounts: state.savedAccounts,
                    selectedEmail: state.selectedAccountEmail,
                    enabled: !state.isSubmitting,
                  ),
                  const SizedBox(height: 14),
                ],
                AppTextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  labelText: 'Email',
                  prefixIcon: Icons.alternate_email,
                  validator: AuthFormValidators.email,
                ),
                const SizedBox(height: 14),
                AppTextFormField(
                  controller: passwordController,
                  focusNode: passwordFocusNode,
                  obscureText: state.obscurePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onFieldSubmitted: (_) => onSubmit(),
                  labelText: 'Password',
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    tooltip: state.obscurePassword
                        ? 'Show password'
                        : 'Hide password',
                    onPressed: state.isSubmitting
                        ? null
                        : () {
                            bloc.add(const AuthPasswordVisibilityToggled());
                          },
                    icon: Icon(
                      state.obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                  validator: AuthFormValidators.password,
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: state.errorMessage == null
                      ? const SizedBox(height: 18)
                      : Container(
                          key: ValueKey(state.errorMessage),
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: AppTextStyle.tintedShadows(
                              colorScheme,
                              colorScheme.error,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: colorScheme.onErrorContainer,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  state.errorMessage!,
                                  style: AppTextStyle.style14Regular.copyWith(
                                    color: colorScheme.onErrorContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 18),
                AppFilledActionButton(
                  isLoading: state.isSubmitting,
                  onPressed: onSubmit,
                  icon: Icon(
                    state.isSignIn ? Icons.login : Icons.person_add_alt,
                  ),
                  label: Text(state.isSignIn ? 'Sign in' : 'Create account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
