// Booking model
// userId is nullable on purpose:
//   - Logged in when booked -> userId = their account id
//   - Booked as guest        -> userId = null
// "My Bookings" filters by this so guests and different accounts each
// only ever see their own bookings on a shared device.

class BookingModel {
  final String id;
  final String? userId;
  final String professionalId;
  final String professionalName;
  final String professionalPhoto;
  final String tradeName;
  final double pricePerHour;
  final String customerName;
  final String address;
  final String date;
  final String time;
  final String notes;

  BookingModel({
    required this.id,
    required this.userId,
    required this.professionalId,
    required this.professionalName,
    required this.professionalPhoto,
    required this.tradeName,
    required this.pricePerHour,
    required this.customerName,
    required this.address,
    required this.date,
    required this.time,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'professionalId': professionalId,
      'professionalName': professionalName,
      'professionalPhoto': professionalPhoto,
      'tradeName': tradeName,
      'pricePerHour': pricePerHour,
      'customerName': customerName,
      'address': address,
      'date': date,
      'time': time,
      'notes': notes,
    };
  }

  factory BookingModel.fromMap(Map<dynamic, dynamic> map) {
    return BookingModel(
      id: map['id'] ?? '',
      userId: map['userId'],
      professionalId: map['professionalId'] ?? '',
      professionalName: map['professionalName'] ?? '',
      professionalPhoto: map['professionalPhoto'] ?? '',
      tradeName: map['tradeName'] ?? '',
      pricePerHour: (map['pricePerHour'] is num) ? (map['pricePerHour'] as num).toDouble() : 0.0,
      customerName: map['customerName'] ?? '',
      address: map['address'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      notes: map['notes'] ?? '',
    );
  }
}
