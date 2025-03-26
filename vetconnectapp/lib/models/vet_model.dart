import 'package:cloud_firestore/cloud_firestore.dart';

class VetModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final List<String> specializations;
  final String experience;
  final String location;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final DateTime createdAt;

  VetModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.specializations,
    required this.experience,
    required this.location,
    required this.rating,
    required this.reviewCount,
    required this.isAvailable,
    required this.createdAt,
  });

  VetModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    List<String>? specializations,
    String? experience,
    String? location,
    double? rating,
    int? reviewCount,
    bool? isAvailable,
    DateTime? createdAt,
  }) {
    return VetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      specializations: specializations ?? this.specializations,
      experience: experience ?? this.experience,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'specializations': specializations,
      'experience': experience,
      'location': location,
      'rating': rating,
      'reviewCount': reviewCount,
      'isAvailable': isAvailable,
      'createdAt': createdAt,
    };
  }

  static VetModel fromMap(Map<String, dynamic> map) {
    return VetModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      specializations: List<String>.from(map['specializations']),
      experience: map['experience'],
      location: map['location'],
      rating: map['rating'],
      reviewCount: map['reviewCount'],
      isAvailable: map['isAvailable'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}