import 'package:cloud_firestore/cloud_firestore.dart';

class FarmerModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String location;
  final DateTime createdAt;

  FarmerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'location': location,
      'createdAt': createdAt,
    };
  }

  static FarmerModel fromMap(Map<String, dynamic> map) {
    return FarmerModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      location: map['location'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}