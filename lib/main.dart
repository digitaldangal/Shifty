import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shifty/app_text_styles.dart';
import 'package:shifty/app_themes.dart';
import 'package:shifty/bottom_navigation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shifty/font_awesome_icon_data.dart';

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
    var _loginEmailController = new TextEditingController();
    var _loginPasswordController = new TextEditingController();

    return new Container(
      decoration: new BoxDecoration(
          color: Colors.red,
          image: new DecorationImage(
              fit: BoxFit.fill,
              image: new AssetImage(
                  'assets/images/splash_screen/background.png'))),
      child: new Center(
        child: new Flex(
          direction: Axis.vertical,
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
                        image: new AssetImage(
                            'assets/images/splash_screen/logo.png'),
                        height: 100.0,
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
            new Container(
              child: new Column(
                children: <Widget>[
                  new Container(
                    width: 250.0,
                    padding: new EdgeInsets.only(bottom: 10.0),
                    child: new TextField(
                      controller: _loginEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: new InputDecoration(
                        border: new UnderlineInputBorder(
                            borderSide: new BorderSide(color: Colors.red)),
                        filled: false,
                        fillColor: Colors.black26,
                        contentPadding:
                            new EdgeInsets.fromLTRB(7.0, 7.0, 7.0, 7.0),
                        prefixIcon: new Container(
                          child: new Icon(
                            FontAwesomeIcons.envelope,
                            size: 17.0,
                          ),
                          padding: new EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                        ),
                        hintText: 'Email Address',
                        hintStyle: AppTextStyles.loginTextFieldHint,
                      ),
                      style: AppTextStyles.loginTextField,
                    ),
                  ),
                  new Container(
                    width: 250.0,
                    child: new TextField(
                      controller: _loginPasswordController,
                      decoration: new InputDecoration(
                        border: new UnderlineInputBorder(),
                        filled: false,
                        fillColor: Colors.black26,
                        contentPadding:
                            new EdgeInsets.fromLTRB(7.0, 7.0, 7.0, 7.0),
                        prefixIcon: new Container(
                          child: new Icon(
                            FontAwesomeIcons.key,
                            size: 17.0,
                          ),
                          padding: new EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                        ),
                        hintText: 'Password',
                        hintStyle: AppTextStyles.loginTextFieldHint,
                      ),
                      obscureText: true,
                      style: AppTextStyles.loginTextField,
                    ),
                  ),
                  new Container(
                    padding: new EdgeInsets.only(top: 30.0, bottom: 30.0),
                    child: new RaisedButton(
                        color: Colors.blue[600],
                        shape: new StadiumBorder(),
                        child: new Text(
                          'Sign In',
                          style: AppTextStyles.loginButton,
                        ),
                        onPressed: () {
                          print('Email: ' +
                              _loginEmailController.text +
                              ' Pass: ' +
                              _loginPasswordController.text);
                        }),
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Container(
                        width: 70.0,
                        padding: new EdgeInsets.only(right: 10.0),
                        child: new Divider(
                          color: Colors.white,
                        ),
                      ),
                      new Text(
                        'OR',
                        style: new TextStyle(
                            color: Colors.white, fontFamily: 'Assistant'),
                      ),
                      new Container(
                        width: 70.0,
                        padding: new EdgeInsets.only(left: 10.0),
                        child: new Divider(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  new Container(
                    padding: new EdgeInsets.only(top: 20.0),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Container(
                          height: 55.0,
                          width: 155.0,
                          margin: new EdgeInsets.only(right: 20.0),
                          child: new RaisedButton(
                            elevation: 5.0,
                            highlightElevation: 0.0,
                            padding: new EdgeInsets.all(0.0),
                            color: new Color.fromARGB(255, 221, 75, 57),
                            child: new Icon(
                              FontAwesomeIcons.google,
                              size: 25.0,
                              color: Colors.white,
                            ),
                            onPressed: () {},
                          ),
                        ),
                        new Container(
                          height: 55.0,
                          width: 155.0,
                          child: new RaisedButton(
                            elevation: 5.0,
                            highlightElevation: 0.0,
                            padding: new EdgeInsets.all(0.0),
                            color: new Color.fromARGB(255, 59, 89, 152),
                            child: new Icon(
                              FontAwesomeIcons.facebook_f,
                              size: 25.0,
                              color: Colors.white,
                            ),
                            onPressed: () {},
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            /*new FlatButton(
                onPressed: () async {
                  setState(() {
                    _handleEmailSignIn();
                  });
                },
                child: new Text('Sign In (Email)')),
            new RaisedButton(
              onPressed: () async {
                setState(() {
                  _handleGoogleSignIn();
                });
              },
              child: new Container(
                height: 40.0,
                width: 195.0,
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Image(
                      image: new AssetImage(
                          'assets/images/splash_screen/google_button.png'),
                      height: 22.0,
                    ),
                    new Container(
                      height: 30.0,
                      width: 1.0,
                      color: Colors.red[900],
                    ),
                    new Text(
                      'Sign in with Google',
                      style: AppTextStyles.splashButtonGoogle,
                    )
                  ],
                ),
              ),
              color: Colors.white,
            ),
            new RaisedButton(
              onPressed: () async {
                setState(() {
                  _handleGoogleSignIn();
                });
              },
              child: new Container(
                height: 40.0,
                width: 217.5,
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Image(
                      image: new AssetImage(
                          'assets/images/splash_screen/facebook_button.png'),
                      height: 22.0,
                    ),
                    new Container(
                      height: 30.0,
                      width: 1.0,
                      color: Colors.white,
                    ),
                    new Text(
                      'Sign in with Facebook',
                      style: AppTextStyles.splashButtonFacebook,
                    )
                  ],
                ),
              ),
              color: new Color.fromARGB(255, 59, 89, 152),
            ),
            new FlatButton(
                onPressed: () async {
                  setState(() {
                    _handleSignOut();
                  });
                },
                child: new Text('Sign Out')),*/
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
