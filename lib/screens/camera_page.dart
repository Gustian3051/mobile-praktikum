import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:praktikum3/models/image_model.dart';
import 'package:praktikum3/services/database_helper.dart';
import 'package:sensors_plus/sensors_plus.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});
  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(firstCamera, ResolutionPreset.high);
    await _controller!.initialize();
    if (!mounted) return;
    setState(() {});
  }

  Future<String> saveImageToStorage(String imagePath) async {
    final directory =
        await getApplicationDocumentsDirectory(); // Dapatkan direktori aplikasi
    final fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.png';
    final newPath = '${directory.path}/$fileName';

    final File imageFile = File(imagePath);
    final File newImage = await imageFile.copy(
      newPath,
    ); // Simpan gambar ke storage aplikasi
    return newImage.path; // Return path baru
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Layanan lokasi tidak aktif.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Izin lokasi tidak diberikan.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Izin lokasi tidak diberikan secara permanen.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      // Ambil gambar
      final image = await _controller!.takePicture();
      final savedImagePath = await saveImageToStorage(image.path);

      // Dapatkan lokasi
      final position = await _getCurrentLocation();
      final locationString = "${position.latitude}, ${position.longitude}";

      // Ambil sensor
      double accelX = 0, accelY = 0, accelZ = 0;
      final subscription = accelerometerEvents.listen((
        AccelerometerEvent event,
      ) {
        accelX = event.x;
        accelY = event.y;
        accelZ = event.z;
      });

      await Future.delayed(Duration(seconds: 5));
      subscription.cancel();

      // Simpan ke database
      await DataBaseHelper.instance.insertImage(
        ImageModel(
          imagePath: savedImagePath,
          location: locationString,
          accelerometerX: accelX,
          accelerometerY: accelY,
          accelerometerZ: accelZ,
        ),
      );

      // Navigasi ke halaman preview
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ImagePreviewPage(
                imagePath: savedImagePath,
                location: locationString,
                accelerometerX: accelX,
                accelerometerY: accelY, 
                accelerometerZ: accelZ,
              ),
        ),
      );
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(title: Text('Camera')),
      body: CameraPreview(_controller!),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture, // Panggil fungsi yang sudah diperbaiki
        child: Icon(Icons.camera),
      ),
    );
  }
}

class ImagePreviewPage extends StatelessWidget {
  final String imagePath;
  final String location;
  final double accelerometerX;
  final double accelerometerY;
  final double accelerometerZ;

  const ImagePreviewPage({
    super.key,
    required this.imagePath,
    required this.location,
    required this.accelerometerX,
    required this.accelerometerY,
    required this.accelerometerZ,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Preview')),
      body: Center(
        child: Column(
          children: [
            Image.file(File(imagePath), width: 500, height: 500),
            SizedBox(height: 5),
            Text('Lokasi: $location'),
            Text('Accelerometer X: $accelerometerX'),
            Text('Accelerometer Y: $accelerometerY'),
            Text('Accelerometer Z: $accelerometerZ'),
          ],
        ),
      ),
    );
  }
}
