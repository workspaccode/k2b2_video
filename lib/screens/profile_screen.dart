import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232526),
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircleAvatar(
              radius: 48,
              backgroundColor: Colors.amber,
              child: Icon(Icons.person, size: 48, color: Colors.white),
            ),
            SizedBox(height: 24),
            Text(
              'اسم المستخدم',
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
            SizedBox(height: 12),
            Text(
              'الحالة: غير مشترك',
              style: TextStyle(color: Colors.redAccent, fontSize: 18),
            ),
            SizedBox(height: 32),
            Text(
              'سجل المشاهدات',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            // يمكن إضافة المزيد لاحقًا
          ],
        ),
      ),
    );
  }
}
