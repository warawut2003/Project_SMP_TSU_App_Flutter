import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:project_smp_tsu_application/controllers/user_controller.dart';
import 'package:project_smp_tsu_application/models/project_model.dart';
import 'package:project_smp_tsu_application/models/user_model.dart';
import 'package:project_smp_tsu_application/pages/AdminView/ProjectDetail.dart';
import 'package:project_smp_tsu_application/pages/AdminView/UserDetail.dart';
import 'package:project_smp_tsu_application/pages/AdminView/AddProject.dart';
import 'package:project_smp_tsu_application/widget/customCliper.dart';

class PartcipantListScreen extends StatefulWidget {
  final ProjectModel project;

  const PartcipantListScreen({super.key, required this.project});

  @override
  _PartcipantListScreenState createState() => _PartcipantListScreenState();
}

class _PartcipantListScreenState extends State<PartcipantListScreen> {
  late Future<List<UserModel>> _participants;
  final userController = UserController();

  @override
  void initState() {
    super.initState();
    _participants =
        UserController().AdminGetUsers(context, widget.project.projectId);
  }

  Future<void> _deleteUser(String userId, String image, String document) async {
    final result = await userController.AdmindeleteUser(context, userId);

    if (result.statusCode == 200) {
      // ลบไฟล์จาก Firebase Storage
      await deleteFileFromFirebase(image); // ลบไฟล์รูปภาพ
      await deleteFileFromFirebase(document); // ลบไฟล์เอกสาร
      setState(() {
        _participants =
            UserController().AdminGetUsers(context, widget.project.projectId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ลบผู้ใช้สำเร็จ!')),
      );
    } else {
      // Handle deletion error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่สามารถลบผู้ใช้ได้.')),
      );
    }
  }

  Future<void> deleteFileFromFirebase(String fileUrl) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(fileUrl);
      await ref.delete();
      debugPrint('File deleted successfully');
    } catch (e) {
      debugPrint('Error deleting file: $e');
      throw Exception('Failed to delete file.');
    }
  }

  // ฟังก์ชันยืนยันการลบ
  void _confirmDeleteUser(String userId, String image, String document) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการลบ'),
          content: const Text('คุณแน่ใจหรือว่าต้องการลบผู้ใช้นี้?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิดกล่องโต้ตอบ
              },
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // ปิดกล่องโต้ตอบ
                await _deleteUser(userId, image, document);
              },
              child: const Text('ยืนยัน'),
            ),
          ],
        );
      },
    );
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
                        text: 'รายการ',
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.w900,
                          color: Color(0xffC7253E),
                        ),
                        children: [
                          TextSpan(
                            text: 'ผู้เข้าร่วมโครงการ',
                            style: TextStyle(
                                color: Color(0xffE85C0D), fontSize: 35),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Back Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProjectDetailsScreen(
                              project: widget.project,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff821131),
                      ),
                      child: const Text(
                        'กลับไปยังรายละเอียดโครงการ',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Participant List Display
                    FutureBuilder<List<UserModel>>(
                      future: _participants,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Text('ไม่พบผู้เข้าร่วม');
                        }

                        List<UserModel> participants = snapshot.data!;

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(
                                  label: Text('รหัสผู้ใช้',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('ชื่อ-นามสกุล',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('เบอร์โทร',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('อีเมล',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: participants.map((user) {
                              return DataRow(cells: [
                                DataCell(Text(user.userId)),
                                DataCell(Text(
                                    '${user.userFname} ${user.userLname}')),
                                DataCell(Text(user.userPhoneNum)),
                                DataCell(Text(user.userEmail)),
                                DataCell(Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                          Icons.content_paste_search_rounded),
                                      color: Colors.green,
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                UserDetailsScreen(
                                              user: user,
                                              project: widget.project,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      color: Colors.red,
                                      onPressed: () {
                                        _confirmDeleteUser(user.userId,
                                            user.userImage, user.userFile);
                                      },
                                    ),
                                  ],
                                )),
                              ]);
                            }).toList(),
                          ),
                        );
                      },
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
