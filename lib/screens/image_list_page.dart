import 'dart:io';

import 'package:flutter/material.dart';
import 'package:praktikum3/models/image_model.dart';
import 'package:praktikum3/services/database_helper.dart';

class ImageListPage extends StatefulWidget {
  const ImageListPage({super.key});
  @override
  State<ImageListPage> createState() => _ImageListPageState();
}

class _ImageListPageState extends State<ImageListPage> {
  List<ImageModel> images = [];
  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final data = await DataBaseHelper.instance.getAllImages();
    setState(() {
      images = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daftar Gambar')),
      body:
          images.isEmpty
              ? Center(child: Text('Tidak ada gambar'))
              : ListView.builder(
                itemCount: images.length,
                itemBuilder: (context, index) {
                  print(
                    'Stored image path: ${images[index].imagePath}',
                  ); // Debugging path
                  File imageFile = File(images[index].imagePath);
                  if (!imageFile.existsSync()) {
                    print(
                      'File not found: ${images[index].imagePath}',
                    ); // Tambahan log jika file tidak ditemukan
                    return ListTile(
                      leading: Icon(Icons.broken_image),
                      title: Text(
                        'Image ${images[index].id} (File tidak ditemukan)',
                      ),
                    );
                  }
                  return ListTile(
                    leading: Image.file(
                      imageFile,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text('Image ${images[index].id}'),
                  );
                },
              ),
    );
  }
}
