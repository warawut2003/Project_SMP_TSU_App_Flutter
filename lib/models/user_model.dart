// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  String userId;
  String nationalId;
  String userPrefix;
  String userFname;
  String userLname;
  String userGender;
  DateTime userDateBirth;
  int userAge;
  String userPhoneNum;
  String userEmail;
  String userStatus;
  String userImage;
  String userFile;
  String adminIdFk;
  String projectIdFk;

  UserModel({
    required this.userId,
    required this.nationalId,
    required this.userPrefix,
    required this.userFname,
    required this.userLname,
    required this.userGender,
    required this.userDateBirth,
    required this.userAge,
    required this.userPhoneNum,
    required this.userEmail,
    required this.userStatus,
    required this.userImage,
    required this.userFile,
    required this.adminIdFk,
    required this.projectIdFk,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        userId: json["user_id"],
        nationalId: json["National_ID"],
        userPrefix: json["User_prefix"],
        userFname: json["User_Fname"],
        userLname: json["User_Lname"],
        userGender: json["User_gender"],
        userDateBirth: DateTime.parse(json["User_Date_Birth"]),
        userAge: json["User_age"],
        userPhoneNum: json["User_phone_num"],
        userEmail: json["User_email"],
        userStatus: json["user_status"],
        userImage: json["User_Image"],
        userFile: json["User_file"],
        adminIdFk: json["admin_id_FK"] ?? "",
        projectIdFk: json["project_id_FK"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
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
        "admin_id_FK": adminIdFk,
        "project_id_FK": projectIdFk,
      };
}
