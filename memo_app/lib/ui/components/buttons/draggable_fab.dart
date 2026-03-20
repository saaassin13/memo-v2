import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A draggable floating action button that remembers its position (Bug 14).
class DraggableFab extends StatefulWidget {
  /// Creates a DraggableFab.
  const DraggableFab({
    super.key,
    required this.child,
    required this.onPressed,
    this.initialOffset,
    this.storageKey = 'fab_position',
  });

  /// The FAB widget content.
  final Widget child;

  /// Called when the FAB is pressed.
  final VoidCallback onPressed;

  /// Initial offset if no stored position exists.
  final Offset? initialOffset;

  /// Key used to store position in SharedPreferences.
  final String storageKey;

  @override
  State<DraggableFab> createState() => _DraggableFabState();
}

class _DraggableFabState extends State<DraggableFab> {
  Offset? _position;
  bool _isDragging = false;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadPosition();
  }

  Future<void> _loadPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final x = prefs.getDouble('${widget.storageKey}_x');
    final y = prefs.getDouble('${widget.storageKey}_y');

    if (mounted) {
      setState(() {
        if (x != null && y != null) {
          _position = Offset(x, y);
        }
        _isLoaded = true;
      });
    }
  }

  Future<void> _savePosition(Offset position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('${widget.storageKey}_x', position.dx);
    await prefs.setDouble('${widget.storageKey}_y', position.dy);
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details, Size screenSize) {
    setState(() {
      final newX = (_position?.dx ?? 0) + details.delta.dx;
      final newY = (_position?.dy ?? 0) + details.delta.dy;

      // Constrain to screen bounds with padding
      const padding = 16.0;
      const fabSize = 56.0;

      _position = Offset(
        newX.clamp(padding, screenSize.width - fabSize - padding),
        newY.clamp(padding, screenSize.height - fabSize - padding - 100), // Account for bottom nav
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
    if (_position != null) {
      _savePosition(_position!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;

    // Default position: bottom right
    final defaultPosition = widget.initialOffset ??
        Offset(
          screenSize.width - 72,
          screenSize.height - 200,
        );

    final position = _position ?? defaultPosition;

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: (details) => _onPanUpdate(details, screenSize),
        onPanEnd: _onPanEnd,
        onTap: _isDragging ? null : widget.onPressed,
        child: AnimatedScale(
          scale: _isDragging ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: AnimatedOpacity(
            opacity: _isDragging ? 0.8 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// A wrapper widget that provides a Stack for the draggable FAB.
class DraggableFabScaffold extends StatelessWidget {
  /// Creates a DraggableFabScaffold.
  const DraggableFabScaffold({
    super.key,
    required this.body,
    required this.fabChild,
    required this.onFabPressed,
    this.fabStorageKey = 'fab_position',
    this.fabBackgroundColor,
    this.fabForegroundColor,
  });

  /// The main body content.
  final Widget body;

  /// The FAB icon or content.
  final Widget fabChild;

  /// Called when FAB is pressed.
  final VoidCallback onFabPressed;

  /// Storage key for FAB position.
  final String fabStorageKey;

  /// FAB background color.
  final Color? fabBackgroundColor;

  /// FAB foreground color.
  final Color? fabForegroundColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        body,
        DraggableFab(
          storageKey: fabStorageKey,
          onPressed: onFabPressed,
          child: FloatingActionButton(
            onPressed: null, // Handled by DraggableFab
            backgroundColor: fabBackgroundColor ?? Theme.of(context).colorScheme.primary,
            foregroundColor: fabForegroundColor ?? Theme.of(context).colorScheme.onPrimary,
            child: fabChild,
          ),
        ),
      ],
    );
  }
}
