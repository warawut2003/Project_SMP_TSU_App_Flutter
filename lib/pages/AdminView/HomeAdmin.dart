import 'package:flutter/material.dart';
import 'package:project_smp_tsu_application/controllers/project_controller.dart';
import 'package:project_smp_tsu_application/models/project_model.dart';
import 'package:project_smp_tsu_application/pages/AdminView/AddProject.dart';
import 'package:project_smp_tsu_application/pages/AdminView/ProjectDetail.dart';
import 'package:project_smp_tsu_application/pages/HomePage.dart';

import 'dart:math';
import 'package:project_smp_tsu_application/widget/customCliper.dart';

class HomeAdminScreen extends StatefulWidget {
  const HomeAdminScreen({super.key});

  @override
  _HomeAdminScreenState createState() => _HomeAdminScreenState();
}

class _HomeAdminScreenState extends State<HomeAdminScreen> {
  late Future<List<ProjectModel>> _projects;

  @override
  void initState() {
    super.initState();
    _projects = ProjectController().getProjects(context);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        height: height,
        child: Stack(
          children: [
            // Background Gradient Decoration
            Positioned(
              top: -height * .15,
              right: -width * .4,
              child: Transform.rotate(
                angle: -pi / 3.5,
                child: ClipPath(
                  clipper: ClipPainter(),
                  child: Container(
                    height: height * .5,
                    width: width,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xffE9EFEC), Color(0xffFABC3F)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: height * .1),
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        text: 'จัดการ',
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.w900,
                          color: Color(0xffC7253E),
                        ),
                        children: [
                          TextSpan(
                            text: 'โครงการ',
                            style: TextStyle(
                                color: Color(0xffE85C0D), fontSize: 35),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Project List Display
                    FutureBuilder<List<ProjectModel>>(
                      future: _projects,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Text('ไม่พบโครงการ');
                        }

                        List<ProjectModel> projects = snapshot.data!;

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(
                                  label: Text('รหัสโครงการ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('ชื่อโครงการ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('วันเปิดรับสมัคร',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('วันหมดเขตรับสมัคร',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: projects.map((project) {
                              return DataRow(cells: [
                                DataCell(Text(project.projectId)),
                                DataCell(Text(project.projectName)),
                                DataCell(Text(
                                  project.projectStartDate
                                      .toLocal()
                                      .toString()
                                      .split(' ')[0],
                                  style: const TextStyle(color: Colors.green),
                                )),
                                DataCell(Text(
                                  project.projectExpirationDate
                                      .toLocal()
                                      .toString()
                                      .split(' ')[0],
                                  style: const TextStyle(color: Colors.red),
                                )),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(
                                        Icons.content_paste_search_rounded),
                                    color: Colors.blue,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProjectDetailsScreen(
                                            project: project,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ]);
                            }).toList(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Add Project Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddProjectScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff821131),
                      ),
                      child: const Text(
                        'เพิ่มโครงการใหม่',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Navigate to HomePage Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                HomePage(), // Replace with your actual HomePage widget
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff821131),
                      ),
                      child: const Text(
                        'กลับไปยังหน้าแรก',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
