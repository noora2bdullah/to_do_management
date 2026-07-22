import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_text_style.dart';
import '../../domain/entities/app_user.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class AuthAccountMenu extends StatelessWidget {
  const AuthAccountMenu({required this.user, super.key});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        return previous.errorMessage != current.errorMessage &&
            current.errorMessage != null &&
            !current.isSubmitting;
      },
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              behavior: SnackBarBehavior.floating,
            ),
          );
      },
      child: BlocSelector<AuthBloc, AuthState, List<AppUser>>(
        selector: (state) => state.savedAccounts,
        builder: (context, savedAccounts) {
          final colorScheme = Theme.of(context).colorScheme;
          final switchableAccounts = savedAccounts
              .where((account) => account.id != user.id)
              .toList();

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 180),
                child: Text(
                  user.email,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.style14Bold.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              PopupMenuButton<_AccountMenuSelection>(
                tooltip: 'Account',
                icon: const Icon(Icons.account_circle_outlined),
                onSelected: (selection) => _handleSelection(context, selection),
                itemBuilder: (context) {
                  return [
                    PopupMenuItem<_AccountMenuSelection>(
                      enabled: false,
                      child: _AccountMenuHeader(email: user.email),
                    ),
                    const PopupMenuDivider(),
                    if (switchableAccounts.isNotEmpty)
                      PopupMenuItem<_AccountMenuSelection>(
                        value: _SwitchAccountsSelection(switchableAccounts),
                        child: const _AccountMenuRow(
                          icon: Icons.swap_horiz,
                          label: 'Switch account',
                        ),
                      ),
                    const PopupMenuItem<_AccountMenuSelection>(
                      value: _AddAccountSelection(),
                      child: _AccountMenuRow(
                        icon: Icons.person_add_alt,
                        label: 'Add another account',
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem<_AccountMenuSelection>(
                      value: _SignOutSelection(),
                      child: _AccountMenuRow(
                        icon: Icons.logout,
                        label: 'Sign out',
                      ),
                    ),
                  ];
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _handleSelection(BuildContext context, _AccountMenuSelection selection) {
    final bloc = context.read<AuthBloc>();
    switch (selection) {
      case _SwitchAccountsSelection(:final accounts):
        bloc.add(const AuthMessageCleared());
        showDialog<void>(
          context: context,
          builder: (_) {
            return BlocProvider.value(
              value: bloc,
              child: _SwitchAccountDialog(
                currentUser: user,
                accounts: accounts,
              ),
            );
          },
        ).whenComplete(() => bloc.add(const AuthMessageCleared()));
      case _AddAccountSelection():
        bloc.add(const AuthAddAccountRequested());
      case _SignOutSelection():
        bloc.add(const AuthSignOutRequested());
    }
  }
}

sealed class _AccountMenuSelection {
  const _AccountMenuSelection();
}

final class _AddAccountSelection extends _AccountMenuSelection {
  const _AddAccountSelection();
}

final class _SwitchAccountsSelection extends _AccountMenuSelection {
  const _SwitchAccountsSelection(this.accounts);

  final List<AppUser> accounts;
}

final class _SignOutSelection extends _AccountMenuSelection {
  const _SignOutSelection();
}

class _AccountMenuHeader extends StatelessWidget {
  const _AccountMenuHeader({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(Icons.check_circle, color: colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            email,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.style14Bold.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _SwitchAccountDialog extends StatelessWidget {
  const _SwitchAccountDialog({
    required this.currentUser,
    required this.accounts,
  });

  final AppUser currentUser;
  final List<AppUser> accounts;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AuthBloc, AuthState, bool>(
      selector: (state) => state.isSubmitting,
      builder: (context, isSubmitting) {
        final colorScheme = Theme.of(context).colorScheme;

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppTextStyle.surfaceGradient(
                  colorScheme,
                  tintColor: colorScheme.secondary,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SwitchAccountHeader(enabled: !isSubmitting),
                    const SizedBox(height: 18),
                    _CurrentAccountPanel(user: currentUser),
                    const SizedBox(height: 14),
                    _AccountChoiceList(
                      accounts: accounts,
                      enabled: !isSubmitting,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SwitchAccountHeader extends StatelessWidget {
  const _SwitchAccountHeader({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.switch_account,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Switch account',
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.style20Bold.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Close',
          onPressed: enabled ? () => Navigator.of(context).pop() : null,
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }
}

class _CurrentAccountPanel extends StatelessWidget {
  const _CurrentAccountPanel({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            _AccountAvatar(
              email: user.email,
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Current account',
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.style12SemiBold.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.style14Bold.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.check_circle, color: colorScheme.primary, size: 22),
          ],
        ),
      ),
    );
  }
}

class _AccountChoiceList extends StatelessWidget {
  const _AccountChoiceList({required this.accounts, required this.enabled});

  final List<AppUser> accounts;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 320),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTextStyle.surfaceBorderColor(colorScheme),
          ),
        ),
        child: ListView.separated(
          padding: const EdgeInsets.all(8),
          shrinkWrap: true,
          itemCount: accounts.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final account = accounts[index];

            return _AccountChoiceTile(
              account: account,
              enabled: enabled,
              onSelected: () {
                final bloc = context.read<AuthBloc>();
                Navigator.of(context).pop();
                bloc.add(AuthSavedAccountSwitchRequested(account));
              },
            );
          },
        ),
      ),
    );
  }
}

class _AccountChoiceTile extends StatelessWidget {
  const _AccountChoiceTile({
    required this.account,
    required this.enabled,
    required this.onSelected,
  });

  final AppUser account;
  final bool enabled;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final contentColor = enabled
        ? colorScheme.onSurface
        : colorScheme.onSurface.withValues(alpha: 0.48);

    return Material(
      color: colorScheme.surfaceContainerLowest,
      elevation: enabled ? 1 : 0,
      shadowColor: Colors.black.withValues(
        alpha: colorScheme.brightness == Brightness.dark ? 0.3 : 0.07,
      ),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: enabled ? onSelected : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              _AccountAvatar(
                email: account.email,
                backgroundColor: colorScheme.secondaryContainer,
                foregroundColor: colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  account.email,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.style14Bold.copyWith(color: contentColor),
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.swap_horiz,
                color: enabled
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.42),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountAvatar extends StatelessWidget {
  const _AccountAvatar({
    required this.email,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String email;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _accountInitial(email),
        style: AppTextStyle.style16Bold.copyWith(color: foregroundColor),
      ),
    );
  }
}

class _AccountMenuRow extends StatelessWidget {
  const _AccountMenuRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 12),
        Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

String _accountInitial(String email) {
  final trimmedEmail = email.trim();
  if (trimmedEmail.isEmpty) {
    return '?';
  }

  return trimmedEmail.substring(0, 1).toUpperCase();
}
