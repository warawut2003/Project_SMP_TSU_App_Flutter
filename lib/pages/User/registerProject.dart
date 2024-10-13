import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:project_smp_tsu_application/controllers/project_controller.dart';
import 'package:project_smp_tsu_application/controllers/user_controller.dart';
import 'package:project_smp_tsu_application/models/project_model.dart';
import 'package:project_smp_tsu_application/pages/HomePage.dart';
import 'package:http/http.dart' as http;
import 'package:project_smp_tsu_application/provider/project_provider.dart';
import 'package:provider/provider.dart';

class RegisterProjectPage extends StatefulWidget {
  final ProjectModel project;

  const RegisterProjectPage({Key? key, required this.project}) : super(key: key);
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
  String userImage = 'here'; // ตัวแปรสำหรับ URL ของภาพ
  String userFile = 'are you here'; // ตัวแปรสำหรับ URL ของเอกสาร

  void _CreateNewUser() async {
    
    print(widget.project.projectId);
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {

      _formKey.currentState!.save();
      print("Preparing to create a new user...");
      // บันทึกข้อมูลโครงการใหม่โดยเรียกใช้ฟังก์ชัน InsertProject
      userController
          .createUser(
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
              widget.project.projectId,)
          .then((response) {
        print("Response received: ${response.statusCode}");

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เพิ่มโครงการเรียบร้อยแล้ว')),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        } else if (response.statusCode == 401) {
          print('Error: Unauthorized');
        }
      }).catchError((error) {
        print("Error occurred: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $error')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สมัครเข้าร่วมโครงการ'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form( // ใช้ Form widget รอบฟอร์มของคุณ
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
                  decoration: const InputDecoration(labelText: 'วันเดือนปีเกิด'),
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

                // ปุ่มสมัคร
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _CreateNewUser,
                  child: const Text('สมัครเข้าร่วมโครงการ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
