
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo_ui/data/user_directory_helper.dart';
import 'package:flutter_demo_ui/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

import 'views/create_item_view.dart';
import 'views/home_view.dart';
import 'views/import_item_view.dart';
import 'views/main_view.dart';
import 'views/profile_view.dart';
import 'views/shared_items_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  try {
    await UserDirectoryHelper.ensureCurrentUserProfile();
  } catch (_) {}
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const String appTitle = 'DnD Item Maker';
    final providers = [EmailAuthProvider()];

    void onSignedIn(BuildContext context) {
      UserDirectoryHelper.ensureCurrentUserProfile().catchError((_) {});
      Navigator.pushReplacementNamed(context, '/home');
    }

    return MaterialApp(
      title: appTitle,
      initialRoute: FirebaseAuth.instance.currentUser == null
          ? '/sign-in'
          : '/home',
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
          case '/home':
            return MaterialPageRoute(
              builder: (BuildContext context) => const HomeView(),
              settings: settings,
            );
          case '/create_item':
            return MaterialPageRoute(
              builder: (BuildContext context) => const CreateItemView(),
              settings: settings,
            );
          case '/import_item':
            return MaterialPageRoute(
              builder: (BuildContext context) => const ImportItemView(),
              settings: settings,
            );
          case '/shared_items':
            return MaterialPageRoute(
              builder: (BuildContext context) => const SharedItemsView(),
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
              builder: (BuildContext context) => ProfileView(
                providers: providers,
              ),
              settings: settings,
            );
        }
        return null;
      },
    );
  }
}
