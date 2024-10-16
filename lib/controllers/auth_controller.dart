import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_smp_tsu_application/varibles.dart';
import 'package:project_smp_tsu_application/provider/admin_provider.dart';
import 'package:project_smp_tsu_application/models/auth_model.dart';

import 'package:http/http.dart' as http;

class AuthController {
  Future<AdminModel> login(
      BuildContext context, String username, String password) async {
    print(apiURL);

    final response = await http.post(Uri.parse("$apiURL/api/auth/admin/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(
          {
            "admin_username": username,
            "admin_password": password,
          },
        ));

    print(response.statusCode);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      print('Response data: $data');
      AdminModel adminModel = AdminModel.fromJson(data);

      return adminModel;
    } else {
      throw Exception('Error: Invalid response structure');
    }
  }

  Future<void> register(BuildContext context, String username, String password,
      String Fname, String Lname, String tel, String email) async {
    final Map<String, dynamic> registerData = {
      "admin_username": username,
      "admin_password": password,
      "admin_Fname": Fname,
      "admin_Lname": Lname,
      "admin_tel": tel,
      "admin_email": email,
    };

    final response = await http.post(
      Uri.parse("$apiURL/api/auth/admin/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(registerData),
    );
    print(response.statusCode);

    if (response.statusCode == 201) {
      print('Registration Successfuly');
    } else {
      print('Registration failed');
    }
  }

  Future<void> refreshToken(BuildContext context) async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    final response = await http.post(
      Uri.parse("$apiURL/api/auth/admin/refresh"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${adminProvider.refreshToken}",
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      print(data);

      final accessToken = data['accessToken'];
      adminProvider
          .updateAccessToken(accessToken); // แก้ไขให้รับแค่ accessToken
    } else if (response.statusCode == 401) {
      const accessToken = "";
      adminProvider
          .updateAccessToken(accessToken); // แก้ไขให้รับแค่ accessToken
    } else {
      throw Exception('Failed to refresh token');
    }
  }
}
