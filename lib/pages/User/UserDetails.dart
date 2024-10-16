import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage
import 'package:project_smp_tsu_application/models/user_model.dart'; // Import UserModel

class UserDetailsPage extends StatefulWidget {
  final UserModel user;

  const UserDetailsPage({super.key, required this.user});

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  String? _uploadedFilePath; // Path of uploaded file

  // Function to select file
  Future<void> _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      String? filePath = result.files.single.path;
      setState(() {
        _uploadedFilePath = filePath; // Save the path of the selected file
      });
    }
  }

  // Function to delete old file from Firebase Storage
  Future<void> _deleteOldFile(String fileUrl) async {
    try {
      if (fileUrl.isNotEmpty) {
        FirebaseStorage storage = FirebaseStorage.instance;
        Reference ref = storage.refFromURL(fileUrl); // Create reference from URL
        await ref.delete(); // Delete the file
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ลบไฟล์เก่าสำเร็จ')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error deleting file: $e')));
    }
  }

  // Function to upload new file to Firebase Storage
  Future<String> _uploadFile(String filePath) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child(
          'assets/documents/${widget.user.nationalId}/${DateTime.now().millisecondsSinceEpoch}');
      await ref.putFile(File(filePath)); // Upload the file
      String downloadURL = await ref.getDownloadURL(); // Get the download URL
      return downloadURL;
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error uploading file: $e')));
      rethrow;
    }
  }

  // Function to manage file upload
  Future<void> _handleUpload() async {
    if (_uploadedFilePath != null) {
      // If there is an old file, delete it first
      if (widget.user.userFile.isNotEmpty) {
        await _deleteOldFile(widget.user.userFile);
      }

      // Upload new file
      String newFileUrl = await _uploadFile(_uploadedFilePath!);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('อัปโหลดไฟล์สำเร็จ')),
      );

      // Update user info with the new file URL (send to backend if needed)
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกไฟล์ก่อนอัปโหลด')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดผู้สมัคร'),
        backgroundColor: const Color.fromARGB(255, 246, 185, 64),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('รหัสผู้สมัคร', 'A001'),
            const SizedBox(height: 10),
            _buildInfoRow('ชื่อ', '${widget.user.userFname} ${widget.user.userLname}', 'เพศ', widget.user.userGender),
            const SizedBox(height: 10),
            _buildInfoRow('วันเดือนปีเกิด', '25 ต.ค. 2546', 'อายุ', widget.user.userAge.toString()),
            const SizedBox(height: 10),
            _buildInfoRow('เบอร์โทรศัพท์', '097-553-6855', 'อีเมล', widget.user.userEmail),
            const SizedBox(height: 20),
            _buildStatusSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label1, String value1, [String? label2, String? value2]) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: '$label1: ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                  children: [
                    TextSpan(
                      text: value1,
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (label2 != null && value2 != null)
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: '$label2: ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                    children: [
                      TextSpan(
                        text: value2,
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'สถานะการส่งเอกสาร',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'รอตรวจสอบ',
                  style: TextStyle(color: Colors.orange),
                ),
                Text(
                  '• สำเนาบัตรประชาชน',
                  style: TextStyle(color: Colors.orange),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _selectFile, // Function to select file
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
              child: const Text(
                'Add File',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
