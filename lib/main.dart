import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(title: 'Login dan Daftar dengan Firebase'),
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController email_controller = TextEditingController();
  TextEditingController password_controller = TextEditingController();
  final _formKey = new GlobalKey<FormState>();
  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  FacebookLogin facebookLogin = FacebookLogin();
  var profile;
  bool isLoggedIn = false;

  @override
  void initState() {
    print(isLoggedIn);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blueAccent,
        key: scaffoldKey,
        body: Form(
          key: _formKey,
          child: Center(
            child: Container(
              color: Colors.white,
              child: Padding(
                  padding: EdgeInsets.all(36),
                  child: SingleChildScrollView(
                    child: (!isLoggedIn)
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                height: 150,
                                child: Image.asset(
                                  "images/logo.png",
                                  fit: BoxFit.fill,
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Column(
                                children: <Widget>[
                                  SignInButton(
                                    Buttons.GoogleDark,
                                    onPressed: () async {
                                      await _googleSignIn
                                          .signIn()
                                          .then((result) {
                                        //Jika berhasil
                                        setState(() {
                                          isLoggedIn = true;
                                        });
                                      }).catchError((err) {
                                        //Jika terjadi error
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text("Error"),
                                                content: Text(err.message),
                                                actions: [
                                                  FlatButton(
                                                    child: Text("Ok"),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  )
                                                ],
                                              );
                                            });
                                      });
                                    },
                                  ),
                                  SignInButton(
                                    Buttons.Facebook,
                                    onPressed: () async {
                                      final facebookLogin = FacebookLogin();
                                      final result = await facebookLogin
                                          .logIn(['email']).then((result) {
                                        setState(() {
                                          getFacebookUser(result.accessToken.token);
                                          isLoggedIn = true;
                                        });
                                      }).catchError((err) {
                                        //Jika terjadi error
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text("Error"),
                                                content: Text(err.message),
                                                actions: [
                                                  FlatButton(
                                                    child: Text("Ok"),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  )
                                                ],
                                              );
                                            });
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                height: 150,
                                child: Image.network(
                                  (profile == null)
                                      ? _googleSignIn.currentUser.photoUrl
                                      : profile['picture']['data']['url'],
                                  fit: BoxFit.fill,
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text((profile == null)
                                  ? _googleSignIn.currentUser.displayName
                                  : profile['name']),
                              FlatButton(
                                child: Text("Logout"),
                                onPressed: () {
                                  setState(() {
                                    isLoggedIn = false;
                                  });
                                },
                              ),
                            ],
                          ),
                  )),
            ),
          ),
        ),
      ),
    );
  }

  getFacebookUser(token) async {
    final graphResponse = await http.get(
        'https://graph.facebook.com/v2.12/me?fields=picture,name,first_name,last_name,email&access_token=${token}');
    setState(() {
      profile = json.decode(graphResponse.body);
      print(profile['picture']['data']['url']);
    });
  }
}
