import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_demo_ui/data/db_helper.dart';
import 'package:flutter_demo_ui/data/todo_list_manager.dart';
import 'package:flutter_demo_ui/firebase_options.dart';
import 'package:flutter_demo_ui/views/input_view.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'views/main_view.dart';
import 'views/todo_list_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await DatabaseHelper.instance.init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ChangeNotifierProvider(
      create: (context) {
        var model = TodoListManager();
        model.init();
        return model;
      },
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const String appTitle = 'Flutter Layout Demo';
    final providers = [EmailAuthProvider()];

    void onSignedIn(BuildContext context) {
      Navigator.pushReplacementNamed(context, '/todo_list');
    }

    return MaterialApp(
      title: appTitle,
      initialRoute: FirebaseAuth.instance.currentUser == null
          ? '/sign-in'
          : '/todo_list',
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/info':
            return PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 2000),
              reverseTransitionDuration: const Duration(milliseconds: 2000),
              pageBuilder: (context, animation, secondaryanimation) =>
                  MainView(),
              transitionsBuilder:
                  (context, animation, secondaryanimation, child) {
                    const begin = Offset(-1.0, 1.0);
                    const end = Offset.zero;
                    const curve = Curves.easeIn;

                    var tween = Tween(
                      begin: begin,
                      end: end,
                    ).chain(CurveTween(curve: curve));
                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
            );

          case '/todo_list':
            return MaterialPageRoute(
              builder: (BuildContext context) => TodoListView(),
              settings: settings,
            );
          case '/input':
            return MaterialPageRoute(
              builder: (BuildContext context) => InputView(),
              settings: settings,
            );
          case '/sign-in':
            return MaterialPageRoute(
              builder: (BuildContext context) => SignInScreen(
                providers: providers,
                actions: [
                  AuthStateChangeAction<UserCreated>((context, state) {
                    // Put any new user logic here
                    onSignedIn(context);
                  }),
                  AuthStateChangeAction<SignedIn>((context, state) {
                    onSignedIn(context);
                  }),
                ],
              ),
              settings: settings,
            );

          case '/profile':
            return MaterialPageRoute(
              builder: (BuildContext context) => ProfileScreen(
                providers: providers,
                actions: [
                  SignedOutAction((context) {
                    Navigator.pushReplacementNamed(context, '/sign-in');
                  }),
                ],
              ),
              settings: settings,
            );
        }
        return null;
      },
    );
  }
}
