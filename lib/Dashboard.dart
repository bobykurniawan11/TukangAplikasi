import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tutorialfirebase/main.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String userEmail = "";
  bool showChangePasswordForm = false;
  TextEditingController password_controller = TextEditingController();

  @override
  void initState() {
    firebaseAuth.currentUser().then((result){
      setState(() {
        userEmail = result.email;

      });
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child:Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Hallo $userEmail"),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FlatButton(
                      color: Colors.red,
                      onPressed: () async {
                        //Logout
                        await firebaseAuth.signOut();
                        //Alihkan ke halaman login
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: Text("Logout"),
                    ),
                    SizedBox(width: 50,),


                  ],

                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
