import 'package:firebase_auth/firebase_auth.dart';
import 'package:qrcode_magario/pages/registration_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:qrcode_magario/utils/colors.dart';
import 'package:line_icons/line_icons.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();
  bool isGoogleSignIn = false;
  String errorMessage = '';
  String successMessage = '';
  final GlobalKey<FormState> _formStateKey = GlobalKey<FormState>();
  String _emailId;
  String _password;
  final _emailIdController = TextEditingController(text: '');
  final _passwordController = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: primaryColor),
    );
    return Scaffold(
        resizeToAvoidBottomPadding: false,

        body: Center(
        child: Container (
          padding: EdgeInsets.only(top: 150.0, left: 30.0, right: 30.0),
          decoration: BoxDecoration(gradient: primaryGradient),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,


        children: [
          Text(
            "Log In.",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,

              fontSize: 45.0,
            ),
          ),
          Text (
          "We missed you!",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
        ),
          Card(
            elevation: 0, //solves the problem of gray background in transparent background
            color: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.all(10),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Form(
                    key: _formStateKey,
                    autovalidate: true,

                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding:
                              EdgeInsets.only(left: 10, right: 10, bottom: 5),
                          child: TextFormField(
                            validator: validateEmail,
                            onSaved: (value) {
                              _emailId = value;
                            },
                            keyboardType: TextInputType.emailAddress,
                            controller: _emailIdController,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              labelStyle: TextStyle(color: Colors.white),
                              prefixIcon: Icon(
                                Icons.email,
                                color: Colors.white,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(left: 10, right: 10, bottom: 5),
                          child: TextFormField(
                            validator: validatePassword,
                            onSaved: (value) {
                              _password = value;
                            },
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(

                              labelText: "Password",
                              labelStyle: TextStyle(color: Colors.white),
                              icon: Icon(
                                Icons.lock,
                                color: Colors.white,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  (errorMessage != ''
                      ? Text(
                          errorMessage,
                          style: TextStyle(color: Colors.red),
                        )
                      : Container()),
                  ButtonTheme.bar(
                    child: ButtonBar(
                      children: <Widget>[
                        FlatButton(
                          child: Text(
                            'LOGIN',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () {
                            if (_formStateKey.currentState.validate()) {
                              _formStateKey.currentState.save();
                              signIn(_emailId, _password).then((user) {
                                if (user != null) {
                                  print('Logged in successfully.');
                                  setState(() {
                                    successMessage =
                                        'Logged in successfully.\nYou can now navigate to Home Page.';
                                  });
                                } else {
                                  print('Error while Login.');
                                }
                              });
                            }
                          },
                        ),
                        FlatButton(
                          child: Text(
                            'Get Register',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              new MaterialPageRoute(
                                builder: (context) => RegistrationPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          (successMessage != ''
              ? Text(
                  successMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.green),
                )
              : Container()),
          (!isGoogleSignIn
              ? RaisedButton(
                  child: Text('Continue with Google'),
                  onPressed: () {
                    googleSignin(context).then((user) {
                      if (user != null) {
                        print('Logged in successfully.');
                        setState(() {
                          isGoogleSignIn = true;
                          successMessage =
                              'Logged in successfully.\nEmail : ${user.email}\nYou can now navigate to Home Page.';
                        });
                      } else {
                        print('Error while Login.');
                      }
                    });
                  },
                )
              : RaisedButton(
                  child: Text('Google Logout'),
                  onPressed: () {
                    googleSignout().then((response) {
                      if (response) {
                        setState(() {
                          isGoogleSignIn = false;
                          successMessage = '';
                        });
                      }
                    });
                  },
                )),
        ],
      )),
      )
    );
  }

  Future<FirebaseUser> signIn(String email, String password) async {
    try {
      FirebaseUser user = (await auth.signInWithEmailAndPassword(
          email: email, password: password)).user;

      assert(user != null);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await auth.currentUser();
      assert(user.uid == currentUser.uid);
      return user;
    } catch (e) {
      handleError(e);
      return null;
    }
  }

  Future<FirebaseUser> googleSignin(BuildContext context) async {
    FirebaseUser currentUser;
    try {
      final GoogleSignInAccount googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final FirebaseUser user = (await auth.signInWithCredential(credential)).user;
      assert(user.email != null);
      assert(user.displayName != null);
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      currentUser = await auth.currentUser();
      assert(user.uid == currentUser.uid);
      print(currentUser);
      print("User Name  : ${currentUser.displayName}");
    } catch (e) {
      handleError(e);
    }
    return currentUser;
  }

  Future<bool> googleSignout() async {
    await auth.signOut();
    await googleSignIn.signOut();
    return true;
  }

  handleError(PlatformException error) {
    print(error);
    switch (error.code) {
      case 'ERROR_USER_NOT_FOUND':
        setState(() {
          errorMessage = 'User Not Found!!!';
        });
        break;
      case 'ERROR_WRONG_PASSWORD':
        setState(() {
          errorMessage = 'Wrong Password!!!';
        });
        break;
    }
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (value.isEmpty || !regex.hasMatch(value))
      return 'Enter Valid Email Id!!!';
    else
      return null;
  }

  String validatePassword(String value) {
    if (value.trim().isEmpty) {
      return 'Password is empty!!!';
    }
    return null;
  }
}
