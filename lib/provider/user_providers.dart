import 'package:flutter/material.dart';
import 'package:project_smp_tsu_application/models/user_model.dart';
class UserProviders extends ChangeNotifier {

  String? _userId;
  String? _nationalId;
  String? _userPrefix;
  String? _userFname;
  String? _userLname;
  String? _userGender;
  DateTime? _userDateBirth;
  int? _userAge;
  String? _userPhoneNum;
  String? _userEmail;
  String? _userStatus;
  String? _userImage;
  String? _userFile;
  String? _adminIdFk;
  String? _projectIdFk;


  String? get userId =>_userId;
  String? get nationalId =>_nationalId;
  String? get userPrefix =>_userPrefix;
  String? get userFname=>_userFname;
  String? get userLname=>_userLname;
  String? get userGender=>_userGender;
  DateTime? get userDateBirth=>_userDateBirth;
  int? get userAge=>_userAge;
  String? get userPhoneNum=>_userPhoneNum;
  String? get userEmail=>_userEmail;
  String? get userStatus=>_userStatus;
  String? get userImage=>_userImage;
  String? get userFile=>_userFile;
  String? get adminIdFk=>_adminIdFk;
  String? get projectIdFk=>_projectIdFk;

   void getProjects(UserModel userModel){
      _userId = userModel.userId;
      _nationalId = userModel.nationalId;
      _userPrefix = userModel.userPrefix;
      _userFname = userModel.userFname;
      _userLname = userModel.userLname;
      _userGender = userModel.userGender;
      _userDateBirth= userModel.userDateBirth ;
      _userAge= userModel.userAge;
      _userPhoneNum= userModel.userPhoneNum;
      _userEmail= userModel.userEmail;
      _userStatus= userModel.userStatus;
      _userImage= userModel.userImage;
      _userFile= userModel.userFile;
      _adminIdFk= userModel.adminIdFk;
      _projectIdFk= userModel.projectIdFk;


      notifyListeners(); // อัปเดตให้ UI รู้ว่ามีการเปลี่ยนแปลง
    }


}