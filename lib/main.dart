import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const TenetApp());
}

class TenetApp extends StatelessWidget {
  const TenetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const TenetScreen(),
    );
  }
}

class TenetScreen extends StatefulWidget {
  const TenetScreen({super.key});

  @override
  State<TenetScreen> createState() => _TenetScreenState();
}

class _TenetScreenState extends State<TenetScreen> {
  int _entropy = 0;
  String _origText = '';
  String _revText = '';
  String _statusMessage = 'SYSTEM READY';
  final TextEditingController _controller = TextEditingController();

  void _handleInput() {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    setState(() {
      if (input.toLowerCase() == 'tenet') {
        _entropy = 0;
        _origText = '';
        _revText = '';
        _statusMessage = 'SYSTEM RESET: STABLE';
        _controller.clear();
        return;
      }

      final value = int.tryParse(input);
      if (value != null) {
        _entropy += value;
        if (_entropy > 200) _revText = _processText(_origText);
      } else {
        _origText = input.toUpperCase();
        _revText = _processText(input);
      }

      if (_entropy > 200) {
        _statusMessage = 'STATUS: CRITICAL ERROR';
      } else if (_entropy == 0) {
        _statusMessage = 'ZERO ENTROPY: INVERSION DISABLED';
      } else {
        _statusMessage = 'STATUS: INVERSION ACTIVE';
      }
      _controller.clear();
    });
  }

  String _processText(String input) {
    if (_entropy == 0) return input.toUpperCase();
    if (_entropy > 200) {
      return (input.split('')..shuffle(Random())).join().toUpperCase();
    }
    return input.split('').reversed.join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bool isCritical = _entropy > 200;
    final Color themeColor = isCritical ? Colors.redAccent : Colors.cyanAccent;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('T E N E T', style: TextStyle(letterSpacing: 10)),
        centerTitle: true,
        backgroundColor: isCritical ? Colors.red[900] : Colors.blueGrey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildEntropyBox(themeColor, isCritical),

            const SizedBox(height: 30),

            if (_origText.isNotEmpty) _buildResultBox(themeColor),

            const Spacer(),

            TextField(
              controller: _controller,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'Enter text or number',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: themeColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: themeColor, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _handleInput,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  foregroundColor: Colors.black,
                ),
                child: const Text(
                  'PROCESS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntropyBox(Color color, bool isCritical) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(border: Border.all(color: color, width: 2)),
      child: Column(
        children: [
          Text(
            'ENTROPY LEVEL',
            style: TextStyle(color: color, letterSpacing: 2),
          ),
          Text(
            '$_entropy',
            style: const TextStyle(fontSize: 90, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            _statusMessage,
            style: TextStyle(
              color: color,
              fontFamily: 'monospace',
              fontSize: 14,
              fontWeight: isCritical ? FontWeight.bold : FontWeight.normal,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResultBox(Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      color: color.withValues(alpha: 0.8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_origText, style: const TextStyle(color: Colors.white54)),
          const SizedBox(width: 15),
          Icon(Icons.arrow_forward, color: color),
          const SizedBox(width: 15),
          Text(
            _revText,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
