import 'package:flutter/material.dart';
import 'package:project_smp_tsu_application/pages/LoginPage.dart'; // เพิ่มการนำเข้าไฟล์ใหม่ที่สร้างขึ้น
import 'package:project_smp_tsu_application/pages/User/ListProject.dart'; // นำเข้าหน้า ListProject

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  static final List<Widget> _widgetOptions = <Widget>[
    const Center(child: Text('หน้าหลัก', style: TextStyle(fontSize: 24))),
    const Center(child: Text('ข้อมูลโครงการ', style: TextStyle(fontSize: 24))),
    const ListProject(), // เรียกหน้าที่ใช้แสดงรายการโครงการ (ListProject.dart)
    const Center(child: Text('ข่าวสาร/กิจกรรม', style: TextStyle(fontSize: 24))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('หน้าแรก'),
        backgroundColor: Colors.yellowAccent[100],
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            ),
            child: const Text(
              'สำหรับเจ้าหน้าที่',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'หน้าหลัก', icon: Icon(Icons.home)),
            Tab(text: 'ข้อมูลโครงการ', icon: Icon(Icons.info)),
            Tab(text: 'สมัครเข้าร่วมโครงการ', icon: Icon(Icons.add_box)),
            Tab(text: 'ข่าวสาร/กิจกรรม', icon: Icon(Icons.event)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _widgetOptions,
      ),
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
}
