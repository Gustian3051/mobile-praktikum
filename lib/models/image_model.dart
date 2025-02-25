class ImageModel {
  final int? id;
  final String imagePath;

  ImageModel({this.id, required this.imagePath});

  Map<String, dynamic> toMap() {
    return {'id': id, 'imagePath': imagePath};
  }

  factory ImageModel.fromMap(Map<String, dynamic> map) {
    return ImageModel(id: map['id'], imagePath: map['imagePath']);
  }

  ImageModel copyWith({int? id, String? imagePath}) {
    return ImageModel(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
