class Appointment {
  final int? age; // Nullable
  final String? appointmentDate; // Nullable
  final String? doctorId; // Nullable
  final int? mobileNumber; // Nullable
  final String? name; // Nullable
  final String? status; // Nullable

  Appointment({
    this.age,
    this.appointmentDate,
    this.doctorId,
    this.mobileNumber,
    this.name,
    this.status,
  });

  factory Appointment.fromFirestore(Map<String, dynamic> data) {
    return Appointment(
      age: data['age'] as int?, // Nullable cast
      appointmentDate: data['appointmentDate'] as String?, // Nullable cast
      doctorId: data['doctorId'] as String?, // Nullable cast
      mobileNumber: data['mobileNumber'] as int?, // Nullable cast
      name: data['name'] as String?, // Nullable cast
      status: data['status'] as String?, // Nullable cast
    );
  }
}
