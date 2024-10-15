import 'package:flutter/material.dart';

import 'package:project_smp_tsu_application/controllers/project_controller.dart';

import 'package:project_smp_tsu_application/models/project_model.dart'; // Import your Project Model

import 'package:project_smp_tsu_application/pages/AdminView/documentView.dart';
import 'package:project_smp_tsu_application/pages/User/registerProject.dart';

class ListProject extends StatefulWidget {
  const ListProject({super.key});

  @override
  _ListProjectState createState() => _ListProjectState();
}

class _ListProjectState extends State<ListProject> {
  List<ProjectModel> projects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProjects(); // Fetch projects when the page loads
  }

  Future<void> fetchProjects() async {
    try {
      // Call the project controller's method to get the latest project
      final project = await ProjectController().getProjectLatest();

      setState(() {
        projects = [project]; // Wrap the single project in a list
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching projects: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('โครงการ วมว. - มอ.ทักษิณ'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Card(
                    child: ExpansionTile(
                      title: Text(
                        'โครงการ วมว ปีการศึกษา ${project.projectName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                      children: <Widget>[
                        ListTile(
                          title: const Text('รายละเอียดโครงการ'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ชื่อโครงการ: ${project.projectName}'),
                              Text(
                                  'วันที่เริ่มต้น: ${project.projectStartDate}'),
                              Text(
                                  'วันที่สิ้นสุด: ${project.projectExpirationDate}'),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      if (project.projectFile != null &&
                                          project.projectFile!.isNotEmpty) {
                                        // Open Document Viewer
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DocumentViewerScreen(
                                                    fileUrl:
                                                        project.projectFile),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content:
                                                    Text('ไม่พบไฟล์เอกสาร')));
                                      }
                                    },
                                    child: const Text('ดูเอกสาร',
                                        style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xffFBA834),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 20),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => RegisterProjectPage(
                                              project:
                                                  project), // Pass project details if needed
                                        ),
                                      );
                                    }, // Call the modified function
                                    child: const Text('สมัครโครงการ',
                                        style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xffFBA834),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
