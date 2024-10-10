import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:project_smp_tsu_application/controllers/project_controller.dart';
import 'package:project_smp_tsu_application/pages/AdminView/HomeAdmin.dart';
import 'package:project_smp_tsu_application/pages/LoginPage.dart';

import 'dart:math';
import 'package:project_smp_tsu_application/widget/customCliper.dart';

class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key});

  @override
  _AddProjectScreenState createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final ProjectController _projectController = ProjectController();

  DateTime? _startDate;
  DateTime? _endDate;
  String? _uploadedFilePath; // To store the URL of the uploaded file

  // แยกฟังก์ชันสำหรับเพิ่มสินค้า
  void _addNewProject() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_uploadedFilePath != null) {
        // Upload the file and get the download URL
        String fileDownloadUrl = await _uploadFile(_uploadedFilePath!);

        // Save the new project data by calling the InsertProject function
        _projectController.InsertProject(
          context,
          _projectNameController.text,
          fileDownloadUrl, // Use the download URL here
          _startDate!,
          _endDate!,
        ).then((response) {
          // Check if the project was added successfully
          if (response.statusCode == 201) {
            // Success action here (e.g., navigate back or show success message)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('เพิ่มโครงการเรียบร้อยแล้ว')),
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomeAdminScreen(),
              ),
            );
          } else if (response.statusCode == 401) {
            // Show a message when there's an error adding the project
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoginScreen(),
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Refresh token expired. Please login again.')),
            );
          }
        }).catchError((error) {
          // Show a message when there's an error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เกิดข้อผิดพลาด: $error')),
          );
        });
      } else {
        // Show a message if no file was uploaded
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('กรุณาเลือกไฟล์ก่อนบันทึก')),
        );
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
                        text: 'เพิ่ม',
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

                    // Form Section
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _buildTextFormField(
                            controller: _projectNameController,
                            label: 'ชื่อโครงการ',
                            hintText: 'กรุณาใส่ชื่อโครงการ',
                          ),
                          const SizedBox(height: 15),
                          _buildDateFormField(
                            controller: _startDateController,
                            label: 'วันเปิดรับสมัคร',
                            hintText: 'กรุณาเลือกวันเปิดรับสมัคร',
                            onTap: () =>
                                _selectDate(context, isStartDate: true),
                          ),
                          const SizedBox(height: 15),
                          _buildDateFormField(
                            controller: _endDateController,
                            label: 'วันปิดรับสมัคร',
                            hintText: 'กรุณาเลือกวันปิดรับสมัคร',
                            onTap: () => _selectDate(context),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () async {
                              await _selectFile();
                            },
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.drive_folder_upload_rounded,
                                    color: Colors.white,
                                  ), // ไอคอนเพิ่มไฟล์
                                  SizedBox(
                                      width:
                                          8), // เพิ่มระยะห่างระหว่างไอคอนกับข้อความ
                                  Text(
                                    'เพิ่มไฟล์',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ]),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xffFBA834),
                            ),
                          ),
                          if (_uploadedFilePath != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text('Selected File: $_uploadedFilePath'),
                            ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 150,
                                child: ElevatedButton(
                                  onPressed: _addNewProject,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff821131),
                                  ),
                                  child: const Text(
                                    'บันทึก',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 150,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(
                                        context); // ย้อนกลับไปหน้าก่อนหน้า
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                  ),
                                  child: const Text(
                                    'ยกเลิก',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
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
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      String? filePath = result.files.single.path;
      if (filePath != null) {
        setState(() {
          _uploadedFilePath = filePath; // Store the file path for later upload
        });
      }
    }
  }

  Future<String> _uploadFile(String filePath) async {
    try {
      // Create a reference to the Firebase Storage
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child(
          'assets/documents/${_projectNameController.text}/${DateTime.now().millisecondsSinceEpoch}');
      // Upload the file
      await ref.putFile(File(filePath));
      // Get the download URL
      String downloadURL = await ref.getDownloadURL();
      return downloadURL; // Return the download URL
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error uploading file: $e')));
      throw e;
    }
  }

  Future<void> _selectDate(BuildContext context,
      {bool isStartDate = false}) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? DateTime.now() : _startDate ?? DateTime.now(),
      firstDate: isStartDate ? DateTime.now() : _startDate ?? DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          DateTime fullDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          if (isStartDate) {
            _startDate = fullDate;
            _startDateController.text =
                fullDate.toLocal().toString().split('.')[0];
          } else {
            _endDate = fullDate;
            _endDateController.text =
                fullDate.toLocal().toString().split('.')[0];
          }
        });
      }
    }
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hintText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'กรุณาใส่$label';
        }
        return null;
      },
    );
  }

  Widget _buildDateFormField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required Function() onTap,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      readOnly: true,
      onTap: onTap,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'กรุณาเลือก$label';
        }
        return null;
      },
    );
  }
}
