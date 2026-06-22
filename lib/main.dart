import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/transaction_model.dart';
import 'providers/transaction_provider.dart';
import 'screens/home_screen.dart';
import 'services/hive_service.dart';

// main() is the first function Flutter runs when the app starts.
Future<void> main() async {
  // This makes sure Flutter is fully ready before we initialize Hive.
  WidgetsFlutterBinding.ensureInitialized();

  // This initializes Hive for Flutter and prepares local storage on the device.
  await Hive.initFlutter();

  // This registers the generated adapter for TransactionModel.
  // It lets Hive understand how to save and read TransactionModel objects.
  Hive.registerAdapter(TransactionModelAdapter());

  // This registers the generated adapter for TransactionType.
  // It lets Hive understand the income/expense enum.
  Hive.registerAdapter(TransactionTypeAdapter());

  // This creates the Hive service object.
  final hiveService = HiveService();

  // This opens the transactions box before the app UI starts.
  await hiveService.openTransactionBox();

  // This starts the Flutter app.
  runApp(
    // ChangeNotifierProvider makes TransactionProvider available to the widget tree.
    ChangeNotifierProvider(
      // This creates TransactionProvider and gives it the HiveService.
      create: (context) => TransactionProvider(hiveService: hiveService)
        // This loads saved transactions from Hive immediately after provider creation.
        ..loadTransactions(),

      // MyApp is the root widget of the app.
      child: const MyApp(),
    ),
  );
}

// MyApp is StatelessWidget because app setup does not change inside this widget.
class MyApp extends StatelessWidget {
  // super.key helps Flutter identify this widget efficiently.
  const MyApp({super.key});

  // build() returns the UI for this widget.
  @override
  Widget build(BuildContext context) {
    // MaterialApp sets up Material Design, navigation, theme, and routes.
    return MaterialApp(
      // This removes the debug banner from the top-right corner.
      debugShowCheckedModeBanner: false,

      // This is the app name used internally by Flutter.
      title: 'Money Buddy',

      // This controls the app's colors and visual style.
      theme: ThemeData(
        // This creates a color scheme using green as the seed color.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),

        // This enables newer Material 3 styling.
        useMaterial3: true,
      ),

      // initialRoute tells Flutter which screen to open first.
      initialRoute: '/',

      // routes maps route names to screen widgets.
      routes: {
        // '/' is the first route and opens HomeScreen.
        '/': (context) => const HomeScreen(),
      },
    );
  }
}