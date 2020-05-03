import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tutorialfirebase/DaftarPage.dart';
import 'package:tutorialfirebase/Dashboard.dart';
import 'package:tutorialfirebase/ForgotPasswordPage.dart';

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
  bool _autoValidate = false;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController email_controller = TextEditingController();
  TextEditingController password_controller = TextEditingController();
  final _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blueAccent,
        key: scaffoldKey,
        body:Form(
          key: _formKey,
          child:  Center(
            child: Container(
              color: Colors.white,
              child: Padding(
                  padding: EdgeInsets.all(36),
                  child: SingleChildScrollView(
                    child: Column(
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
                        TextFormField(
                          validator: validateEmail,
                          controller: email_controller,
                          style: TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                              contentPadding:
                              EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                              hintText: "Email",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(32.0))),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          validator: validatePassword,
                          controller: password_controller,
                          obscureText: true,
                          style: TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                              contentPadding:
                              EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                              hintText: "Password",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(32.0))),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        FlatButton(
                          color: Colors.blueAccent,
                          child: Text(
                            "Login",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            _validateInputs();
                          },
                        ),
                        SizedBox(
                          height: 100,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            FlatButton(
                              child: Text("Daftar"),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DaftarPage()),
                                );
                              },
                            ),
                            FlatButton(
                              child: Text("Lupa Password"),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ForgotPasswordPage()),
                                );
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  )),
            ),
          ),
        ),
      ),
    );
  }
  String validateEmail(String value) {
    if (value.length < 1) {
      return 'Please type your email address';
    } else {
      Pattern pattern =
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regex = new RegExp(pattern);
      if (!regex.hasMatch(value))
        return 'Wrong email format';
      else
        return null;
    }
  }
  String validatePassword(String value) {
    if (value.length < 8)
      return 'Minimum 8 character';
    else
      return null;
  }
  void _validateInputs() {
    if (_formKey.currentState.validate()) {
      setState(() {
        prosesLogin();
        _formKey.currentState.save();
      });
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
  }

  prosesLogin(){
    //Instance firebase
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    //Login Firebase
    firebaseAuth
        .signInWithEmailAndPassword(email: email_controller.text, password: password_controller.text)
        .then((result) {
      print(result);
      //Hasilnya jika proses berhasil
      email_controller.text    = "";
      password_controller.text = "";
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Dashboard()),
      );
    }).catchError((err) {
      print(err.toString());
      //Jika ada error, pesan akan muncul dengan dialog
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
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    });
  }
}
