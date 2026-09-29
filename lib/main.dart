import 'package:flutter/material.dart';
import 'state/app_state.dart';
import 'app.dart'; // تأكد أن هذا الملف هو الذي يحتوي على كلاس MasarApp

void main() async {
  // ضمان تهيئة بيئة الفلاتر الأساسية
  WidgetsFlutterBinding.ensureInitialized();

  // تحميل الحالة وقاعدة البيانات المحلية مسبقاً
  final appState = await AppState.load();

  // تشغيل التطبيق وتمرير الحالة مباشرة إلى MasarApp
  runApp(
    MasarApp(state: appState),
  );
}