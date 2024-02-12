import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_google_maps/data_dummy.dart';
import 'package:flutter_google_maps/maps_type_google.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsV2Page extends StatefulWidget {
  const MapsV2Page({super.key});

  @override
  State<MapsV2Page> createState() => _MapsV2PagetState();
}

class _MapsV2PagetState extends State<MapsV2Page> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  double latitude = -6.195046270347632;
  double longitude = 106.79489053942709;

  var mapType = MapType.normal;

  Position? devicePosition;
  String? address;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maps V2'),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              setState(() {
                switch (value) {
                  case Type.Normal:
                    mapType = MapType.normal;
                    break;
                  case Type.Hybrid:
                    mapType = MapType.hybrid;
                    break;
                  case Type.Satellite:
                    mapType = MapType.satellite;
                    break;
                  case Type.Terrain:
                    mapType = MapType.terrain;
                  default:
                }
              });
            },
            itemBuilder: (context) {
              return googleMapTypes
                  .map(
                    (item) => PopupMenuItem(
                      value: item.type,
                      child: Text(item.type.name),
                    ),
                  )
                  .toList();
            },
          )
        ],
      ),
      body: Stack(
        children: [
          _buildGoogleMaps(),
          _buildSearchCard(),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Geolocator.requestPermission();
  }

  GoogleMap _buildGoogleMaps() {
    return GoogleMap(
      mapType: mapType,
      initialCameraPosition: CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 17,
      ),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      myLocationEnabled: true,
    );
  }

  _buildSearchCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 150,
        width: double.infinity,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(10),
          child: Column(
            children: [
              // field pencarian

              Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 8, bottom: 4),
                child: TextField(
                  decoration: InputDecoration(
                      hintText: 'Masukkan alamat...',
                      contentPadding: const EdgeInsets.only(left: 15, top: 15),
                      suffixIcon: IconButton(
                        onPressed: searchLocation,
                        icon: const Icon(Icons.search),
                      )),
                  onChanged: (value) {
                    address = value;
                  },
                  onSubmitted: (value) {
                    searchLocation();
                  },
                ),
              ),

              // tombol untuk mendapatkan posisi device
              ElevatedButton(
                  onPressed: () {
                    getCurrentPosition().then((value) async {
                      setState(() {
                        devicePosition = value;
                      });
                      GoogleMapController controller = await _controller.future;
                      final cameraPosition = CameraPosition(
                        target: LatLng(value!.latitude, value.longitude),
                        zoom: 17,
                      );
                      final cameraUpdate = CameraUpdate.newCameraPosition(
                        cameraPosition,
                      );
                      controller.animateCamera(cameraUpdate);
                    });
                  },
                  child: const Text("Dapatkan lokasi saat ini")),

              // teks latitude dan longitude
              devicePosition != null
                  ? Text(
                      "Lokasi saat ini : ${devicePosition?.latitude} ${devicePosition?.longitude}")
                  : const Text("Lokasi belum terdeteksi")
            ],
          ),
        ),
      ),
    );
  }

  Future<Position?> getCurrentPosition() async {
    Position? currentPosition;
    try {
      currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      currentPosition = null;
      Fluttertoast.showToast(msg: e.toString());
    }
    return currentPosition;
  }

  Future searchLocation() async {
    try {
      await GeocodingPlatform.instance
          .locationFromAddress(address!) 
          .then((value) async {
        GoogleMapController controller = await _controller.future;
        final cameraPosition = CameraPosition(
          target: LatLng(value[0].latitude, value[0].longitude),
          zoom: 17,
        );
        final cameraUpdate = CameraUpdate.newCameraPosition(
          cameraPosition,
        );
        controller.animateCamera(cameraUpdate);
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Alamat tidak ditemukan');
    }
  }
}
