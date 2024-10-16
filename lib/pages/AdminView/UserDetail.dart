import 'package:flutter/material.dart';
import 'package:project_smp_tsu_application/controllers/user_controller.dart';
import 'package:project_smp_tsu_application/models/project_model.dart';
import 'package:project_smp_tsu_application/models/user_model.dart';
import 'package:project_smp_tsu_application/pages/AdminView/PartcipantList.dart';
import 'package:project_smp_tsu_application/pages/AdminView/documentView.dart';

class UserDetailsScreen extends StatefulWidget {
  final UserModel user;
  final ProjectModel project;

  const UserDetailsScreen(
      {super.key, required this.user, required this.project});

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final List<String> statusOptions = [
    'รอการตรวจสอบ',
    'เอกสารครบถ้วน',
    'เอกสารไม่ครบถ้วน',
  ];
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    selectedStatus =
        widget.user.userStatus; // Set initial status from user model
  }

  final userController = UserController();

  Future<void> _updateStatus() async {
    if (selectedStatus != null) {
      final response = await userController.updateProject(
          context, widget.user.userId, selectedStatus!);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('อัพเดทสถานะผู้ใช้เรียบร้อย')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    // Create a formatter for date of birth
    final String formattedDateOfBirth =
        '${widget.user.userDateBirth.day}/${widget.user.userDateBirth.month}/${widget.user.userDateBirth.year}';

    return Scaffold(
      body: SizedBox(
        height: height,
        width: width,
        child: Stack(
          children: [
            // Background Gradient Decoration
            Positioned(
              top: -height * .15,
              right: -width * .4,
              child: Transform.rotate(
                angle: -3.14 / 3.5,
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
                            text: 'ผู้ใช้',
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
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4), // Shadow position
                            ),
                          ]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User Image Display
                          Center(
                            child: ClipOval(
                              child: widget.user.userImage.isNotEmpty
                                  ? Image.network(
                                      widget.user.userImage,
                                      width: 200,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(
                                      Icons.person,
                                      size: 100,
                                      color: Colors.grey,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'รหัสผู้ใช้',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffC7253E), // Heading color
                            ),
                          ),
                          Text(
                            widget.user.userId,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'หมายเลขประจำตัวประชาชน',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffC7253E), // Heading color
                            ),
                          ),
                          Text(
                            widget.user.nationalId,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'คำนำหน้า',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffC7253E), // Heading color
                            ),
                          ),
                          Text(
                            widget.user.userPrefix,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'ชื่อ-นามสกุล',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffC7253E), // Heading color
                            ),
                          ),
                          Text(
                            '${widget.user.userFname} ${widget.user.userLname}',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'เพศ',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffC7253E), // Heading color
                            ),
                          ),
                          Text(
                            widget.user.userGender,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'วันเกิด',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffC7253E), // Heading color
                            ),
                          ),
                          Text(
                            formattedDateOfBirth,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'อายุ',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffC7253E), // Heading color
                            ),
                          ),
                          Text(
                            '${widget.user.userAge} ปี',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'เบอร์โทร',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffC7253E), // Heading color
                            ),
                          ),
                          Text(
                            widget.user.userPhoneNum,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'อีเมล',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffC7253E), // Heading color
                            ),
                          ),
                          Text(
                            widget.user.userEmail,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'สถานะผู้ใช้',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffC7253E), // Heading color
                            ),
                          ),
                          DropdownButton<String>(
                            value: selectedStatus,
                            items: statusOptions.map((String status) {
                              return DropdownMenuItem<String>(
                                value: status,
                                child: Text(status),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedStatus = newValue;
                              });
                            },
                          ),

                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _updateStatus,
                            child: const Text('อัพเดทสถานะ'),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'ไฟล์เอกสาร',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffC7253E), // Heading color
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DocumentViewerScreen(
                                    fileUrl: widget
                                        .user.userFile, // Pass the file URL
                                  ),
                                ),
                              );
                            },
                            child: const Text('ดูเอกสาร'),
                          ),

                          const SizedBox(height: 20),
                          const Text(
                            'รหัสโครงการที่เกี่ยวข้อง',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffC7253E), // Heading color
                            ),
                          ),
                          Text(
                            widget.user.projectIdFk,
                            style: const TextStyle(fontSize: 18),
                          ),

                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PartcipantListScreen(
                                    project: widget.project,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff006400),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 20),
                            ),
                            child: const Text('กลับ',
                                style: TextStyle(color: Colors.white)),
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
}
