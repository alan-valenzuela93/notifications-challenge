
extension MapExtension on Map<String, dynamic> {
  Map<String, dynamic> get cleanNulls {
    removeWhere((key, value) => value == null);
    return this;
  }
}