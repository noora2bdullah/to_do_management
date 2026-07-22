import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/widgets/app_widgets.dart';

class TaskSearchField extends StatefulWidget {
  const TaskSearchField({
    required this.query,
    required this.onChanged,
    super.key,
  });

  final String query;
  final ValueChanged<String> onChanged;

  @override
  State<TaskSearchField> createState() => _TaskSearchFieldState();
}

class _TaskSearchFieldState extends State<TaskSearchField> {
  static const _debounceDuration = Duration(milliseconds: 220);

  late final TextEditingController _controller;
  Timer? _debounce;
  bool _isSyncingText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
    _controller.addListener(_handleTextChanged);
  }

  @override
  void didUpdateWidget(covariant TaskSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != _controller.text) {
      _debounce?.cancel();
      _isSyncingText = true;
      _controller.value = TextEditingValue(
        text: widget.query,
        selection: TextSelection.collapsed(offset: widget.query.length),
      );
      _isSyncingText = false;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _handleTextChanged() {
    if (_isSyncingText) {
      return;
    }

    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, () {
      widget.onChanged(_controller.text);
    });
  }

  void _submitSearch(String value) {
    FocusManager.instance.primaryFocus?.unfocus();
    _debounce?.cancel();
    widget.onChanged(value);
  }

  void _clearSearch() {
    _debounce?.cancel();
    _isSyncingText = true;
    _controller.clear();
    _isSyncingText = false;
    setState(() {});
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: _controller,
      textInputAction: TextInputAction.search,
      labelText: 'Search tasks',
      prefixIcon: Icons.search,
      suffixIcon: _controller.text.isEmpty
          ? null
          : IconButton(
              tooltip: 'Clear search',
              onPressed: _clearSearch,
              icon: const Icon(Icons.close),
            ),
      onSubmitted: _submitSearch,
    );
  }
}
