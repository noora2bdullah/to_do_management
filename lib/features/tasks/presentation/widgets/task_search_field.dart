import 'package:flutter/material.dart';

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
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
  }

  @override
  void didUpdateWidget(covariant TaskSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.query,
        selection: TextSelection.collapsed(offset: widget.query.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        labelText: 'Search tasks',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                onPressed: () {
                  _controller.clear();
                  widget.onChanged('');
                },
                icon: const Icon(Icons.close),
              ),
      ),
      onChanged: widget.onChanged,
    );
  }
}
