import 'package:flutter/material.dart';
import 'package:project_smp_tsu_application/models/project_model.dart';

class ProjectProvider extends ChangeNotifier {
  String? _projectId;
  String? _projectName;
  String? _projectFile;
  DateTime? _projectStartDate;
  DateTime? _projectExpirationDate;
  String? _adminIdFk;
  



  String? get projectId => _projectId;
  String? get projectName =>_projectName;
  String? get projectFile =>_projectFile;
  DateTime? get projectStartDate =>_projectStartDate;
  DateTime? get projectExpirationDate =>_projectExpirationDate;
    String? get adminIdFk => _adminIdFk;


    void getProjects(ProjectModel projectModel){
      _projectId = projectModel.projectId;
      _projectName = projectModel.projectName;
      _projectFile = projectModel.projectFile;
      _projectStartDate = projectModel.projectStartDate;
      _projectExpirationDate = projectModel.projectExpirationDate;
      notifyListeners(); // อัปเดตให้ UI รู้ว่ามีการเปลี่ยนแปลง
    }

    
}