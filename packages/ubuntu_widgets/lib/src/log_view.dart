import 'dart:async';

import 'package:flutter/material.dart';

/// Views a stream of log lines.
class LogView extends StatefulWidget {
  /// Creates a log view. A stream of [log] lines is required.
  const LogView({
    required this.log,
    this.padding,
    this.decoration,
    this.background,
    this.style,
    this.scrollController,
    super.key,
  });

  /// The stream of log lines to show.
  final Stream<String> log;

  /// Padding around the log text.
  final EdgeInsetsGeometry? padding;

  /// See [TextField.decoration]
  final InputDecoration? decoration;

  /// See [Container.decoration]
  final Decoration? background;

  /// See [TextField.style]
  final TextStyle? style;

  /// See [TextField.scrollController]
  final ScrollController? scrollController;

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  StreamSubscription<String>? _subscription;
  final _controller = TextEditingController();
  late final _scrollController = widget.scrollController ?? ScrollController();

  @override
  void initState() {
    super.initState();
    _subscription = widget.log.listen(_appendLine);
    _scrollToEnd();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _appendText(String line) {
    final text = _controller.text;
    if (text.isEmpty) return line;
    return '$text\n$line';
  }

  void _appendLine(String line) {
    final wasAtEnd = _isAtEnd();

    final text = _appendText(line);
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );

    if (wasAtEnd) _scrollToEnd();
  }

  bool _isAtEnd() => _scrollController.position.extentAfter == 0;
  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  void didUpdateWidget(LogView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.log != widget.log) {
      _subscription?.cancel();
      _subscription = widget.log.listen(_appendLine);
    }
    _scrollToEnd();
  }

  @override
  Widget build(BuildContext context) {
    final contentPadding =
        (widget.decoration?.contentPadding ?? EdgeInsets.zero)
            .add(widget.padding ?? EdgeInsets.zero);
    final decoration = (widget.decoration ?? const InputDecoration())
        .copyWith(contentPadding: contentPadding);

    return DecoratedBox(
      decoration: widget.background ?? const BoxDecoration(),
      child: Scrollbar(
        key: const ValueKey('LogViewScrollbar'),
        thumbVisibility: true,
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: TextField(
            controller: _controller,
            decoration: decoration,
            readOnly: true,
            maxLines: null,
            style: widget.style,
          ),
        ),
      ),
    );
  }
}
