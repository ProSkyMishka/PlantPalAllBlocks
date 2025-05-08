class Plant {
  final String id;
  final String name;
  final String imageUrl;
  final String moisture;
  final String temperature;
  final String description;
  final int waterInterval;
  final int seconds;
  final String mlid;
  final bool usered;

  Plant({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.moisture,
    required this.temperature,
    required this.description,
    required this.waterInterval,
    required this.seconds,
    required this.mlid,
    required this.usered,
  });

  factory Plant.fromJson(Map<String, dynamic> json) {
    return Plant(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageURL'],
      moisture: json['humidity'],
      temperature: json['temp'],
      description: json['description'],
      waterInterval: json['waterInterval'],
      seconds: json['seconds'],
      mlid: json['MLID'],
      usered: json['usered'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageURL': imageUrl,
      'temp': temperature,
      'humidity': moisture,
      'waterInterval': waterInterval,
      'seconds': seconds,
      'MLID': mlid,
      'usered': usered,
    };
  }

  Plant copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    String? moisture,
    String? temperature,
    String? description,
    String? disease,
    int? waterInterval,
    int? seconds,
    String? mlid,
    bool? usered,
  }) {
    return Plant(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: avatarUrl ?? this.imageUrl,
      moisture: moisture ?? this.moisture,
      temperature: temperature ?? this.temperature,
      description: description ?? this.description,
      waterInterval: waterInterval ?? this.waterInterval,
      seconds: seconds ?? this.seconds,
      mlid: mlid ?? this.mlid,
      usered: usered ?? this.usered,
    );
  }
}
