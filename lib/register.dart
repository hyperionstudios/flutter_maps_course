import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'map.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final _formKey = GlobalKey<FormState>();


  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Regiter New Account'),
      ),
      body: Container(
        padding: EdgeInsets.all( 16 ),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Email'
                ),
                validator: ( value ){
                  if( value.isEmpty ){
                    return 'Email is required';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 24,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: 'Password',
                ),
                validator: ( value ){
                  if( value.isEmpty ){
                    return 'Password is required';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 48,
              ),
              RaisedButton(
                child: Text('REGISTER ACCOUNT'),
                onPressed: () async {
                  if( _formKey.currentState.validate() ){

                    AuthResult results = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);
                    FirebaseUser user = results.user;
                    if(  user != null ){
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) { return MapScreen(); }
                      ));
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
