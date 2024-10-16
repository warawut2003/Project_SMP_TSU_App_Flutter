import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart'; // นำเข้า Firebase Storage
import 'package:project_smp_tsu_application/models/user_model.dart'; // นำเข้า UserModel

class UserDetailsPage extends StatefulWidget {
  final UserModel user;

  const UserDetailsPage({super.key, required this.user});

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  String? _uploadedFilePath; // เก็บ path ของไฟล์ที่อัปโหลด

  // ฟังก์ชันเลือกไฟล์
  Future<void> _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      String? filePath = result.files.single.path;
      setState(() {
        _uploadedFilePath = filePath; // เก็บ path ของไฟล์ที่เลือก
      });
    }
  }

  // ฟังก์ชันลบไฟล์เก่าจาก Firebase Storage
  Future<void> _deleteOldFile(String fileUrl) async {
    try {
      if (fileUrl.isNotEmpty) {
        FirebaseStorage storage = FirebaseStorage.instance;
        Reference ref = storage.refFromURL(fileUrl); // สร้าง reference จาก URL
        await ref.delete(); // ลบไฟล์
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ลบไฟล์เก่าสำเร็จ')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error deleting file: $e')));
    }
  }

  // ฟังก์ชันอัปโหลดไฟล์ใหม่ไปยัง Firebase Storage
  Future<String> _uploadFile(String filePath) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child(
          'assets/documents/${widget.user.nationalId}/${DateTime.now().millisecondsSinceEpoch}');
      await ref.putFile(File(filePath)); // อัปโหลดไฟล์
      String downloadURL = await ref.getDownloadURL(); // รับ URL ของไฟล์ที่อัปโหลด
      return downloadURL;
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error uploading file: $e')));
      rethrow;
    }
  }

  // ฟังก์ชันจัดการการอัปโหลดไฟล์
  Future<void> _handleUpload() async {
    if (_uploadedFilePath != null) {
      // ตรวจสอบว่ามีไฟล์เก่าหรือไม่ ถ้ามี ให้ลบก่อน
      if (widget.user.userFile.isNotEmpty) {
        await _deleteOldFile(widget.user.userFile);
      }

      // อัปโหลดไฟล์ใหม่
      String newFileUrl = await _uploadFile(_uploadedFilePath!);

      // แสดงผลลัพธ์การอัปโหลด
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('อัปโหลดไฟล์สำเร็จ')),
      );

      // อัปเดตข้อมูลผู้ใช้ด้วย URL ของไฟล์ใหม่ (เชื่อมต่อ backend เพื่ออัปเดตในฐานข้อมูลถ้าจำเป็น)
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
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ชื่อ: ${widget.user.userFname} ${widget.user.userLname}', style: const TextStyle(fontSize: 18)),
            Text('เลขบัตรประชาชน: ${widget.user.nationalId}', style: const TextStyle(fontSize: 16)),
            Text('อายุ: ${widget.user.userAge}', style: const TextStyle(fontSize: 16)),
            Text('เพศ: ${widget.user.userGender}', style: const TextStyle(fontSize: 16)),
            Text('อีเมล: ${widget.user.userEmail}', style: const TextStyle(fontSize: 16)),
            Text('สถานะ: ${widget.user.userStatus}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            if (widget.user.userStatus == 'เอกสารไม่ครบถ้วน') ...[
              ElevatedButton(
                onPressed: _selectFile, // เรียกฟังก์ชันเลือกไฟล์
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
                child: const Text(
                  'เลือกไฟล์ใหม่',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _handleUpload, // เรียกฟังก์ชันอัปโหลดไฟล์
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
                child: const Text(
                  'อัปโหลด',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
