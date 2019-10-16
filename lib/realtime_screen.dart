import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RealTimeScreen extends StatefulWidget {
  @override
  _RealTimeScreenState createState() => _RealTimeScreenState();
}

class _RealTimeScreenState extends State<RealTimeScreen> {
//  FirebaseUser user;
//  Geolocator _geolocator;
//  LocationOptions locationOptions;
//  DatabaseReference _myUserLocation;

//  void checkPermission() {
//    _geolocator.checkGeolocationPermissionStatus().then((status) { print('status: $status'); });
//    _geolocator.checkGeolocationPermissionStatus(locationPermission: GeolocationPermission.locationAlways).then((status) { print('always status: $status'); });
//    _geolocator.checkGeolocationPermissionStatus(locationPermission: GeolocationPermission.locationWhenInUse)..then((status) { print('whenInUse status: $status'); });
//  }

//  @override
//  void initState() {
//    _geolocator = Geolocator();
//    locationOptions = LocationOptions(accuracy: LocationAccuracy.best , );
//    SharedPreferences.getInstance().then((sharedPref){
//      String uid = sharedPref.getString('uid');
//      _myUserLocation = FirebaseDatabase.instance.reference().child(uid).child('location');
//    });
//    checkPermission();
//    super.initState();
//  }

  List<Marker> markers = [];
  CameraPosition cameraPosition;
  bool loaded = false;

  List<User> users = [];

  @override
  void initState() {
    super.initState();

    FirebaseDatabase.instance
        .reference()
        .child('users')
        .onValue
        .listen((event) {
      for (var user in event.snapshot.value) {
        if (user != null) {
          users.add(User(user['id']));
          markers.add(Marker(
            markerId: MarkerId(user['id']),
            position: LatLng(
              user['location']['latitude'],
              user['location']['longitude'],
            ),
            infoWindow: InfoWindow(
              title: user['id']
            )
          ));
        }
      }
      cameraPosition = CameraPosition(target: markers[0].position, zoom: 15);
      setState(() {
        loaded = true;
      });
      for (Marker marker in markers) {
        Geolocator()
            .distanceBetween(
                marker.position.latitude,
                marker.position.longitude,
                markers[0].position.latitude,
                markers[0].position.longitude)
            .then((distance) {
          if (distance > 5) {
            _showWarning(marker.infoWindow.title);
          }
        });
      }
    });
  }

//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: Text('Realtime Screen'),
//      ),
//      body: Container(
//        child: FutureBuilder(
//          future: _getCurrentLocation(),
//          builder: ( BuildContext context , AsyncSnapshot<Position> snapshot ){
//            switch(snapshot.connectionState){
//              case ConnectionState.none:
//                return Text('Error');
//                break;
//              case ConnectionState.waiting:
//              case ConnectionState.active:
//                return Text('Loading ......');
//                break;
//              case ConnectionState.done:
//                if( snapshot.hasData ){
//                  CameraPosition cameraPosition = CameraPosition(
//                    target: LatLng( snapshot.data.latitude , snapshot.data.longitude ),
//                    zoom: 15
//                  );
//                  List<Marker> markers = [];
//                  Marker marker = Marker(
//                    markerId: MarkerId('myposition'),
//                    position: LatLng( snapshot.data.latitude , snapshot.data.longitude ),
//                  );
//                  markers.add(marker);
//                  return GoogleMap(
//                    initialCameraPosition: cameraPosition,
//                    markers: markers.toSet(),
//                  );
//                }else{
//                  return Text('No location Found');
//                }
//                break;
//            }
//            return Container();
//          },
//        ),
//      ),
//    );
//  }

//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        title: Text('Location Monitoring'),
//      ),
//      body: StreamBuilder(
//        stream: _geolocator.getPositionStream(locationOptions),
//        builder: (context, snapshot) {
//          switch (snapshot.connectionState) {
//            case ConnectionState.none:
//              return Text('Error');
//              break;
//            case ConnectionState.waiting:
//              return Text('Loading ......');
//              break;
//            case ConnectionState.done:
//            case ConnectionState.active:
//              if (snapshot.hasData) {
//                print(snapshot.data);
//                CameraPosition cameraPosition = CameraPosition(
//                    target:
//                        LatLng(snapshot.data.latitude, snapshot.data.longitude),
//                    zoom: 15);
//                List<Marker> markers = [];
//                Marker marker = Marker(
//                  markerId: MarkerId('myposition'),
//                  position:
//                      LatLng(snapshot.data.latitude, snapshot.data.longitude),
//                );
//                markers.add(marker);
//                _myUserLocation.set({
//                  'latitude' : snapshot.data.latitude,
//                  'longitude' : snapshot.data.longitude,
//                });
//                return GoogleMap(
//                  initialCameraPosition: cameraPosition,
//                  markers: markers.toSet(),
//                );
//              } else {
//                return Text('No location Found');
//              }
//              break;
//          }
//          return Container();
//        },
//      ),
//    );
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monitoring All Locations'),
      ),
      body: (loaded)
          ? GoogleMap(
              initialCameraPosition: cameraPosition,
              markers: markers.toSet(),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  void _showWarning(String user) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('WARNING!'),
            content: Text('User $user is out of range'),
          );
        });
  }

//  Future<Position> _getCurrentLocation() async {
//    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
//    Position position = await geolocator.getCurrentPosition(
//        desiredAccuracy: LocationAccuracy.best);
//    return position;
//  }
}

class User {
  String name;

  User(this.name);
}
