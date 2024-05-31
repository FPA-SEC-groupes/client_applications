class WifiInfo {
  int? id;
  String ssid;
  String password;
  int? id_space;

  WifiInfo({required this.ssid, required this.password , this.id_space});

  // From JSON
  factory WifiInfo.fromJson(Map<String, dynamic> json) {
    return WifiInfo(
      ssid: json['ssid'],
      password: json['password'],
      id_space: json['space']['id_space'],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'ssid': ssid,
      'password': password,
    };
  }
}
