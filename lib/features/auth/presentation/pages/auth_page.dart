import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(AuthState state) {
    FocusScope.of(context).unfocus();
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final theme = Theme.of(context);

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1020),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 820;
                      final form = _AuthFormCard(
                        formKey: _formKey,
                        state: state,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        onSubmit: () => _submit(state),
                      );

                      if (!isWide) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _AuthBrandPanel(compact: true),
                            const SizedBox(height: 24),
                            form,
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Expanded(child: _AuthBrandPanel()),
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
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
            child: Text(
              'TaskFlow',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AuthBrandPanel extends StatelessWidget {
  const _AuthBrandPanel({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: compact
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Container(
          width: compact ? 72 : 92,
          height: compact ? 72 : 92,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.task_alt,
            size: compact ? 40 : 52,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'TaskFlow',
          textAlign: compact ? TextAlign.center : TextAlign.start,
          style:
              (compact
                      ? theme.textTheme.headlineLarge
                      : theme.textTheme.displaySmall)
                  ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Text(
          'Plan work, track progress, and keep every device in sync.',
          textAlign: compact ? TextAlign.center : TextAlign.start,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _AuthFormCard extends StatelessWidget {
  const _AuthFormCard({
    required this.formKey,
    required this.state,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final AuthState state;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bloc = context.read<AuthBloc>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<AuthFormMode>(
                selected: {state.formMode},
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: AuthFormMode.signIn,
                    icon: Icon(Icons.login),
                    label: Text('Sign in'),
                  ),
                  ButtonSegment(
                    value: AuthFormMode.signUp,
                    icon: Icon(Icons.person_add_alt),
                    label: Text('Create'),
                  ),
                ],
                onSelectionChanged: state.isSubmitting
                    ? null
                    : (selection) {
                        bloc.add(AuthFormModeChanged(selection.first));
                      },
              ),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: Text(
                  state.isSignIn ? 'Welcome back' : 'Create account',
                  key: ValueKey(state.formMode),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.alternate_email),
                ),
                validator: _emailValidator,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: passwordController,
                obscureText: state.obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onFieldSubmitted: (_) => onSubmit(),
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
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
                ),
                validator: _passwordValidator,
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
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: state.isSubmitting ? null : onSubmit,
                icon: state.isSubmitting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : Icon(state.isSignIn ? Icons.login : Icons.person_add_alt),
                label: Text(state.isSignIn ? 'Sign in' : 'Create account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String? _emailValidator(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) {
    return 'Email is required.';
  }
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
    return 'Enter a valid email address.';
  }

  return null;
}

String? _passwordValidator(String? value) {
  final password = value ?? '';
  if (password.isEmpty) {
    return 'Password is required.';
  }
  if (password.length < 6) {
    return 'Password must be at least 6 characters.';
  }

  return null;
}
