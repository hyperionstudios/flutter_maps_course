import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps_course/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_maps_course/realtime_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map Screen'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return HomePage();
              }));
            },
          ),
          IconButton(
            icon: Icon(Icons.pin_drop),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return RealTimeScreen();
              }));
            },
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection('locations').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return new Text('Loading...');
              default:
                List<DocumentSnapshot> documents = snapshot.data.documents;
                DocumentSnapshot documentSnapshot = documents[0];

                CameraPosition cameraPosition = CameraPosition(
                  target: LatLng(documentSnapshot['location']['latitude'],
                      documentSnapshot['location']['longitude']),
                  zoom: 15,
                );

                List<Marker> markers = [];
                for (DocumentSnapshot snapshot in documents) {
                  markers.add(Marker(
                    markerId: MarkerId(snapshot.documentID),
                    position: LatLng(
                      snapshot['location']['latitude'],
                      snapshot['location']['longitude']
                    ),
                    onTap: (){
                      print('tapped on marker');
                    },
                    infoWindow: InfoWindow(
                      title: 'Marker Title',
                      snippet: 'Marker information',
                      onTap: () {
                        print('tapped on info');
                      },
                    ),
                  ));
                }

                return GoogleMap(
                  initialCameraPosition: cameraPosition,
                  markers: markers.toSet(),
                );
            }
          },
        ),
      ),
    );
  }
}
