import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shifty/app_text_styles.dart';
import 'package:shifty/app_themes.dart';
import 'package:shifty/bottom_navigation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Shifty',
      theme: AppThemes.light,
      home: new ShiftyHome(),
    );
  }
}

class ShiftyHome extends StatefulWidget {
  @override
  _ShiftyHomeState createState() => new _ShiftyHomeState();
}

const List<String> tabNames = const <String>[
  'foo',
  'bar',
  'baz',
  'שלום',
  'quuz',
  'רכבת צפון',
  'grault',
  'garply',
  'waldo',
];

class _ShiftyHomeState extends State<ShiftyHome> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = new GoogleSignIn();
  FirebaseUser _user;
  int _screen;
  ScrollPhysics _scrollPhysics;

  Future<FirebaseUser> _handleGoogleSignIn() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    _user = await _auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return _user;
  }

  @override
  initState() {
    super.initState();

    _auth.onAuthStateChanged.listen((FirebaseUser user) {
      setState(() {
        _user = user;
      });
    });

    _auth.currentUser().then((FirebaseUser user) {
      _user = user;
    });

    _googleSignIn.signInSilently().then((GoogleSignInAccount googleAccount) {
      googleAccount.authentication
          .then((GoogleSignInAuthentication googleAuth) {
        _auth
            .signInWithGoogle(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        )
            .then((FirebaseUser user) {
          _user = user;
        });
      });
    });

    _screen = 0;

    botNavItemTabs[_screen]
        ? _scrollPhysics = const ScrollPhysics()
        : _scrollPhysics = const NeverScrollableScrollPhysics();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildBody() {
    if (_user != null) {
      print(_auth.toString());
      return new TabBarView(
        physics: _scrollPhysics,
        children: new List<Widget>.generate(tabNames.length, (int index) {
          switch (_screen) {
            case 0:
              return new Center(
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    new FlatButton(
                        onPressed: () async {
                          await _auth.signOut();
                          await _googleSignIn.disconnect();
                          setState(() {
                            //_handleSignOut();
                          });
                        },
                        child: new Text('Sign out')),
                    new Text(_user.displayName),
                  ],
                ),
              );
            case 1:
              return new Center(
                child: new Text('Second screen, ${tabNames[index]}'),
              );
            case 2:
              return new Center(
                child: new Text('Third screen'),
              );
            case 3:
              return new Center(
                child: new Text('Settings Screen'),
              );
          }
        }),
      );
    } else {
      return new Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const Text("You are not currently signed in."),
          new RaisedButton(
            child: const Text('SIGN IN'),
            onPressed: () {
              setState(() {
                _handleGoogleSignIn()
                    .then((FirebaseUser user) => print(user))
                    .catchError((e) => print(e));
              });
            },
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
      length: tabNames.length,
      child: new Scaffold(
        body: _buildBody(),
        bottomNavigationBar: _auth != null
            ? new Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  new AnimatedCrossFade(
                    firstChild: new Material(
                      color: Theme.of(context).primaryColor,
                      child: new TabBar(
                        isScrollable: true,
                        labelStyle: AppTextStyles.tabBarLabel,
                        tabs: new List.generate(tabNames.length, (index) {
                          return new Tab(text: tabNames[index].toUpperCase());
                        }),
                      ),
                    ),
                    secondChild: new Container(),
                    crossFadeState: botNavItemTabs[_screen]
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 300),
                  ),
                  new BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    currentIndex: _screen,
                    onTap: (int index) {
                      setState(() {
                        _screen = index;
                        botNavItemTabs[_screen]
                            ? _scrollPhysics = const ScrollPhysics()
                            : _scrollPhysics =
                                const NeverScrollableScrollPhysics();
                      });
                    },
                    items: botNavItems,
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
