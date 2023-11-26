class CurrentWifiCount {
  final String message;

  const CurrentWifiCount({
    required this.message
  });

  factory CurrentWifiCount.fromJson(Map<String, dynamic> json) {
    return CurrentWifiCount(
      message: json['number'].toString(),
    );
  }
}