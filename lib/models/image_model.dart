class ImageModel {
  final int? id;
  final String? imagePath;
  final String? location;
  final double? accelerometerX;
  final double? accelerometerY;
  final double? accelerometerZ;

  ImageModel({
    this.id,
    this.imagePath,
    this.location,
    this.accelerometerX,
    this.accelerometerY,
    this.accelerometerZ,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'location': location,
      'accelerometerX': accelerometerX,
      'accelerometerY': accelerometerY,
      'accelerometerZ': accelerometerZ,
    };
  }

  factory ImageModel.fromMap(Map<String, dynamic> map) {
    return ImageModel(
      id: map['id'],
      imagePath: map['imagePath'],
      location: map['location'],
      accelerometerX: map['accelerometerX'],
      accelerometerY: map['accelerometerY'],
      accelerometerZ: map['accelerometerZ'],
    );
  }

  ImageModel copyWith({
    int? id,
    String? imagePath,
    String? location,
    double? accelerometerX,
    double? accelerometerY,
    double? accelerometerZ,
  }) {
    return ImageModel(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      location: location ?? this.location,
      accelerometerX: accelerometerX ?? this.accelerometerX,
      accelerometerY: accelerometerY ?? this.accelerometerY,
      accelerometerZ: accelerometerZ ?? this.accelerometerZ,
    );
  }
}
