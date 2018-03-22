import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shifty/app_text_styles.dart';
import 'package:shifty/app_themes.dart';
import 'package:shifty/bottom_navigation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

final GoogleSignIn _googleSignIn = new GoogleSignIn(
  scopes: [
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
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
  /*Future<String> _message = new Future<String>.value('');

  Future<String> _testSignInAnonymously() async {
    final FirebaseUser user = await _auth.signInAnonymously();
    assert(user != null);
    assert(user.isAnonymous);
    assert(!user.isEmailVerified);
    assert(await user.getIdToken() != null);
    if (Platform.isIOS) {
      // Anonymous auth doesn't show up as a provider on iOS
      assert(user.providerData.isEmpty);
    } else if (Platform.isAndroid) {
      // Anonymous auth does show up as a provider on Android
      assert(user.providerData.length == 1);
      assert(user.providerData[0].providerId == 'firebase');
      assert(user.providerData[0].uid != null);
      assert(user.providerData[0].displayName == null);
      assert(user.providerData[0].photoUrl == null);
      assert(user.providerData[0].email == null);
    }

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    return 'signInAnonymously succeeded: $user';
  }

  Future<String> _testSignInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final FirebaseUser user = await _auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    assert(user.email != null);
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    return 'signInWithGoogle succeeded: $user';
  }*/

  GoogleSignInAccount _currentUser;
  String _contactText;

  int _screen;
  ScrollPhysics _scrollPhysics;

  @override
  initState() {
    super.initState();

    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        _handleGetContact();
      }
    });
    _googleSignIn.signInSilently();

    _screen = 0;

    botNavItemTabs[_screen]
        ? _scrollPhysics = const ScrollPhysics()
        : _scrollPhysics = const NeverScrollableScrollPhysics();
  }

  Future<Null> _handleGetContact() async {
    setState(() {
      _contactText = "Loading contact info...";
    });
    final http.Response response = await http.get(
      'https://people.googleapis.com/v1/people/me/connections'
          '?requestMask.includeField=person.names',
      headers: await _currentUser.authHeaders,
    );
    if (response.statusCode != 200) {
      setState(() {
        _contactText = "People API gave a ${response.statusCode} "
            "response. Check logs for details.";
      });
      print('People API ${response.statusCode} response: ${response.body}');
      return;
    }
    final Map<String, dynamic> data = json.decode(response.body);
    final String namedContact = _pickFirstNamedContact(data);
    setState(() {
      if (namedContact != null) {
        _contactText = "I see you know $namedContact!";
      } else {
        _contactText = "No contacts to display.";
      }
    });
  }

  String _pickFirstNamedContact(Map<String, dynamic> data) {
    final List<Map<String, dynamic>> connections = data['connections'];
    final Map<String, dynamic> contact = connections?.firstWhere(
      (Map<String, dynamic> contact) => contact['names'] != null,
      orElse: () => null,
    );
    if (contact != null) {
      final Map<String, dynamic> name = contact['names'].firstWhere(
        (Map<String, dynamic> name) => name['displayName'] != null,
        orElse: () => null,
      );
      if (name != null) {
        return name['displayName'];
      }
    }
    return null;
  }

  Future<Null> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<Null> _handleSignOut() async {
    _googleSignIn.disconnect();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildBody() {
    if (_currentUser != null) {
      print(_currentUser.toString());
      return new TabBarView(
        physics: _scrollPhysics,
        children: new List<Widget>.generate(tabNames.length, (int index) {
          switch (_screen) {
            case 0:
              return new Center(
                child: new Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    new ListTile(
                      leading: new GoogleUserCircleAvatar(
                        identity: _currentUser,
                      ),
                      title: new Text(_currentUser.displayName),
                      subtitle: new Text(_currentUser.email),
                    ),
                    const Text("Signed in successfully."),
                    new Text(_contactText),
                    new RaisedButton(
                      child: const Text('SIGN OUT'),
                      onPressed: _handleSignOut,
                    ),
                    new RaisedButton(
                      child: const Text('REFRESH'),
                      onPressed: _handleGetContact,
                    ),
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
            onPressed: _handleSignIn,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {/*
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('test'),
      ),
      body: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new MaterialButton(
              child: const Text('Test signInAnonymously'),
              onPressed: () {
                setState(() {
                  _message = _testSignInAnonymously();
                });
              }),
          new MaterialButton(
              child: const Text('Test signInWithGoogle'),
              onPressed: () {
                setState(() {
                  _message = _testSignInWithGoogle();
                });
              }),
          new FutureBuilder<String>(
              future: _message,
              builder: (_, AsyncSnapshot<String> snapshot) {
                return new Text(snapshot.data ?? '',
                    style: const TextStyle(
                        color: const Color.fromARGB(255, 0, 155, 0)));
              }),
        ],
      ),
    );*/
    return new DefaultTabController(
      length: tabNames.length,
      child: new Scaffold(
        body: _buildBody(),
        bottomNavigationBar: _currentUser != null
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
