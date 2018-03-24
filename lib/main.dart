import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shifty/app_text_styles.dart';
import 'package:shifty/app_themes.dart';
import 'package:shifty/bottom_navigation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
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
  final _googleSignIn = new GoogleSignIn();
  var _facebookLogin = new FacebookLogin();
  final _auth = FirebaseAuth.instance;
  FirebaseUser _currentUser;

  Animation<double> _logoAnimation;
  AnimationController _logoAnimationController;

  int _screen;
  ScrollPhysics _scrollPhysics;

  Future<FirebaseUser> _ensureLoggedIn() async {
    GoogleSignInAccount user = _googleSignIn.currentUser;
    if (user == null) user = await _googleSignIn.signInSilently();
    if (user == null) {
      await _googleSignIn.signIn();
      //analytics.logLogin();
    }

    if (await _auth.currentUser() == null) {
      GoogleSignInAuthentication credentials =
          await _googleSignIn.currentUser.authentication;
      await _auth.signInWithGoogle(
        idToken: credentials.idToken,
        accessToken: credentials.accessToken,
      );
    }

    return _auth.currentUser();
  }

  @override
  initState() {
    super.initState();

    // Splash Logo Animation
    _logoAnimationController = new AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _logoAnimation =
        new Tween(begin: 0.0, end: 1.0).animate(_logoAnimationController)
          ..addListener(() {
            setState(() {
              // the state that has changed here is the animation object’s value
            });
          });
    _logoAnimationController.forward();

    /*_ensureLoggedIn().then((FirebaseUser user) {
      setState(() {
        _currentUser = user;
      });
    });*/

    _auth.onAuthStateChanged.listen((FirebaseUser user) {
      setState(() {
        _currentUser = user;
      });
      if (_currentUser != null) {
        setState(() {
          _currentUser = user;
        });
      }
    });

    _screen = 0;

    botNavItemTabs[_screen]
        ? _scrollPhysics = const ScrollPhysics()
        : _scrollPhysics = const NeverScrollableScrollPhysics();
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();

    super.dispose();
  }

  Future<Null> _handleEmailSignIn() async {
    try {
      _auth.signInWithEmailAndPassword(
          email: 'argamanza@gmail.com', password: 'melikson24');
    } catch (error) {
      print(error);
    }
  }

  Future<Null> _handleGoogleSignIn() async {
    try {
      await _googleSignIn.signIn();
      GoogleSignInAuthentication credentials =
          await _googleSignIn.currentUser.authentication;
      await _auth.signInWithGoogle(
        idToken: credentials.idToken,
        accessToken: credentials.accessToken,
      );
    } catch (error) {
      print(error);
    }
  }

  Future<Null> _handleFacebookSignIn() async {
    try {
      FacebookLoginResult result =
          await _facebookLogin.logInWithReadPermissions(['email']);

      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          print('Facebook login: ' + result.accessToken.userId);
          await _auth.signInWithFacebook(accessToken: result.accessToken.token);
          print(_currentUser.uid +
              ' | ' +
              _currentUser.displayName +
              ' | ' +
              _currentUser.photoUrl);
          // Logged in UI
          break;
        case FacebookLoginStatus.cancelledByUser:
          print('Facebook login cancelled by user.');
          break;
        case FacebookLoginStatus.error:
          print('Facebook login error: ' + result.errorMessage);
          break;
      }
    } catch (error) {
      print(error);
    }
  }

  Future<Null> _handleSignOut() async {
    await _googleSignIn.disconnect();
    await _auth.signOut();
  }

  Widget _showSplashScreen() {
    return new Container(
      color: Theme.of(context).backgroundColor,
      child: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Container(
                padding: new EdgeInsetsDirectional.only(bottom: 30.0),
                child: new Column(
                  children: <Widget>[
                    new Opacity(
                      opacity: _logoAnimation.value == null
                          ? 0
                          : _logoAnimation.value,
                      child: new Image(
                        //TODO: Wait for image to load, then start animation
                        image: new AssetImage('assets/images/logo.png'),
                        height: 150.0,
                      ),
                    ),
                    new Opacity(
                      opacity: _logoAnimation.value == null
                          ? 0
                          : _logoAnimation.value,
                      child: new Text(
                        'Shifty',
                        style: AppTextStyles.splashLogo,
                      ),
                    ),
                  ],
                )),
            new FlatButton(
                onPressed: () async {
                  setState(() {
                    _handleEmailSignIn();
                  });
                },
                child: new Text('Sign In (Email)')),
            new FlatButton(
                onPressed: () async {
                  setState(() {
                    _handleGoogleSignIn();
                  });
                },
                child: new Text('Sign In (Google)')),
            new FlatButton(
                onPressed: () async {
                  setState(() {
                    _handleFacebookSignIn();
                  });
                },
                child: new Text('Sign In (Facebook)')),
            new FlatButton(
                onPressed: () async {
                  setState(() {
                    _handleSignOut();
                  });
                },
                child: new Text('Sign Out')),
          ],
        ),
      ),
    );
  }

  Widget _showMainScreen() {
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
                        setState(() {
                          _handleSignOut();
                        });
                      },
                      child: new Text('Sign Out')),
                  new Text(_currentUser != null
                      ? _currentUser.uid +
                          ', Provider: ' +
                          _currentUser.providerId
                      : 'No user'),
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
  }

  Widget _buildBody() {
    Widget screen;

    _currentUser != null
        ? screen = _showMainScreen()
        : screen = _showSplashScreen();

    return screen;
  }

  Widget _buildBottomNavigation() {
    Widget botNav;

    _currentUser != null
        ? botNav = new Column(
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
                        : _scrollPhysics = const NeverScrollableScrollPhysics();
                  });
                },
                items: botNavItems,
              ),
            ],
          )
        : botNav = null;
    return botNav;
  }

  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
      length: tabNames.length,
      child: new Scaffold(
          body: _buildBody(), bottomNavigationBar: _buildBottomNavigation()),
    );
  }
}
