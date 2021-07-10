class KmlModel {
  final String message;
  final String filename;
  final String downloadUrl;

  KmlModel(
      {this.message,
      this.filename,
      this.downloadUrl});

  factory KmlModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return KmlModel(
        message: json["message"] == null ? null : json["message"],
        filename: json["filename"] == null ? null : json["filename"],
        downloadUrl: json["downloadUrl"] == null ? null : json["downloadUrl"],
    );
  }

  static KmlModel fromJsonObject(Object object) {
    if (object == null) return null;
    return KmlModel.fromJson(object);
  }

}
