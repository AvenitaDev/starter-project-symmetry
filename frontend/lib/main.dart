import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/home/daily_news.dart';
import 'config/theme/app_themes.dart';
import 'features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  // Disable persistence because we want to see the articles that are being saved in real time
  firestore.settings = const Settings(persistenceEnabled: false);

  await _configureFirebaseEmulators(firestore, storage);
  await initializeDependencies();
  await initializeDateFormatting('en', null);

  runApp(const MyApp());
}

Future<void> _configureFirebaseEmulators(FirebaseFirestore firestore, FirebaseStorage storage) async {
  
  const useEmulator = bool.fromEnvironment(
    'USE_FIREBASE_EMULATOR',
    defaultValue: false,
  );

  if (!useEmulator) return;

  //This IP corresponds to host machine in Waydroid
  const host = String.fromEnvironment(
    'FIREBASE_EMULATOR_HOST',
    defaultValue: '192.168.1.95',
    /*  defaultValue: '192.168.240.1', */
  );

  // Firestore emulator (default port 8080)
  firestore.useFirestoreEmulator(
    host,
    8080,
    //Needs to be false because i'm not using Android Emulator
    automaticHostMapping: false,
  );

  // Storage emulator (default port 9199)
  storage.useStorageEmulator(
    host,
    9199,
    //Needs to be false because i'm not using Android Emulator
    automaticHostMapping: false,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RemoteArticlesBloc>(
      create: (context) => sl()..add(const GetArticles()),
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme(),
          onGenerateRoute: AppRoutes.onGenerateRoutes,
          home: const DailyNews()),
    );
  }
}
