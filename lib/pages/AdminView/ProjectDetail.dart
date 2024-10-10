import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:project_smp_tsu_application/controllers/project_controller.dart';
import 'package:project_smp_tsu_application/models/project_model.dart';
import 'package:project_smp_tsu_application/pages/AdminView/EditProject.dart';
import 'package:project_smp_tsu_application/pages/AdminView/HomeAdmin.dart';
import 'package:project_smp_tsu_application/pages/LoginPage.dart';
import 'package:project_smp_tsu_application/provider/admin_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'dart:math';
import 'package:project_smp_tsu_application/widget/customCliper.dart';

class ProjectDetailsScreen extends StatelessWidget {
  final ProjectModel project;

  const ProjectDetailsScreen({super.key, required this.project});

  Future<void> deleteFileFromFirebase(String fileUrl) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      debugPrint('Error deleting file: $e');
      throw Exception('Failed to delete file.');
    }
  }

  Future<void> deleteProduct(BuildContext context, ProjectModel project) async {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);

    // แสดงกล่องยืนยันก่อนทำการลบ
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการลบโครงการ'),
          content: const Text('คุณแน่ใจหรือไม่ว่าต้องการลบโครงการนี้?'),
          actions: <Widget>[
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop(false); // ปิดกล่องและส่งค่ากลับ false
              },
            ),
            TextButton(
              child: const Text('ลบ'),
              onPressed: () {
                Navigator.of(context).pop(true); // ปิดกล่องและส่งค่ากลับ true
              },
            ),
          ],
        );
      },
    );

    // ถ้าผู้ใช้ยืนยันการลบ
    if (confirmDelete == true) {
      try {
        // ถ้ามีไฟล์ projectFile ให้ทำการลบไฟล์ออกจาก Firebase Storage
        if (project.projectFile != null && project.projectFile!.isNotEmpty) {
          await deleteFileFromFirebase(project.projectFile!);
        }

        final response =
            await ProjectController().deleteProject(context, project.projectId);

        if (response.statusCode == 200) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeAdminScreen()),
          );

          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('ลบสินค้าสำเร็จ')));
          // เรียกใช้งาน _fetchProducts เพื่อดึงข้อมูลสินค้าใหม่
        } else if (response.statusCode == 401) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Refresh token expired. Please login again.')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting product: $error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        height: height,
        width: width,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: height * .1),
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        text: 'รายละเอียด',
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.w900,
                          color: Color(0xffC7253E),
                        ),
                        children: [
                          TextSpan(
                            text: 'โครงการ',
                            style: TextStyle(
                              color: Color(0xffE85C0D),
                              fontSize: 35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(top: 20, bottom: 20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4), // Shadow position
                            ),
                          ]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditProjectScreen(project: project),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.edit,
                                    color: Colors.blue, size: 30),
                                tooltip: 'Edit Project',
                              ),
                              IconButton(
                                onPressed: () {
                                  deleteProduct(context,
                                      project); // Call delete function directly
                                },
                                icon: const Icon(Icons.delete,
                                    color: Colors.red, size: 30),
                                tooltip: 'ลบโครงการ',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'รหัสโครงการ',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffC7253E), // Heading color
                            ),
                          ),
                          Text(
                            '${project.projectId}',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'ชื่อโครงการ',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffC7253E), // Heading color
                            ),
                          ),
                          Text(
                            '${project.projectName}',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'วันเปิดรับสมัคร',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffC7253E), // Heading color
                            ),
                          ),
                          Text(
                            '${project.projectStartDate.toLocal().toString().split(' ')[0]}',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'วันหมดเขต',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffC7253E), // Heading color
                            ),
                          ),
                          Text(
                            '${project.projectExpirationDate.toLocal().toString().split(' ')[0]}',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () async {
                              if (project.projectFile != null &&
                                  project.projectFile!.isNotEmpty) {
                                // Open Document Viewer
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DocumentViewerScreen(
                                        fileUrl: project.projectFile),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('ไม่พบไฟล์เอกสาร')));
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
                          const SizedBox(height: 20),
                        ],
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

// สร้างหน้าจอสำหรับดูเอกสาร (สมมุติว่าใช้เปิดไฟล์จาก assets หรือ URL)
class DocumentViewerScreen extends StatelessWidget {
  final String fileUrl;

  const DocumentViewerScreen({super.key, required this.fileUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ดูเอกสาร'),
      ),
      body: fileUrl.isNotEmpty
          ? SfPdfViewer.network(fileUrl)
          : Center(child: const Text('ไม่สามารถแสดงเอกสารได้')),
    );
  }
}
