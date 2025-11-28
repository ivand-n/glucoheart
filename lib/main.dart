import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/routes/app_router.dart';
import 'config/themes/app_theme.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id');
  timeago.setLocaleMessages('id', timeago.IdMessages());

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GlucoHeart',
      theme: AppTheme.lightTheme,

      locale: const Locale('id'),
      supportedLocales: const [Locale('id'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

    navigatorKey: AppRouter.navigatorKey,
    initialRoute: AppRouter.splash,
    onGenerateRoute: AppRouter.onGenerateRoute,
    builder: (context, child) => AppRouter.authWrapper(child ?? const SizedBox.shrink()),
      debugShowCheckedModeBanner: false,
    );
  }
}
