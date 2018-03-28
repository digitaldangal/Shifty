import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shifty/app_text_styles.dart';
import 'package:shifty/app_themes.dart';
import 'package:shifty/bottom_navigation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shifty/font_awesome_icon_data.dart';

final analytics = new FirebaseAnalytics();
final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Shifty',
      theme: AppThemes.loginScreen,
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
      analytics.logLogin();
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

  Future<Null> _handleEmailSignIn(String _email, String _password) async {
    if (_email.isEmpty || _password.isEmpty) {
      _scaffoldKey.currentState.removeCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(new SnackBar(
        backgroundColor: Colors.blue[700],
        duration: new Duration(seconds: 10),
        content: new Container(
          margin: new EdgeInsets.all(0.0),
          padding: new EdgeInsets.all(0.0),
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text(
                'Please enter a valid Email address and Password.',
                style: AppTextStyles.snackbarText,
              )
            ],
          ),
        ),
        action: new SnackBarAction(
            label: 'DISMISS',
            onPressed: () {
              _scaffoldKey.currentState.hideCurrentSnackBar();
            }),
      ));
    } else {
      try {
        _auth.signInWithEmailAndPassword(email: _email, password: _password);
      } catch (error) {
        print(error);
      }

      analytics.logLogin();
      analytics.logEvent(name: 'email_login');
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

      analytics.logLogin();
      analytics.logEvent(name: 'google_login');
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

          analytics.logLogin();
          analytics.logEvent(name: 'facebook_login');
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
      _scaffoldKey.currentState.showSnackBar(new SnackBar(
          duration: new Duration(seconds: 10),
          action: new SnackBarAction(
              label: 'Dismiss'.toUpperCase(), onPressed: () {}),
          content: new Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text('No Shifty account associated'),
              new Text('with your Facebook account.')
            ],
          )));
    }
  }

  Future<Null> _handleSignOut() async {
    await _googleSignIn.disconnect();
    await _auth.signOut();
  }

  Widget _showLoginScreen() {
    var _loginEmailController = new TextEditingController();
    var _loginPasswordController = new TextEditingController();

    return new Container(
      decoration: new BoxDecoration(
          color: Colors.red,
          image: new DecorationImage(
              fit: BoxFit.cover,
              image: new AssetImage(
                  'assets/images/splash_screen/background.png'))),
      child: new Center(
        child: new ListView(
          //TODO: CHECK OVERSCROLL (ACCENT) COLOR IN THEME MAKE SURE IT'S BLUE NOT IN SPLASH
          physics: new PageScrollPhysics(),
          children: <Widget>[
            new Container(
              height: 30.0,
            ),
            new Flex(
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
                            style: AppTextStyles.loginLogo,
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
                          autocorrect: false,
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
                              padding:
                                  new EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
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
                              padding:
                                  new EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                            ),
                            hintText: 'Password',
                            hintStyle: AppTextStyles.loginTextFieldHint,
                          ),
                          obscureText: true,
                          style: AppTextStyles.loginTextField,
                        ),
                      ),
                      new Container(
                        width: 260.0,
                        margin: new EdgeInsets.only(top: 5.0),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            new FlatButton(
                                padding: new EdgeInsets.only(
                                    left: 10.0, right: 10.0),
                                onPressed: () {},
                                child: new Text(
                                  'Forgot Password?',
                                  style: AppTextStyles.loginTextOpaque
                                      .copyWith(fontSize: 14.0),
                                ))
                          ],
                        ),
                      ),
                      new Container(
                        padding: new EdgeInsets.only(top: 10.0, bottom: 30.0),
                        child: new RaisedButton(
                            color: Colors.white,
//                            highlightColor: Colors.red[200],
                            shape: new StadiumBorder(),
                            child: new Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                new Container(
                                  padding: new EdgeInsets.only(right: 10.0),
                                  child: new Icon(
                                    FontAwesomeIcons.sign_in,
                                    size: 20.0,
                                    color: Colors.red[700],
                                  ),
                                ),
                                new Text(
                                  'Login'.toUpperCase(),
                                  style: AppTextStyles.loginButton,
                                )
                              ],
                            ),
                            elevation: 5.0,
                            highlightElevation: 0.0,
                            onPressed: () async {
                              setState(() {
                                _handleEmailSignIn(_loginEmailController.text,
                                    _loginPasswordController.text);
                              });
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
                                highlightColor:
                                    new Color.fromARGB(255, 206, 72, 55),
                                child: new Icon(
                                  FontAwesomeIcons.google,
                                  size: 25.0,
                                  color: Colors.white,
                                ),
                                onPressed: () async {
                                  setState(() {
                                    _handleGoogleSignIn();
                                  });
                                },
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
                                highlightColor:
                                    new Color.fromARGB(255, 47, 71, 122),
                                child: new Icon(
                                  FontAwesomeIcons.facebook_f,
                                  size: 25.0,
                                  color: Colors.white,
                                ),
                                onPressed: () async {
                                  setState(() {
                                    _handleFacebookSignIn();
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                      new Container(
                        margin: new EdgeInsets.only(top: 50.0),
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Container(
                              padding: new EdgeInsets.only(right: 2.5),
                              child: new Text(
                                'New to Shifty?',
                                style: AppTextStyles.loginTextTransparent,
                              ),
                            ),
                            new Container(
                                padding: new EdgeInsets.only(left: 0.0),
                                child: new FlatButton(
                                  padding: new EdgeInsets.only(
                                      left: 2.5, right: 2.5),
                                  onPressed: () {},
                                  child: new Text('Sign Up!',
                                      style: AppTextStyles.loginTextOpaque),
                                ))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
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
        : screen = _showLoginScreen();

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
          key: _scaffoldKey,
          body: _buildBody(),
          bottomNavigationBar: _buildBottomNavigation()),
    );
  }
}
