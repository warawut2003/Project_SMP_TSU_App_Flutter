import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project_smp_tsu_application/controllers/auth_controller.dart';
import 'package:project_smp_tsu_application/pages/LoginPage.dart';
import 'package:project_smp_tsu_application/provider/admin_provider.dart';
import 'package:project_smp_tsu_application/provider/user_providers.dart';
import 'package:provider/provider.dart';
import 'package:project_smp_tsu_application/models/user_model.dart'; // Import your User model here
import 'package:project_smp_tsu_application/varibles.dart'; // Define your API URL here

class UserController {
  final _authController = AuthController();
  Future<List<UserModel>> AdminGetUsers(
      BuildContext context, String projectID) async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    var accessToken = adminProvider.accessToken;

    try {
      final response = await http.get(
        Uri.parse('$apiURL/api/admin/get/users/$projectID'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${accessToken}", // ใส่ accessToken ใน header
        },
      );
      print(response.statusCode);
      print(projectID);
      if (response.statusCode == 200) {
        // Decode the response and map it to ProductModel objects
        List<dynamic> jsonResponse = json.decode(response.body);
        print(jsonResponse);
        return jsonResponse.map((user) => UserModel.fromJson(user)).toList();
      } else if (response.statusCode == 401) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );
        throw Exception(
            'Refresh token expired. Please login again.'); // เพิ่ม throw Exception
      } else if (response.statusCode == 403) {
        // Refresh token and retry
        await _authController.refreshToken(context);
        accessToken = adminProvider.accessToken;
        return await AdminGetUsers(context, projectID);
      } else {
        throw Exception(
            'Failed to load products with status code: ${response.statusCode}');
      }
    } catch (err) {
      // If the request failed, throw an error
      print(err);
      throw Exception('Failed to load products');
    }
  }

  Future<http.Response> updateProject(
      BuildContext context, String userId, String status) async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    var accessToken = adminProvider.accessToken;
    var adminId = adminProvider.admin?.adminId;
    print(adminId);

    final Map<String, dynamic> updateData = {
      "user_status": status,
      "admin_id": adminId
    };

    try {
      // Make PUT request to update the product
      final response = await http.put(
        Uri.parse(
            "$apiURL/api/admin/update/user/$userId"), // Replace with the correct API endpoint
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken" // Attach accessToken
        },
        body: jsonEncode(updateData),
      );
      // Handle successful product update
      if (response.statusCode == 200) {
        print("user updated successfully!");
        return response; // ส่งคืน response
      } else if (response.statusCode == 403) {
        // Refresh the accessToken
        await _authController.refreshToken(context);
        accessToken =
            adminProvider.accessToken; // Update the accessToken after refresh

        return await updateProject(context, userId, status);
      } else {
        return response; // ส่งคืน response
      }
    } catch (error) {
      throw Exception('Failed to update user');
    }
  }

  Future<http.Response> AdmindeleteUser(
      BuildContext context, String userId) async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    var accessToken = adminProvider.accessToken;

    try {
      final response = await http.delete(
        Uri.parse("$apiURL/api/admin/delete/user/$userId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken"
        },
      );

      if (response.statusCode == 200) {
        print("User deleted successfully!");
        return response; // ส่งคืน response
      } else if (response.statusCode == 403) {
        // Refresh the accessToken
        await _authController.refreshToken(context);
        accessToken = adminProvider.accessToken;

        return await AdmindeleteUser(context, userId);
      } else {
        return response; // ส่งคืน response
      }
    } catch (error) {
      throw Exception('Failed to delete user due to error: $error');
    }
  }

  Future<http.Response> createUser(
      BuildContext context,
      String nationalId,
      String userPrefix,
      String userFname,
      String userLname,
      String userGender,
      DateTime userDateBirth,
      int userAge,
      String userPhoneNum,
      String userEmail,
      String userStatus,
      String userImage,
      String userFile,
      String? projectId) async {
    final userProviders = Provider.of<UserProviders>(context, listen: false);

    final Map<String, dynamic> userData = {
      "National_ID": nationalId,
      "User_prefix": userPrefix,
      "User_Fname": userFname,
      "User_Lname": userLname,
      "User_gender": userGender,
      "User_Date_Birth": userDateBirth.toIso8601String(),
      "User_age": userAge,
      "User_phone_num": userPhoneNum,
      "User_email": userEmail,
      "user_status": userStatus,
      "User_Image": userImage,
      "User_file": userFile,
      "project_id_FK": projectId
    };

    try {
      print({
        "National_ID": nationalId,
        "User_prefix": userPrefix,
        "User_Fname": userFname,
        "User_Lname": userLname,
        "User_gender": userGender,
        "User_Date_Birth": userDateBirth.toIso8601String(),
        "User_age": userAge,
        "User_phone_num": userPhoneNum,
        "User_email": userEmail,
        "User_status": userStatus,
        "User_Image": userImage,
        "User_file": userFile,
        "project_id_FK": projectId
      });
      final response = await http.post(
        Uri.parse('$apiURL/api/user/create'),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(userData), // ส่งข้อมูลใน request body
      );
      print(response.statusCode);

      if (response.statusCode == 201) {
        // สร้างผู้ใช้ใหม่สำเร็จ
        return response; // แปลง JSON เป็น UserModel
      } else {
        throw Exception(
            'Failed to create user with status code: ${response.statusCode}');
      }
    } catch (err) {
      // หากคำขอล้มเหลว ให้โยนข้อผิดพลาด
      throw Exception('Failed to create user: $err');
    }
  }

  Future<List<UserModel>> updateUser(BuildContext context) async {
    final userProviders = Provider.of<UserProviders>(context, listen: false);
    try {
      final response = await http.put(
        Uri.parse('$apiURL/api/user/update/:id'),
        headers: {
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode == 200) {
        // Decode the response and map it to ProductModel objects
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((project) => UserModel.fromJson(project))
            .toList();
      } else {
        throw Exception(
            'Failed to load products with status code: ${response.statusCode}');
      }
    } catch (err) {
      // If the request failed, throw an error
      throw Exception('Failed to load products');
    }
  }
}
