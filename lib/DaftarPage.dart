import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DaftarPage extends StatefulWidget {
  DaftarPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _DaftarPageState createState() => _DaftarPageState();
}

class _DaftarPageState extends State<DaftarPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController email_controller = TextEditingController();
  TextEditingController password_controller = TextEditingController();
  final _formKey = new GlobalKey<FormState>();
  bool _autoValidate = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        body: Form(
          autovalidate: _autoValidate,
          key: _formKey,
          child: Center(
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
                        keyboardType: TextInputType.emailAddress,
                        controller: email_controller,
                        style: TextStyle(fontSize: 20),
                        validator: validateEmail,
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
                        controller: password_controller,
                        obscureText: true,
                        style: TextStyle(fontSize: 20),
                        validator: validatePassword,
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
                          "Daftar",
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          FlatButton(
                            child: Text("Kembali"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
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
        prosesDaftar();
        _formKey.currentState.save();
      });
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
  }

  prosesDaftar(){
    //Instance firebase
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    //Daftar Firebase
    firebaseAuth
        .createUserWithEmailAndPassword(email: email_controller.text, password: password_controller.text)
        .then((result) {
         print(result);
          //Hasilnya jika proses berhasil
         email_controller.text    = "";
         password_controller.text = "";
         showDialog(
             context: context,
             builder: (BuildContext context) {
               return AlertDialog(
                 title: Text("Sukses"),
                 content: Text("Proses daftar sukses, silahkan kembali ke form login"),
                 actions: [
                   FlatButton(
                     child: Text("Ok"),
                     onPressed: () {
                       Navigator.of(context).pop();
                       FocusScope.of(context).requestFocus(FocusNode());
                     },
                   )
                 ],
               );
             });
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
