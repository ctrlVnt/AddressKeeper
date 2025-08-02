class AppInfo {
  final String appName;
  final String phone;
  final String address;
  final String? url;

  AppInfo({
    required this.appName,
    required this.phone,
    required this.address,
    this.url,
  });

  Map<String, dynamic> toMap() {
    return {
      'appName': appName,
      'phone': phone,
      'address': address,
      'url': url,
    };
  }

  factory AppInfo.fromMap(Map<String, dynamic> map) {
    return AppInfo(
      appName: map['appName'],
      phone: map['phone'],
      address: map['address'],
      url: map['url'],
    );
  }
}
