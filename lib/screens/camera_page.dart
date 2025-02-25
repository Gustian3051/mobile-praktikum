import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:praktikum3/models/image_model.dart';
import 'package:praktikum3/services/database_helper.dart';

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

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final image = await _controller!.takePicture();
      final savedImagePath = await saveImageToStorage(image.path);

      // Simpan ke database
      await DataBaseHelper.instance.insertImage(
        ImageModel(imagePath: savedImagePath),
      );

      // Navigasi ke halaman preview
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePreviewPage(imagePath: savedImagePath),
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
  const ImagePreviewPage({super.key, required this.imagePath});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Preview')),
      body: Center(child: Image.file(File(imagePath))),
    );
  }
}
