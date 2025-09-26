import 'package:flutter/material.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232526),
      appBar: AppBar(
        title: const Text('الاشتراك المميز'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'مزايا الاشتراك:',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '• مشاهدة بدون إعلانات',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const Text(
              '• محتوى حصري',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const Text(
              '• دعم فني سريع',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
              ),
              child: const Text('اشترك الآن عبر Paymob!'),
            ),
          ],
        ),
      ),
    );
  }
}
