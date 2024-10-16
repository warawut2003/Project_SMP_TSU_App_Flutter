import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:project_smp_tsu_application/controllers/user_controller.dart';
import 'package:project_smp_tsu_application/models/project_model.dart';
import 'package:project_smp_tsu_application/pages/HomePage.dart';

class RegisterProjectPage extends StatefulWidget {
  final ProjectModel project;

  const RegisterProjectPage({super.key, required this.project});
  @override
  _RegisterProjectPageState createState() => _RegisterProjectPageState();
}

class _RegisterProjectPageState extends State<RegisterProjectPage> {
  final _formKey = GlobalKey<FormState>(); // ใส่ _formKey ที่นี่
  UserController userController = UserController();

  // ตัวแปรสำหรับฟิลด์ข้อมูล
  String nationalId = '';
  String userPrefix = '';
  String userFname = '';
  String userLname = '';
  String userGender = 'ชาย'; // ค่าเริ่มต้น
  DateTime userDateBirth = DateTime.now();
  int userAge = 0;
  String userPhoneNum = '';
  String userEmail = '';
  String userStatus = 'รอการตรวจสอบ'; // ตั้งค่าเริ่มต้นที่นี่
  String userImage = ''; // ตัวแปรสำหรับ URL ของภาพ
  String userFile = ''; // ตัวแปรสำหรับ URL ของเอกสาร

  String? _uploadedImagePath;
  String? _uploadedDocumentPath;

  void _CreateNewUser() async {
    // เพิ่ม async ที่นี่
    print(widget.project.projectId);
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      try {
        // ตรวจสอบว่ามีการเลือกไฟล์ทั้งสองก่อนดำเนินการ
        if (_uploadedImagePath == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('กรุณาเลือกไฟล์ภาพ')),
          );
          return; // ออกจากฟังก์ชันหากไม่เลือกไฟล์ภาพ
        }
        if (_uploadedDocumentPath == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('กรุณาเลือกเอกสาร')),
          );
          return; // ออกจากฟังก์ชันหากไม่เลือกเอกสาร
        }

        // เตรียมเส้นทางสำหรับการอัปโหลด
        String imagePath =
            'assets/users/image/$userFname $userLname/${DateTime.now().millisecondsSinceEpoch}';
        String documentPath =
            'assets/users/document/$userFname $userLname/${DateTime.now().millisecondsSinceEpoch}';

        // ดำเนินการอัปโหลดภาพ
        userImage = await _uploadFile(_uploadedImagePath!, imagePath);

        // ดำเนินการอัปโหลดเอกสาร
        userFile = await _uploadFile(_uploadedDocumentPath!, documentPath);

        // ดำเนินการสร้างผู้ใช้
        final response = await userController.createUser(
          context,
          nationalId,
          userPrefix,
          userFname,
          userLname,
          userGender,
          userDateBirth,
          userAge,
          userPhoneNum,
          userEmail,
          userStatus,
          userImage,
          userFile,
          widget.project.projectId,
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('สมัครเข้าร่วมโครงการสำเร็จ')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        } else if (response.statusCode == 401) {
          print('Error: Unauthorized');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    }
  }

  Future<String> _uploadFile(String filePath, String destination) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage
          .ref()
          .child('$destination${DateTime.now().millisecondsSinceEpoch}');
      await ref.putFile(File(filePath));
      return await ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _selectFile({required bool isImage}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: isImage ? FileType.image : FileType.custom,
        allowedExtensions: isImage ? null : ['pdf', 'doc', 'docx']);
    if (result != null) {
      String? filePath = result.files.single.path;
      setState(() {
        if (isImage) {
          _uploadedImagePath = filePath;
        } else {
          _uploadedDocumentPath = filePath;
        }
      });
        }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สมัครเข้าร่วมโครงการ'),
        backgroundColor: Color.fromARGB(255, 236, 162, 33),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            // ใช้ Form widget รอบฟอร์มของคุณ
            key: _formKey, // ใส่ _formKey ที่นี่
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'สมัครเข้าร่วมโครงการ',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // รหัสประชาชน
                TextFormField(
                  decoration: const InputDecoration(labelText: 'รหัสประชาชน'),
                  onChanged: (value) {
                    nationalId = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกรหัสประชาชน';
                    }
                    return null;
                  },
                ),
                // คำนำหน้าชื่อ
                DropdownButtonFormField<String>(
                  value: userPrefix.isEmpty ? null : userPrefix,
                  decoration: const InputDecoration(labelText: 'คำนำหน้าชื่อ'),
                  items: <String>['นาย', 'นาง', 'นางสาว'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      userPrefix = value ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณาเลือกคำนำหน้าชื่อ';
                    }
                    return null;
                  },
                ),
                // ชื่อ
                TextFormField(
                  decoration: const InputDecoration(labelText: 'ชื่อ'),
                  onChanged: (value) {
                    userFname = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกชื่อ';
                    }
                    return null;
                  },
                ),
                // นามสกุล
                TextFormField(
                  decoration: const InputDecoration(labelText: 'นามสกุล'),
                  onChanged: (value) {
                    userLname = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'กรุณากรอกนามสกุล';
                    }
                    return null;
                  },
                ),
                // เพศ
                DropdownButtonFormField<String>(
                  value: userGender,
                  decoration: const InputDecoration(labelText: 'เพศ'),
                  items: <String>['ชาย', 'หญิง'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      userGender = value ?? 'ชาย';
                    });
                  },
                ),
                // วันเดือนปีเกิด
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'วันเดือนปีเกิด'),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: userDateBirth,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null && picked != userDateBirth) {
                      setState(() {
                        userDateBirth = picked;
                      });
                    }
                  },
                  controller: TextEditingController(
                      text: userDateBirth.toLocal().toString().split(' ')[0]),
                  readOnly: true,
                ),
                // อายุ
                TextFormField(
                  decoration: const InputDecoration(labelText: 'อายุ'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    userAge = int.tryParse(value) ?? 0;
                  },
                ),
                // เบอร์โทรศัพท์
                TextFormField(
                  decoration: const InputDecoration(labelText: 'เบอร์โทรศัพท์'),
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    userPhoneNum = value;
                  },
                ),
                // อีเมล
                TextFormField(
                  decoration: const InputDecoration(labelText: 'อีเมล'),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    userEmail = value;
                  },
                ),

                const SizedBox(height: 20),

                // Image upload
                ElevatedButton(
                  onPressed: () => _selectFile(isImage: true),
                  child: const Text('อัปโหลดรูปภาพ'),
                ),
                _uploadedImagePath != null
                    ? Text('Selected Image: $_uploadedImagePath')
                    : Container(),

                const SizedBox(height: 10),

                // Document upload
                ElevatedButton(
                  onPressed: () => _selectFile(isImage: false),
                  child: const Text('อัปโหลดเอกสาร'),
                ),
                _uploadedDocumentPath != null
                    ? Text('Selected Document: $_uploadedDocumentPath')
                    : Container(),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _CreateNewUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 236, 147, 38),
                  ),
                  child: const Text('สมัครเข้าร่วมโครงการ'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
