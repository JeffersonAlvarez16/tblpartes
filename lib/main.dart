import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:tblpartes/AutenticationWraper.dart';
import 'package:tblpartes/HomePage.dart';
import 'package:tblpartes/screens/autenticate/sign_in.dart';
import 'package:tblpartes/screens/home/clase_semana.dart';
import 'package:tblpartes/screens/home/comandante.dart';
import 'package:tblpartes/screens/home/comandante_compania.dart';
import 'package:tblpartes/screens/home/oficial_semana.dart';
import 'package:tblpartes/screens/home/personal.dart';
import 'package:tblpartes/screens/home/sub_comandante.dart';
import 'package:tblpartes/services/Constantes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tblpartes/services/auntentication.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp();

  try {
// you can also assign this app to a FirebaseApp variable
// for example app = await FirebaseApp.initializeApp...
    FirebaseOptions op = FirebaseOptions(apiKey: 'AIzaSyAb-v9pKqzffOAcqYM6yxWY0Iu_1RqiUd0', messagingSenderId: "887751905461", appId: "1:887751905461:android:9516ab7d26240384482efc", projectId: "tbl-partes");

    await Firebase.initializeApp(name: "SecondaryApp", options: op);
    FirebaseApp secondary = Firebase.app('SecondaryApp');
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
// you can choose not to do anything here or either
// In a case where you are assigning the initializer instance to a FirebaseApp variable, // do something like this:
//
//   app = Firebase.app('SecondaryApp');
//
      FirebaseApp secondary = Firebase.app('SecondaryApp');
    } else {
      throw e;
    }
  } catch (e) {
    rethrow;
  }

  runApp(App());
}

class App extends StatefulWidget {
  App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Autentication>(
          create: (context) => Autentication(FirebaseAuth.instance),
        ),
        StreamProvider(
          create: (context) => context.read<Autentication>().autStateChange,
          initialData: null,
        )
      ],
      child: MaterialApp(
        theme: ThemeData(brightness: Brightness.light, fontFamily: 'Lato'
            /* light theme settings */
            ),
        darkTheme: ThemeData(
          brightness: Brightness.light,
          /* dark theme settings */
        ),
        themeMode: ThemeMode.light,
        routes: {
          '/home': (context) => HomePage(),
          '/personal': (context) => Personal(),
          SwicthA.route: (context) => SwicthA(ModalRoute.of(context)!.settings.arguments),
          ClaseSemana.route: (context) => ClaseSemana(
                arguments: ModalRoute.of(context)!.settings.arguments,
              ),
          ComandanteCompania.route: (context) => ComandanteCompania(
                arguments: ModalRoute.of(context)!.settings.arguments,
              ),
          '/signIn': (context) => SignIn(),
          '/oficial_semana': (context) => OficialSemana(),
          '/comandante': (context) => Comandante(),
          '/sub_comandante': (context) => SubComandante(),
        },
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('es'),
        ],
        debugShowCheckedModeBanner: false,
        home: AuthenticationWrapper(),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();
    if (firebaseUser != null) {
      return HomePage();
    }
    return SignIn();
  }
}
