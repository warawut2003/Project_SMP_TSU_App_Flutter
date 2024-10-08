// To parse this JSON data, do
//
//     final projectModel = projectModelFromJson(jsonString);

import 'dart:convert';

ProjectModel projectModelFromJson(String str) =>
    ProjectModel.fromJson(json.decode(str));

String projectModelToJson(ProjectModel data) => json.encode(data.toJson());

class ProjectModel {
  String projectId;
  String projectName;
  String projectFile;
  DateTime projectStartDate;
  DateTime projectExpirationDate;
  String adminIdFk;

  ProjectModel({
    required this.projectId,
    required this.projectName,
    required this.projectFile,
    required this.projectStartDate,
    required this.projectExpirationDate,
    required this.adminIdFk,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
        projectId: json["project_id"],
        projectName: json["project_name"],
        projectFile: json["project_file"],
        projectStartDate: DateTime.parse(json["project_start_date"]),
        projectExpirationDate: DateTime.parse(json["project_expiration_date"]),
        adminIdFk: json["admin_id_FK"],
      );

  Map<String, dynamic> toJson() => {
        "project_id": projectId,
        "project_name": projectName,
        "project_file": projectFile,
        "project_start_date": projectStartDate.toIso8601String(),
        "project_expiration_date": projectExpirationDate.toIso8601String(),
        "admin_id_FK": adminIdFk,
      };
}
