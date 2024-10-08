// To parse this JSON data, do
//
//     final adminModel = adminModelFromJson(jsonString);

import 'dart:convert';

AdminModel adminModelFromJson(String str) =>
    AdminModel.fromJson(json.decode(str));

String adminModelToJson(AdminModel data) => json.encode(data.toJson());

class AdminModel {
  Admin admin;
  String accessToken;
  String refreshToken;

  AdminModel({
    required this.admin,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) => AdminModel(
        admin: Admin.fromJson(json["admin"]),
        accessToken: json["accessToken"],
        refreshToken: json["refreshToken"],
      );

  Map<String, dynamic> toJson() => {
        "admin": admin.toJson(),
        "accessToken": accessToken,
        "refreshToken": refreshToken,
      };
}

class Admin {
  String adminId;
  String adminUsername;
  String adminFname;
  String adminLname;
  String adminTel;
  String adminEmail;

  Admin({
    required this.adminId,
    required this.adminUsername,
    required this.adminFname,
    required this.adminLname,
    required this.adminTel,
    required this.adminEmail,
  });

  factory Admin.fromJson(Map<String, dynamic> json) => Admin(
        adminId: json["admin_id"],
        adminUsername: json["admin_username"],
        adminFname: json["admin_Fname"],
        adminLname: json["admin_Lname"],
        adminTel: json["admin_tel"],
        adminEmail: json["admin_email"],
      );

  Map<String, dynamic> toJson() => {
        "admin_id": adminId,
        "admin_username": adminUsername,
        "admin_Fname": adminFname,
        "admin_Lname": adminLname,
        "admin_tel": adminTel,
        "admin_email": adminEmail,
      };
}
