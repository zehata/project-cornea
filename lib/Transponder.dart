import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/animation.dart';
import 'package:latlong/latlong.dart';
import 'package:tuple/tuple.dart';

import 'LocationModule.dart';
import 'Notification.dart';

class Transponder {
  FirebaseApp app;
  DatabaseReference dbRef;
  bool _initialized = false;
  StreamSubscription<Event> cancelInterruptionListener;

  Transponder(){
    firebaseSetup().then((_v) {
    });
  }

  Future<bool> firebaseSetup() async {
    if(_initialized){
      return true;
    }

    FirebaseApp.configure(
        name: 'db',
        options: Platform.isIOS
            ? const FirebaseOptions(
            googleAppID: '',
            gcmSenderID: '',
            databaseURL: '')
            : const FirebaseOptions(
            googleAppID: '1:38730464901:android:cf92a64e63e21e1fe3f3ec',
            apiKey: 'AIzaSyCFPAUF8YZmzurQ2c1Esi_ofMPxRbJn1qQ',
            databaseURL: 'https://fluttertest0-a620f.firebaseio.com')
    ).then((value) async {
      dbRef = FirebaseDatabase.instance.reference();
    }).then((_v) {
      _initialized = true;
      return true;
    });
  }

  void pushToDatabase(path, data) {
    dbRef.child(path).push().set(data);
  }

  void updateDatabase(path, data) {
    dbRef.child(path).update(data);
  }

  void listenForCancel(helpRequestID) {
    cancelInterruptionListener = dbRef.child('/helpRequests/$helpRequestID').onChildChanged.listen((event) {
      // todo cancel request
    });
  }

  void createHelpRequest(currentLocation, String destinationID) {
    final data = {
      "Lat": currentLocation.Lat,
      "Lng": currentLocation.Lng,
      "destinationID": destinationID
    };
    pushToDatabase("helpRequests", data);
  }
}

void subscribeToHelpRequests() {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  firebaseMessaging.requestNotificationPermissions();
  firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        handleMessage(message, false);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
      onBackgroundMessage: handleBgMessage
  );
  firebaseMessaging.getToken()
    .then((value) {
      // subscribe
    });
}

void handleMessage(Map<String, dynamic> message, bool background) {
  final Distance distance = new Distance();
  final double _uLatitude = double.parse(message["data"].Lat);
  final double _uLongitude = double.parse(message["data"].Lng);
  final LocationModule locationModule = new LocationModule();

  // check volunteer's location
  double _vLatitude;
  double _vLongitude;
  locationModule.requestUserCoordinate()
    .then((Tuple2<double, double> value) {
      _vLongitude = value.item1;
      _vLongitude = value.item2;
    })
    .then((_v) {
      // calculate distance between user and volunteer
      final int meter = distance(
        new LatLng(_uLatitude, _uLongitude),
        new LatLng(_vLatitude, _vLongitude),
      );

      if(meter > 50) {
        return "Volunteer too far";
      }

      if(background) {
        notifyUserHelpRequest(message);
      } else {
        
      }
    });
}

Future<dynamic> handleBgMessage(Map<String, dynamic> message) {
  handleMessage(message, true);
}