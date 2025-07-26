import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MaterialApp(home: KeyboardFocusFix()));

class KeyboardFocusFix extends StatefulWidget {
  @override
  State<KeyboardFocusFix> createState() => _KeyboardFocusFixState();
}

class _KeyboardFocusFixState extends State<KeyboardFocusFix> {
  final FocusNode _appFocusNode = FocusNode();
  final FocusNode _field1 = FocusNode();
  final FocusNode _field2 = FocusNode();

  @override
  void initState() {
    super.initState();
    // Request focus when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_appFocusNode);
    });
  }

  void _handleKey(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final key = event.logicalKey;
      if (key == LogicalKeyboardKey.keyA) {
        FocusScope.of(context).requestFocus(_field1);
      } else if (key == LogicalKeyboardKey.keyB) {
        FocusScope.of(context).requestFocus(_field2);
      }
    }
  }

  void _onScreenTapped() {
    // Re-focus the global keyboard listener when tapping outside
    FocusScope.of(context).requestFocus(_appFocusNode);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onScreenTapped,
      behavior: HitTestBehavior.translucent, // allows tap detection outside widgets
      child: Scaffold(
        body: Focus(
          autofocus: true,
          focusNode: _appFocusNode,
          onKey: (_, event) {
            _handleKey(event);
            return KeyEventResult.handled;
          },
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  focusNode: _field1,
                  decoration: InputDecoration(labelText: 'Press A to focus me'),
                ),
                SizedBox(height: 20),
                TextField(
                  focusNode: _field2,
                  decoration: InputDecoration(labelText: 'Press B to focus me'),
                ),
                SizedBox(height: 40),
                Text('Tap outside fields to re-enable keyboard shortcuts'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
