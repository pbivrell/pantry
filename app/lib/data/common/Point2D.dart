class Point2D {

  final String x;
  final int y;

  Point2D({
    required this.x,
    required this.y,
  });

  factory Point2D.fromJson(Map<String, dynamic> json) {
    return Point2D(
      x: json['x'],
      y: json['y'],
    );
  }
}