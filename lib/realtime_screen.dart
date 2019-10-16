
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
  FirebaseUser user;
  Geolocator _geolocator;
  LocationOptions locationOptions;
  DatabaseReference _myUserLocation;

  void checkPermission() {
    _geolocator.checkGeolocationPermissionStatus().then((status) { print('status: $status'); });
    _geolocator.checkGeolocationPermissionStatus(locationPermission: GeolocationPermission.locationAlways).then((status) { print('always status: $status'); });
    _geolocator.checkGeolocationPermissionStatus(locationPermission: GeolocationPermission.locationWhenInUse)..then((status) { print('whenInUse status: $status'); });
  }

  @override
  void initState() {
    _geolocator = Geolocator();
    locationOptions = LocationOptions(accuracy: LocationAccuracy.best , );
    SharedPreferences.getInstance().then((sharedPref){
      String uid = sharedPref.getString('uid');
      _myUserLocation = FirebaseDatabase.instance.reference().child(uid).child('location');
    });
    checkPermission();
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Monitoring'),
      ),
      body: StreamBuilder(
        stream: _geolocator.getPositionStream(locationOptions),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Text('Error');
              break;
            case ConnectionState.waiting:
              return Text('Loading ......');
              break;
            case ConnectionState.done:
            case ConnectionState.active:
              if (snapshot.hasData) {
                print(snapshot.data);
                CameraPosition cameraPosition = CameraPosition(
                    target:
                        LatLng(snapshot.data.latitude, snapshot.data.longitude),
                    zoom: 15);
                List<Marker> markers = [];
                Marker marker = Marker(
                  markerId: MarkerId('myposition'),
                  position:
                      LatLng(snapshot.data.latitude, snapshot.data.longitude),
                );
                markers.add(marker);
                _myUserLocation.set({
                  'latitude' : snapshot.data.latitude,
                  'longitude' : snapshot.data.longitude,
                });
                return GoogleMap(
                  initialCameraPosition: cameraPosition,
                  markers: markers.toSet(),
                );
              } else {
                return Text('No location Found');
              }
              break;
          }
          return Container();
        },
      ),
    );
  }

  Future<Position> _getCurrentLocation() async {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    Position position = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    return position;
  }
}
