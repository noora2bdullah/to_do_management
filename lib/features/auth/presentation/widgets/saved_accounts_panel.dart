import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_user.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class SavedAccountsPanel extends StatelessWidget {
  const SavedAccountsPanel({
    required this.accounts,
    required this.selectedEmail,
    required this.enabled,
    super.key,
  });

  final List<AppUser> accounts;
  final String? selectedEmail;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) {
      return const SizedBox.shrink();
    }

    final selectedAccount = accounts
        .where((account) => account.email == selectedEmail)
        .firstOrNull;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: selectedAccount?.email,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Recent account',
              prefixIcon: Icon(Icons.account_circle_outlined),
            ),
            hint: const Text('Choose account'),
            items: [
              for (final account in accounts)
                DropdownMenuItem<String>(
                  value: account.email,
                  child: Text(account.email, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: enabled
                ? (email) {
                    if (email == null) {
                      return;
                    }

                    context.read<AuthBloc>().add(
                      AuthSavedAccountSelected(email),
                    );
                  }
                : null,
          ),
        ),
        const SizedBox(width: 10),
        IconButton.filledTonal(
          tooltip: 'Forget selected account',
          onPressed: enabled && selectedAccount != null
              ? () {
                  context.read<AuthBloc>().add(
                    AuthSavedAccountForgotten(selectedAccount.id),
                  );
                }
              : null,
          icon: const Icon(Icons.close),
          style: IconButton.styleFrom(
            fixedSize: const Size.square(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
