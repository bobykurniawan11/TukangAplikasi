import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Position _currentPosition;
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _myLocation;
  List<Marker> markers = <Marker>[];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                color: Colors.greenAccent,
                child: Text("Tampilkan map sesuai posisi device"),
                onPressed: () {
                  _getCurrentLocation();
                },
              ),
              (_currentPosition != null)
                  ? Expanded(
                child: GoogleMapWidget(),
              )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  _getCurrentLocation() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        _myLocation = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 12,
          bearing: 15.0,
          tilt: 75.0,
        );
        markers.add(
          Marker(
            markerId: MarkerId("Alamat"),
            position: LatLng(position.latitude,position.longitude),
            infoWindow: InfoWindow(
                title: "Alamat"),
            onTap: () {},
          ),
        );
      });
    }).catchError((e) {
      print(e);
    });
  }

  GoogleMapWidget() {
    return GoogleMap(
      initialCameraPosition: _myLocation,
      mapType: MapType.normal,
      markers: Set<Marker>.of(markers),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
    );
  }
}
