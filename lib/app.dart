import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/constants.dart';
import 'core/theme.dart';
import 'screens/splash_screen.dart';
import 'state/app_state.dart';

class MasarApp extends StatelessWidget {
  const MasarApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      // يعيد بناء التطبيق عند تغيير الوضع الليلي.
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) => MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: buildTheme(),
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: state.darkMode ? Brightness.light : Brightness.dark,
            ),
            child: child!,
          ),
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
