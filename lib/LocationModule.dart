import 'Types.dart';
import 'package:tuple/tuple.dart';
import 'package:location/location.dart';
import 'package:localstorage/localstorage.dart';
import 'package:flutter/material.dart';

class LocationModule {
  final LocalStorage localStorage = new LocalStorage('');
  Location _location = new Location();
  LocationData _locationData;

  Future<bool> checkLocationEnabled() async {
    if (localStorage.getItem('locationDeniedForever')) {
      return false;
    }

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return false;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.deniedForever){
      localStorage.setItem('locationDeniedForever', true);
    }

    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }

    return _serviceEnabled && _permissionGranted == PermissionStatus.granted;
  }

  Future<void> refreshUserLocation() async {
    if(!await this.checkLocationEnabled()) {
      throw("locationDisabled");
    }

    _locationData = await _location.getLocation()
      .catchError((e) {
        if(e == "PERMISSION_DENIED"){
          throw("locationDisabled");
        }
      });
  }

  Tuple2<double, double> get userCoordinate {
    return Tuple2(_locationData.latitude, _locationData.longitude);
  }

  Future<Tuple2<double, double>> requestUserCoordinate() async {
    return refreshUserLocation()
      .catchError((e) {
        if(e == "locationDisabled"){
          // TODO: Location disabled handling
        }
      })
      .then((_v) {
        return this.userCoordinate;
      });
  }
}

class gettingLocationActivityState extends State<gettingLocationActivity> {
  @override
  LocationModule _locationModule = new LocationModule();

  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class gettingLocationActivity extends StatefulWidget {
  @override
  gettingLocationActivityState createState() => gettingLocationActivityState();
}

class detectingLocationIndicatorComponent extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Text('Detecting Your Location')
    );
  }
}