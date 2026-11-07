import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'core/api_client.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/resident_provider.dart';
import 'screens/login_screen.dart';
import 'screens/shell_screen.dart';
import 'services/auth_service.dart';
import 'services/resident_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final api = ApiClient();
  final authService = AuthService(api);
  final residentService = ResidentService(api);
  final auth = AuthProvider(authService);
  await auth.bootstrap();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: api),
        Provider.value(value: authService),
        Provider.value(value: residentService),
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider(create: (_) => ResidentProvider(residentService)),
      ],
      child: const AlZahraaApp(),
    ),
  );
}

class AlZahraaApp extends StatelessWidget {
  const AlZahraaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.bootstrapping) {
            return const Scaffold(
              backgroundColor: AppTheme.brand,
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.apartment_rounded, size: 48, color: Colors.white),
                    SizedBox(height: 16),
                    CircularProgressIndicator(color: Colors.white),
                  ],
                ),
              ),
            );
          }
          return auth.isAuthenticated ? const ShellScreen() : const LoginScreen();
        },
      ),
    );
  }
}
