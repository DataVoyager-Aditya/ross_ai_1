import 'package:flutter/material.dart';

class HoverToolTip extends StatefulWidget {
  final Widget child;
  final String message;

  const HoverToolTip({
    super.key,
    required this.child,
    required this.message,
  });

  @override
  State<HoverToolTip> createState() => _HoverToolTipState();
}

class _HoverToolTipState extends State<HoverToolTip> {
  OverlayEntry? _overlayEntry;

  void _showTooltip(PointerEvent event) {
    _overlayEntry = _createOverlayEntry(event);
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideTooltip(PointerEvent event) {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _updateTooltip(PointerEvent event) {
    _overlayEntry?.remove();
    _overlayEntry = _createOverlayEntry(event);
    Overlay.of(context).insert(_overlayEntry!);
  }

  OverlayEntry _createOverlayEntry(PointerEvent event) {
    return OverlayEntry(
      builder: (context) => Positioned(
        left: event.position.dx + 10,
        top: event.position.dy + 10,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              widget.message,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _showTooltip,
      onExit: _hideTooltip,
      onHover: _updateTooltip,
      child: widget.child,
    );
  }
}
