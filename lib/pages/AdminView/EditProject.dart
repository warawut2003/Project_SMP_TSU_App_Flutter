import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:project_smp_tsu_application/controllers/project_controller.dart';
import 'package:project_smp_tsu_application/models/project_model.dart';
import 'package:project_smp_tsu_application/pages/AdminView/HomeAdmin.dart';
import 'package:project_smp_tsu_application/pages/LoginPage.dart';
import 'package:project_smp_tsu_application/widget/customCliper.dart';

class EditProjectScreen extends StatefulWidget {
  final ProjectModel project;

  const EditProjectScreen({super.key, required this.project});

  @override
  _EditProjectScreenState createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final ProjectController _projectController = ProjectController();

  DateTime? _startDate;
  DateTime? _endDate;
  String? _uploadedFilePath; // To store the URL of the uploaded file

  @override
  void initState() {
    super.initState();
    // Initialize fields with current project data
    _projectNameController.text = widget.project.projectName;
    _startDate = widget.project.projectStartDate.toLocal();
    _endDate = widget.project.projectExpirationDate.toLocal();
    _startDateController.text = formatDate(_startDate);
    _endDateController.text = formatDate(_endDate);
  }

  String formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.toLocal().toString().split(' ')[0]} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      String? filePath = result.files.single.path;
      setState(() {
        _uploadedFilePath = filePath; // Store the file path for later upload
      });
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
      rethrow; // Rethrow for further handling
    }
  }

  Future<void> _selectDate(BuildContext context,
      {bool isStartDate = false}) async {
    DateTime initialDate =
        isStartDate ? _startDate ?? DateTime.now() : _endDate ?? DateTime.now();

    DateTime firstDate =
        isStartDate ? DateTime.now() : (_startDate ?? DateTime.now());
    DateTime lastDate = DateTime(2101); // กำหนดวันสุดท้ายเป็นปี 2101

    // ตรวจสอบว่า initialDate อยู่ระหว่าง firstDate และ lastDate
    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    } else if (initialDate.isAfter(lastDate)) {
      initialDate = lastDate;
    }

    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStartDate
          ? _startDate ?? DateTime.now()
          : _endDate ?? DateTime.now()),
    );

    if (selectedDate != null && selectedTime != null) {
      setState(
        () {
          DateTime combinedDateTime = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );

          if (isStartDate) {
            _startDate = combinedDateTime;
            _startDateController.text = formatDate(_startDate);
          } else {
            if (combinedDateTime.isBefore(_startDate!)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('วันหมดอายุไม่สามารถก่อนวันเปิดรับสมัครได้')),
              );
            } else {
              _endDate = combinedDateTime;
              _endDateController.text = formatDate(_endDate);
            }
          }
        },
      );
    }
    }

  void _editProject() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String oldFileUrl = widget.project.projectFile;

      if (_uploadedFilePath != null) {
        await _deleteOldFile(oldFileUrl);

        // Upload the new file and get the download URL
        String fileDownloadUrl = await _uploadFile(_uploadedFilePath!);

        // Save the updated project data by calling the update function
        final response = await _projectController.updateProject(
          context,
          widget.project.projectId, // Use project ID to update
          _projectNameController.text,
          fileDownloadUrl, // Use the download URL here
          _startDate!,
          _endDate!,
        );

        // Log response
        print('Response status code: ${response.statusCode}');
        print('Response body: ${response.body}');

        // Check if the project was updated successfully
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('แก้ไขโครงการเรียบร้อยแล้ว')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeAdminScreen()),
          );
        } else if (response.statusCode == 401) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Refresh token expired. Please login again.')),
          );
        }
      } else {
        // No new file selected; use the old file URL
        final response = await _projectController.updateProject(
          context,
          widget.project.projectId, // Use project ID to update
          _projectNameController.text,
          oldFileUrl, // Use the old file URL here
          _startDate!,
          _endDate!,
        );
        // Log response
        print('Response status code: ${response.statusCode}');
        print('Response body: ${response.body}');

        // Check if the project was updated successfully
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('แก้ไขโครงการเรียบร้อยแล้ว')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeAdminScreen()),
          );
        } else if (response.statusCode == 401) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Refresh token expired. Please login again.')),
          );
        }
      }
    }
  }

  Future<void> _deleteOldFile(String fileUrl) async {
    try {
      // Create a reference to the old file in Firebase Storage
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.refFromURL(fileUrl);

      // Delete the file
      await ref.delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting old file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SizedBox(
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
                        text: 'แก้ไข',
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
                            onPressed: _selectFile,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xffFBA834)),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.drive_folder_upload_rounded,
                                    color: Colors.white),
                                SizedBox(width: 8),
                                Text('เพิ่มไฟล์',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16)),
                              ],
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
                                  onPressed: _editProject,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xff821131)),
                                  child: const Text('บันทึก',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18)),
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
                                      backgroundColor: Colors.grey),
                                  child: const Text('ยกเลิก',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18)),
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

  TextFormField _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hintText,
  }) {
    return TextFormField(
      controller: controller,
      validator: (value) {
        if (value!.isEmpty) {
          return 'กรุณาใส่ $label';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
    );
  }

  TextFormField _buildDateFormField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
    );
  }
}
