class ColorModel {
  final int? colorId;
  final String colorName;
  final String inkCode;

  ColorModel({
    this.colorId,
    required this.colorName,
    required this.inkCode,
  });

  factory ColorModel.fromMap(Map<String, dynamic> json) => ColorModel(
        colorId: json["colorId"],
        colorName: json["colorName"],
        inkCode: json["inkCode"],
      );

  Map<String, dynamic> toMap() => {
        "colorId": colorId,
        "colorName": colorName,
        "inkCode": inkCode,
      };
}
