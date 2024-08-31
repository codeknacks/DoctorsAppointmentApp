class DoctorProfile {
  String profilePicUrl;
  String name;
  String specialization;
  String clinicAddress;
  double ratePerHour;
  Map<String, bool> availability;

  DoctorProfile({
    required this.profilePicUrl,
    required this.name,
    required this.specialization,
    required this.clinicAddress,
    required this.ratePerHour,
    required this.availability,
  });

  Map<String, dynamic> toMap() {
    return {
      'profilePicUrl': profilePicUrl,
      'name': name,
      'specialization': specialization,
      'clinicAddress': clinicAddress,
      'ratePerHour': ratePerHour,
      'availability': availability,
    };
  }

  factory DoctorProfile.fromMap(Map<String, dynamic> map) {
    return DoctorProfile(
      profilePicUrl: map['profilePicUrl'],
      name: map['name'],
      specialization: map['specialization'],
      clinicAddress: map['clinicAddress'],
      ratePerHour: map['ratePerHour'],
      availability: Map<String, bool>.from(map['availability']),
    );
  }
}
