import 'package:flutter/material.dart';

void main() => runApp(const TenetApp());

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
  String _origText = "";
  String _revText = "";
  String _statusMessage = "SYSTEM READY";
  final TextEditingController _controller = TextEditingController();

  void _handleInput() {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    setState(() {
      final value = int.tryParse(input);
      if (value != null) {
        _entropy += value;
        _statusMessage = "ENTROPY INCREASED";
      } else {
        _origText = input.toUpperCase();
        
        _revText = input.split('').reversed.join('').toUpperCase();
        _statusMessage = "INVERSION SUCCESSFUL";
      }
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("T E N E T", style: TextStyle(letterSpacing: 10)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("ENTROPY: $_entropy", style: const TextStyle(fontSize: 40)),
            Text(_statusMessage, style: const TextStyle(color: Colors.cyanAccent)),
            
            const SizedBox(height: 30),

            if (_origText.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_origText),
                  const Icon(Icons.arrow_forward),
                  Text(_revText, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),

            const Spacer(),

            TextField(
              controller: _controller,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(hintText: "Enter data"),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _handleInput,
                child: const Text("PROCESS"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}