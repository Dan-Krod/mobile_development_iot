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
  final TextEditingController _controller = TextEditingController();

  void _handleInput() {
    setState(() => _controller.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("T E N E T"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            const Text("SYSTEM READY", style: TextStyle(fontSize: 20)),
            const Spacer(),
            TextField(controller: _controller, textAlign: TextAlign.center),
            const SizedBox(height: 15),
            ElevatedButton(onPressed: _handleInput, child: const Text("PROCESS")),
          ],
        ),
      ),
    );
  }
}