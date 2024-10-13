import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:project_smp_tsu_application/controllers/auth_controller.dart';
import 'package:project_smp_tsu_application/pages/LoginPage.dart';
import 'package:project_smp_tsu_application/provider/admin_provider.dart';
import 'package:project_smp_tsu_application/varibles.dart';
import 'package:project_smp_tsu_application/models/project_model.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ProjectController {
  final _authController = AuthController();

  Future<List<ProjectModel>> getProjects(BuildContext context) async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    var accessToken = adminProvider.accessToken;

    try {
      final response = await http.get(
        Uri.parse('$apiURL/api/admin/projects'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${accessToken}", // ใส่ accessToken ใน header
        },
      );
      if (response.statusCode == 200) {
        // Decode the response and map it to ProductModel objects
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((project) => ProjectModel.fromJson(project))
            .toList();
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
        return await getProjects(context);
      } else {
        throw Exception(
            'Failed to load products with status code: ${response.statusCode}');
      }
    } catch (err) {
      // If the request failed, throw an error
      throw Exception('Failed to load products');
    }
  }

  Future<http.Response> InsertProject(
      BuildContext context,
      String ProjectName,
      String ProjectFile,
      DateTime ProjectStartDate,
      DateTime ProjectExpirationDate) async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    var accessToken = adminProvider.accessToken;
    var adminId = adminProvider.admin?.adminId;

    if (adminId == null) {
      // จัดการกรณีที่ adminId เป็น null
      throw Exception('Admin ID is null. Please check your admin provider.');
    }

    final Map<String, dynamic> InsertData = {
      "project_name": ProjectName,
      "project_file": ProjectFile,
      "project_start_date": ProjectStartDate.toIso8601String(),
      "project_expiration_date": ProjectExpirationDate.toIso8601String(),
      "admin_id_FK": adminId
    };
    try {
      // Make POST request to insert the product
      final response = await http.post(
        Uri.parse(
            "$apiURL/api/admin/create/project"), // Replace with the correct API endpoint
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken" // Attach accessToken
        },
        body: jsonEncode(InsertData),
      );

      // Handle successful product insertion
      if (response.statusCode == 201) {
        print("Product inserted successfully!");
        return response; // ส่งคืน response เมื่อเพิ่มสินค้าสำเร็จ
      } else if (response.statusCode == 403) {
        await _authController.refreshToken(context);
        accessToken = adminProvider.accessToken;

        return await InsertProject(context, ProjectName, ProjectFile,
            ProjectStartDate, ProjectExpirationDate);
      } else {
        return response; // ส่งคืน response
      }
    } catch (error) {
      // Catch and print any errors during the request
      throw Exception('Failed to insert product');
    }
  }

  Future<http.Response> updateProject(
    BuildContext context,
    String projectId,
    String ProjectName,
    String ProjectFile,
    DateTime ProjectStartDate,
    DateTime ProjectExpirationDate,
  ) async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    var accessToken = adminProvider.accessToken;
    var adminId = adminProvider.admin?.adminId;

    final Map<String, dynamic> updateData = {
      "project_name": ProjectName,
      "project_file": ProjectFile,
      "project_start_date": ProjectStartDate.toIso8601String(),
      "project_expiration_date": ProjectExpirationDate.toIso8601String(),
      "admin_id_FK": adminId
    };

    try {
      // Make PUT request to update the product
      final response = await http.put(
        Uri.parse(
            "$apiURL/api/admin/update/project/$projectId"), // Replace with the correct API endpoint
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken" // Attach accessToken
        },
        body: jsonEncode(updateData),
      );
      // Handle successful product update
      if (response.statusCode == 200) {
        print("Product updated successfully!");
        return response; // ส่งคืน response
      } else if (response.statusCode == 403) {
        // Refresh the accessToken
        await _authController.refreshToken(context);
        accessToken =
            adminProvider.accessToken; // Update the accessToken after refresh

        return await updateProject(context, projectId, ProjectName, ProjectFile,
            ProjectStartDate, ProjectExpirationDate);
      } else {
        return response; // ส่งคืน response
      }
    } catch (error) {
      throw Exception('Failed to update product');
    }
  }

  Future<http.Response> deleteProject(
      BuildContext context, String projectId) async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    var accessToken = adminProvider.accessToken;

    try {
      final response = await http.delete(
        Uri.parse("$apiURL/api/admin/delete/project/$projectId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken"
        },
      );

      if (response.statusCode == 200) {
        print("Product deleted successfully!");
        return response; // ส่งคืน response
      } else if (response.statusCode == 403) {
        // Refresh the accessToken
        await _authController.refreshToken(context);
        accessToken = adminProvider.accessToken;

        return await deleteProject(context, projectId);
      } else {
        return response; // ส่งคืน response
      }
    } catch (error) {
      throw Exception('Failed to delete product due to error: $error');
    }
  }

 Future<ProjectModel> getProjectLatest() async {
  try {
    final response = await http.get(
      Uri.parse('$apiURL/api/project/latest'),
      headers: {
        "Content-Type": "application/json",
      },
    );

    print('Status Code: ${response.statusCode}');

    if (response.statusCode == 200) {
      // ตรวจสอบการตอบกลับที่ได้
      final List<dynamic> data = jsonDecode(response.body);
      print('Response data: $data');

      // ตรวจสอบว่ามีข้อมูลในลิสต์
      if (data.isNotEmpty) {
        return ProjectModel.fromJson(data[0]); // แปลงโปรเจกต์ตัวแรกในลิสต์
      } else {
        throw Exception('No project data found');
      }
    } else {
      throw Exception('Failed to load project with status code: ${response.statusCode}');
    }
  } catch (err) {
    print('Error in getProjectLatest: $err');
    throw Exception('Failed to load project: $err');
  }
}
}
