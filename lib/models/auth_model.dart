// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  User user;
  String accessToken;
  String refreshToken;

  UserModel({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        user: User.fromJson(json["user"]),
        accessToken: json["accessToken"],
        refreshToken: json["refreshToken"],
      );

  Map<String, dynamic> toJson() => {
        "user": user.toJson(),
        "accessToken": accessToken,
        "refreshToken": refreshToken,
      };
}

class User {
  String adminId;
  String adminUsername;
  String adminFname;
  String adminLname;
  String adminTel;
  String adminEmail;

  User({
    required this.adminId,
    required this.adminUsername,
    required this.adminFname,
    required this.adminLname,
    required this.adminTel,
    required this.adminEmail,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
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
