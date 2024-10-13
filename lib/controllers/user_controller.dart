import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project_smp_tsu_application/provider/user_providers.dart';
import 'package:provider/provider.dart';
import 'package:project_smp_tsu_application/models/user_model.dart'; // Import your User model here
import 'package:project_smp_tsu_application/varibles.dart'; // Define your API URL here

class UserController {
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
    String? projectId
  ) async {
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
      "project_id_FK":projectId
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
    "project_id_FK":projectId
  }); 
      final response = await http.post(
        Uri.parse('$apiURL/api/user/create'),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(userData), // ส่งข้อมูลใน request body
      );
      print(response.statusCode) ;

      if (response.statusCode == 201) {
        // สร้างผู้ใช้ใหม่สำเร็จ
        return response; // แปลง JSON เป็น UserModel
      } else {
        throw Exception('Failed to create user with status code: ${response.statusCode}');
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
      }  else {
        throw Exception(
            'Failed to load products with status code: ${response.statusCode}');
      }
    } catch (err) {
      // If the request failed, throw an error
      throw Exception('Failed to load products');
    }
  }

}


