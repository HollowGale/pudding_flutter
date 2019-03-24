import 'package:flutter/material.dart';
import 'package:pudding_flutter/calendar_carousel.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart';
import 'package:pudding_flutter/social.dart';
import 'package:pudding_flutter/auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


void main() {
  runApp(checkIfSignedIn() ? MyApp() : SignInRoute()); //checks if signed in.
}

final ThemeData _themeData = ThemeData(
  primarySwatch: Colors.brown,
  canvasColor: Colors.yellow[100],
);

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pudding',
      theme: _themeData,
      home: MyHomePage(),
      routes: <String, WidgetBuilder> {
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key})
      : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int _selectedIndex = 0;

  final _widgetOptions = [
    Text('Index 0: Dashboard'),
    Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Index 1: Timetable'),
          Calendar(),
        ],
      ),
    ),
    Text('Index 3: Goals'),
    Social(),
  ];



  @override
  Widget build(BuildContext context) {

    final _appBarOptions = [
      AppBar(title: Text("Dashboard"),),
      AppBar(title: Text("Timetable"),),
      AppBar(title: Text("Goals"),),
      socialAppBar(context),
    ];

    return Scaffold(
      appBar: _appBarOptions.elementAt(_selectedIndex),
      floatingActionButton: (_selectedIndex != 0)
        ? _changingFAB.elementAt(_selectedIndex - 1) // -1 because at _selectedIndex = 1 (timetable), FAB is index 0.
        : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home, color: Colors.brown[600],), title: Text("Dashboard", style: TextStyle(color: Colors.brown[600]),)),
          BottomNavigationBarItem(icon: Icon(Icons.table_chart, color: Colors.brown[600],), title: Text("Timetable", style: TextStyle(color: Colors.brown[600]),)),
          BottomNavigationBarItem(icon: Icon(Icons.flag, color: Colors.brown[600],), title: Text("Goals", style: TextStyle(color: Colors.brown[600]),)),
          BottomNavigationBarItem(icon: Icon(Icons.people, color: Colors.brown[600],), title: Text("Social", style: TextStyle(color: Colors.brown[600]),)),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),

      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
    );
  }

  final _changingFAB = <FloatingActionButton>[
    FloatingActionButton(
      child: Icon(Icons.add_comment),
      elevation: 2.0,
      onPressed: () {
        print("Timetable Action Button pressed!");
      },
    ),
    FloatingActionButton(
      child: Icon(Icons.library_add),
      elevation: 2.0,
      onPressed: () {
        print("Goals Action Button pressed!");
      },
    ),
    FloatingActionButton(
      child: Icon(Icons.person_add),
      elevation: 2.0,
      onPressed: () {
        print("Social Action Button pressed!");
      },
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}


class SignInRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Sign In",
      theme: _themeData,
      routes: <String, WidgetBuilder> {
        '/home': (context) => MyApp(),
      },
      home: new SignInScreen(),
    );
  }
}

class SignInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Container(
        color: Colors.yellow[100],
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Shimmer.fromColors(
                  period: Duration(milliseconds: 3000),
                  baseColor: Colors.brown[600],
                  highlightColor: Colors.brown[200],
                  child: Text(
                    "Welcome to Pudding",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GoogleSignInButton(
                  onPressed: () {
                    handleSignIn()
                      .then((FirebaseUser user) {
                        Firestore.instance.collection('users').document(user.uid).setData({ //this adds/updates the user to the database.
                          'nickname': user.displayName,
                          'displayname': user.displayName,
                          'email': user.email,
                          'photoUrl': user.photoUrl});
                        Navigator.of(context).pushReplacementNamed('/home');
                        /** TODO: cannot call scaffold from this context. Need to somehow call the scaffold we create from above navigator function
                        Scaffold.of(context).showSnackBar(
                          new SnackBar(
                              content: new Text("Successfully logged in!")
                          ),
                        );*/
                      })
                      .catchError((e) => print(e));
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
