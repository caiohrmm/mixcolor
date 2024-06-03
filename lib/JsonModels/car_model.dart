class Car {
  final int? carId;
  final String brand;
  final String model;
  final int year;

  Car({
    this.carId,
    required this.brand,
    required this.model,
    required this.year,
  });

  factory Car.fromMap(Map<String, dynamic> json) => Car(
        carId: json["carId"],
        brand: json["brand"],
        model: json["model"],
        year: json["year"],
      );

  Map<String, dynamic> toMap() => {
        "carId": carId,
        "brand": brand,
        "model": model,
        "year": year,
      };
}
