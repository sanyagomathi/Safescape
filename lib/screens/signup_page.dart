import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String gender = "Male";

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void signUp() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account Created!")),
      );

      Navigator.pop(context);
    }
  }

  Widget inputField(
      {required String hint,
      required IconData icon,
      required TextEditingController controller,
      bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: (value) =>
            value!.isEmpty ? "Please enter $hint" : null,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hint,
          filled: true,
          fillColor: Colors.white.withOpacity(.9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-1 + _controller.value * 2, -1),
                end: Alignment(1 - _controller.value * 2, 1),
                colors: const [
                  Color(0xff0f2027),
                  Color(0xff2c5364),
                  Color(0xff1c92d2),
                ],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        const Text(
                          "Create Account",
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),

                        const SizedBox(height: 30),

                        inputField(
                          hint: "Full Name",
                          icon: Icons.person,
                          controller: nameController,
                        ),

                        const SizedBox(height: 10),

                        DropdownButtonFormField(
                          value: gender,
                          items: const [
                            DropdownMenuItem(
                                value: "Male", child: Text("Male")),
                            DropdownMenuItem(
                                value: "Female", child: Text("Female")),
                            DropdownMenuItem(
                                value: "Other", child: Text("Other")),
                          ],
                          onChanged: (value) {
                            setState(() {
                              gender = value!;
                            });
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withOpacity(.9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        inputField(
                          hint: "Email",
                          icon: Icons.email,
                          controller: emailController,
                        ),

                        const SizedBox(height: 10),

                        inputField(
                          hint: "Password",
                          icon: Icons.lock,
                          controller: passwordController,
                          obscure: true,
                        ),

                        const SizedBox(height: 25),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: signUp,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              "SIGN UP",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Already have an account? Login",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}