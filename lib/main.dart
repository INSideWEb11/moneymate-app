// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'app.dart';
import 'core/constants/app_constants.dart';
import 'data/local/database_helper.dart';
import 'data/repositories/budget_repository.dart';
import 'data/repositories/commitment_repository.dart';
import 'data/repositories/goal_repository.dart';
import 'data/repositories/transaction_repository.dart';
import 'presentation/providers/budget_provider.dart';
import 'presentation/providers/commitment_provider.dart';
import 'presentation/providers/goal_provider.dart';
import 'presentation/providers/transaction_provider.dart';
import 'presentation/providers/user_profile_provider.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Initialize local notifications
  await _initNotifications();

  // Check first launch
  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool(AppConstants.prefIsFirstLaunch) ?? true;
  final onboardingComplete =
      prefs.getBool(AppConstants.prefOnboardingComplete) ?? false;

  // Initialize database (warm up connection)
  await DatabaseHelper().database;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => CommitmentProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider()),
      ],
      child: MoneyMateApp(
        isFirstLaunch: isFirstLaunch && !onboardingComplete,
      ),
    ),
  );
}

Future<void> _initNotifications() async {
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (details) {
      // Handle notification tap
    },
  );

  // Create notification channel for Android
  const channel = AndroidNotificationChannel(
    AppConstants.notifChannelId,
    AppConstants.notifChannelName,
    description: AppConstants.notifChannelDesc,
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

/// Schedule a bill reminder notification
Future<void> scheduleBillReminder({
  required int id,
  required String title,
  required String body,
  required DateTime scheduledDate,
}) async {
  // Simplified: show immediate notification for demo
  const androidDetails = AndroidNotificationDetails(
    AppConstants.notifChannelId,
    AppConstants.notifChannelName,
    channelDescription: AppConstants.notifChannelDesc,
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  await flutterLocalNotificationsPlugin.show(
    id,
    title,
    body,
    const NotificationDetails(android: androidDetails),
  );
}
