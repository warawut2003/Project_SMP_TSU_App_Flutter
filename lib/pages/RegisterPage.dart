import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:project_smp_tsu_application/controllers/auth_controller.dart';
import 'package:project_smp_tsu_application/pages/LoginPage.dart';
import 'package:project_smp_tsu_application/utils/animations.dart';
import '../data/bg_data.dart';
import '../utils/text_utils.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fnameController = TextEditingController();
  final _lnameController = TextEditingController();
  final _telController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int selectedIndex = 0;
  bool showOption = false;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        // ตัวอย่างการส่งข้อมูลไปยัง AuthController
        await AuthController().register(
          context,
          _usernameController.text,
          _passwordController.text,
          _fnameController.text,
          _lnameController.text,
          _telController.text,
          _emailController.text,
        );

        // หลังจาก register เสร็จสิ้น นำไปสู่หน้า login หรืออื่นๆ
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        height: 49,
        width: double.infinity,
        child: Row(
          children: [
            Expanded(
                child: showOption
                    ? ShowUpAnimation(
                        delay: 100,
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: bgList.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedIndex = index;
                                  });
                                },
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: selectedIndex == index
                                      ? Colors.white
                                      : Colors.transparent,
                                  child: Padding(
                                    padding: const EdgeInsets.all(1),
                                    child: CircleAvatar(
                                      radius: 30,
                                      backgroundImage: AssetImage(
                                        bgList[index],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                      )
                    : const SizedBox()),
            const SizedBox(
              width: 20,
            ),
            showOption
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        showOption = false;
                      });
                    },
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ))
                : GestureDetector(
                    onTap: () {
                      setState(() {
                        showOption = true;
                      });
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(1),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(
                            bgList[selectedIndex],
                          ),
                        ),
                      ),
                    ),
                  )
          ],
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(bgList[selectedIndex]), fit: BoxFit.fill),
        ),
        alignment: Alignment.center,
        child: Container(
          height: 800,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(15),
            color: Colors.black.withOpacity(0.1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaY: 5, sigmaX: 5),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      Center(
                        child: TextUtil(
                          text: "Register",
                          weight: true,
                          size: 30,
                        ),
                      ),
                      const Spacer(),
                      _buildTextField("Username", _usernameController, false),
                      _buildTextField("Password", _passwordController, true),
                      _buildTextField("First Name", _fnameController, false),
                      _buildTextField("Last Name", _lnameController, false),
                      _buildTextField("Telephone", _telController, false),
                      _buildTextField("Email", _emailController, false),
                      const Spacer(),
                      GestureDetector(
                        onTap: _register, // เชื่อมต่อกับฟังก์ชัน _register
                        child: Container(
                          height: 40,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30)),
                          alignment: Alignment.center,
                          child: TextUtil(
                            text: "Register",
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: TextUtil(
                            text: "Already have an account? LOGIN",
                            size: 12,
                            weight: true,
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, bool obscureText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextUtil(text: label),
        Container(
          height: 35,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white)),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              fillColor: Colors.white,
              border: InputBorder.none,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your $label';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
