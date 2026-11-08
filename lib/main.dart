import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'core/api_client.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/resident_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/login_screen.dart';
import 'screens/shell_screen.dart';
import 'services/auth_service.dart';
import 'services/complex_ad_service.dart';
import 'services/resident_service.dart';
import 'services/service_bill_service.dart';
import 'services/vehicle_service.dart';
import 'services/visitor_service.dart';
import 'widgets/brand_logo.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final api = ApiClient();
  final authService = AuthService(api);
  final residentService = ResidentService(api);
  final visitorService = VisitorService(api);
  final complexAdService = ComplexAdService(api);
  final serviceBillService = ServiceBillService(api);
  final vehicleService = VehicleService(api);
  final auth = AuthProvider(authService);
  final settings = SettingsProvider();
  await Future.wait([auth.bootstrap(), settings.load()]);

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: api),
        Provider.value(value: authService),
        Provider.value(value: residentService),
        Provider.value(value: visitorService),
        Provider.value(value: complexAdService),
        Provider.value(value: serviceBillService),
        Provider.value(value: vehicleService),
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider.value(value: settings),
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
    final settings = context.watch<SettingsProvider>();

    return MaterialApp(
      title: AppConfig.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      locale: settings.materialLocale,
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supported) {
        if (locale == null) return const Locale('ar');
        if (locale.languageCode == 'en') return const Locale('en');
        // ku / ckb / ar وغيرها → ar (مدعوم من Material + RTL)
        return const Locale('ar');
      },
      builder: (context, child) {
        return Directionality(
          textDirection: settings.textDirection,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.bootstrapping || !settings.ready) {
            return const Scaffold(
              backgroundColor: AppTheme.bg,
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BrandLogo(
                      size: 108,
                      padding: 14,
                      borderRadius: 30,
                      backgroundColor: Colors.white,
                      showBorder: true,
                    ),
                    SizedBox(height: 20),
                    CircularProgressIndicator(color: AppTheme.brandMid),
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
