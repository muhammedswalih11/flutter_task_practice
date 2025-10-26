import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Box box = Hive.box('myBox');

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? savedEmail;
  String? savedPassword;

  @override
  void initState() {
    super.initState();

    savedEmail = box.get('email');
    savedPassword = box.get('password');
    if (savedEmail != null) emailController.text = savedEmail!;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void saveCredentials() {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both email and password.')),
      );
      return;
    }

    box.put('email', email);
    box.put('password', password);

    setState(() {
      savedEmail = email;
      savedPassword = password;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Credentials saved to Hive.')));
  }

  void clearCredentials() {
    box.delete('email');
    box.delete('password');

    setState(() {
      savedEmail = null;
      savedPassword = null;
      emailController.clear();
      passwordController.clear();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Credentials cleared.')));
  }

  String maskedPassword(String? pwd) {
    if (pwd == null || pwd.isEmpty) return '';
    return '*' * pwd.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Email & Password (Hive)')),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: saveCredentials,
                      child: Text('Save'),
                    ),
                  ),
                  SizedBox(width: 8),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      onPressed: clearCredentials,
                      child: Text('Clear'),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),
              if (savedEmail != null || savedPassword != null) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Saved Email: ${savedEmail ?? ''}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Saved Password: ${maskedPassword(savedPassword)}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
