import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:project_smp_tsu_application/controllers/auth_controller.dart';
import 'package:project_smp_tsu_application/models/auth_model.dart';
import 'package:project_smp_tsu_application/pages/AdminView/HomeAdmin.dart';
import 'package:project_smp_tsu_application/pages/RegisterPage.dart';
import 'package:project_smp_tsu_application/provider/admin_provider.dart';
import 'package:project_smp_tsu_application/utils/animations.dart';
import 'package:provider/provider.dart';

import '../data/bg_data.dart';
import '../utils/text_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  int selectedIndex = 0;
  bool showOption = false;

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn(); // ตรวจสอบสถานะการล็อกอิน
  }

  void _checkIfLoggedIn() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      if (adminProvider.admin != null) {
        // หากผู้ใช้ล็อกอินอยู่แล้ว ให้ไปที่หน้า HomeAdminScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeAdminScreen()),
        );
      }
    });
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        AdminModel adminModel = await AuthController()
            .login(context, _usernameController.text, _passwordController.text);

        if (!mounted) return;

        Provider.of<AdminProvider>(context, listen: false).onLogin(adminModel);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeAdminScreen()),
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
          height: 400,
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
                          text: "Login",
                          weight: true,
                          size: 30,
                        )),
                        const Spacer(),
                        TextUtil(
                          text: "Username",
                        ),
                        Container(
                          height: 35,
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Colors.white))),
                          child: TextFormField(
                            controller: _usernameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              suffixIcon: Icon(
                                Icons.account_circle,
                                color: Colors.white,
                              ),
                              fillColor: Colors.white,
                              border: InputBorder.none,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your username';
                              }
                              return null;
                            },
                          ),
                        ),
                        const Spacer(),
                        TextUtil(
                          text: "Password",
                        ),
                        Container(
                          height: 35,
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Colors.white))),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: true, // ซ่อนรหัสผ่าน
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              suffixIcon: Icon(
                                Icons.lock,
                                color: Colors.white,
                              ),
                              fillColor: Colors.white,
                              border: InputBorder.none,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Container(
                              height: 15,
                              width: 15,
                              color: Colors.white,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: TextUtil(
                              text: "Remember Me , FORGET PASSWORD",
                              size: 12,
                              weight: true,
                            ))
                          ],
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _login, // เชื่อมต่อกับฟังก์ชัน _login
                          child: Container(
                            height: 40,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30)),
                            alignment: Alignment.center,
                            child: TextUtil(
                              text: "Log In",
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
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: TextUtil(
                            text: "Don't have a account REGISTER",
                            size: 12,
                            weight: true,
                          ),
                        )),
                        const Spacer(),
                      ],
                    ),
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
