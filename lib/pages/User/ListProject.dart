import 'package:flutter/material.dart';
import 'package:project_smp_tsu_application/controllers/project_controller.dart';
import 'package:project_smp_tsu_application/controllers/user_controller.dart';
import 'package:project_smp_tsu_application/models/project_model.dart';
import 'package:project_smp_tsu_application/pages/AdminView/documentView.dart';
import 'package:project_smp_tsu_application/pages/User/%E0%B9%8AUserDetails.dart';
import 'package:project_smp_tsu_application/pages/User/registerProject.dart';

class ListProject extends StatefulWidget {
  const ListProject({super.key});

  @override
  _ListProjectState createState() => _ListProjectState();
}

class _ListProjectState extends State<ListProject> {
  List<ProjectModel> projects = [];
  bool isLoading = true;
  String userData = ''; // To store the fetched user data

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

  void _showSearchDialog() {
  final TextEditingController idController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('ค้นหาโครงการ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idController,
              decoration: const InputDecoration(
                labelText: 'กรอกเลขบัตรประชาชน',
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                String nationalId = idController.text.trim();
                if (nationalId.isNotEmpty) {
                  if (projects.isNotEmpty) {
                    String projectId = projects[0].projectId; // ดึง projectId จากโครงการล่าสุด
                    try {
                      // ค้นหาข้อมูลผู้ใช้ตามเลขบัตรประชาชนและ projectId
                      final user = await UserController().searchUserByNationalId(context, nationalId, projectId);
                      if (user != null) {
                        Navigator.pop(context); // ปิด dialog
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserDetailsPage(user: user),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ไม่พบข้อมูลผู้ใช้')),
                        );
                      }
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('เกิดข้อผิดพลาดในการค้นหาข้อมูลผู้ใช้')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ไม่มีข้อมูลโครงการ')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('กรุณากรอกเลขบัตรประชาชน')),
                  );
                }
              },
              child: const Text('ค้นหา'),
            ),
          ],
        ),
      );
    },
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('โครงการ วมว. - มอ.ทักษิณ'),
        backgroundColor: Color.fromARGB(255, 252, 162, 53),
        actions: [
          IconButton(
            icon: const Icon(Icons.search), // Add a search icon
            onPressed: _showSearchDialog, // Show search dialog on press
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
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
                                color: Color.fromARGB(255, 62, 63, 64),
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
                                            if (project
                                                .projectFile.isNotEmpty) {
                                              // Open Document Viewer
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      DocumentViewerScreen(
                                                          fileUrl: project
                                                              .projectFile),
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          'ไม่พบไฟล์เอกสาร')));
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xffFBA834),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 20),
                                          ),
                                          child: const Text('ดูเอกสาร',
                                              style: TextStyle(
                                                  color: Color.fromARGB(255, 68, 67, 67))),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    RegisterProjectPage(
                                                        project:
                                                            project), // Pass project details if needed
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xffFBA834),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 20),
                                          ),
                                          child: const Text('สมัครโครงการ',
                                              style: TextStyle(
                                                  color: Color.fromARGB(255, 90, 89, 89))),
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
                ),
                if (userData.isNotEmpty) // Display user data if available
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('ข้อมูลผู้ใช้: $userData'),
                  ),
              ],
            ),
    );
  }
}
