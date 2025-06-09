import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton()),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
<<<<<<< HEAD
            const Text(
              "Forgot Password",
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 18),
            ),
            const SizedBox(height: 16),
            const Text(
              "Enter your email and we will send you instruction on how to reset it",
            ),
=======
            const Text("Forgot Password", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 18)),
            const SizedBox(height: 16),
            const Text("Enter your email and we will send you instruction on how to reset it"),
>>>>>>> 8e2652df52e4a792f0b040a5d62200b66d82b0fb

            const SizedBox(height: 32),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Email',
                filled: true,
                fillColor: Color(0xFFF1F1F5),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
<<<<<<< HEAD
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text(
                "Send",
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
=======
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              child: const Text("Send", style: TextStyle(fontStyle: FontStyle.italic)),
>>>>>>> 8e2652df52e4a792f0b040a5d62200b66d82b0fb
            ),
          ],
        ),
      ),
    );
  }
}
