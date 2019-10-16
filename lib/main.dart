import 'package:flutter/material.dart';
import 'package:flutter_maps_course/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'map.dart';

void main() async{
  Widget homePage = HomePage();
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String uid = sharedPreferences.getString('uid');
  if( uid != null ){
    homePage = MapScreen();
  }
  runApp(MyApp( homePage ));
}

class MyApp extends StatelessWidget {

  final Widget homePage;

  MyApp(this.homePage);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: homePage,
    );
  }

}


class HomePage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to Flutter Maps'),
      ),
      body: Center(
          child: Column(
            children: <Widget>[
              RaisedButton(
                child: Text('REGISTER NEW ACCOUNT'),
                onPressed: (){
                    Navigator.push(context, MaterialPageRoute(
                      builder: ( context ){ return RegisterScreen(); }
                    ));
                },
              ),
              RaisedButton(
                child: Text('LOGIN TO MY ACCOUNT'),
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(
                      builder: ( context ){ return LoginScreen(); }
                  ));
                },
              ),
            ],
          ),
        ),
    );
  }

}




