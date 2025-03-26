import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String vetId;
  final String farmerId;
  final String vetName;
  final String farmerName;
  final DateTime scheduledDate;
  final String timeSlot;
  final String status;
  final String animalType;
  final String reason;
  final bool isEmergency;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String notes;
  final int durationMinutes;

  AppointmentModel({
    required this.id,
    required this.vetId,
    required this.farmerId,
    required this.vetName,
    required this.farmerName,
    required this.scheduledDate,
    required this.timeSlot,
    required this.status,
    required this.animalType,
    required this.reason,
    required this.isEmergency,
    required this.createdAt,
    required this.updatedAt,
    required this.notes,
    required this.durationMinutes,
  });

  AppointmentModel copyWith({
    String? id,
    String? vetId,
    String? farmerId,
    String? vetName,
    String? farmerName,
    DateTime? scheduledDate,
    String? timeSlot,
    String? status,
    String? animalType,
    String? reason,
    bool? isEmergency,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    int? durationMinutes,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      vetId: vetId ?? this.vetId,
      farmerId: farmerId ?? this.farmerId,
      vetName: vetName ?? this.vetName,
      farmerName: farmerName ?? this.farmerName,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      animalType: animalType ?? this.animalType,
      reason: reason ?? this.reason,
      isEmergency: isEmergency ?? this.isEmergency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vetId': vetId,
      'farmerId': farmerId,
      'vetName': vetName,
      'farmerName': farmerName,
      'scheduledDate': scheduledDate,
      'timeSlot': timeSlot,
      'status': status,
      'animalType': animalType,
      'reason': reason,
      'isEmergency': isEmergency,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'notes': notes,
      'durationMinutes': durationMinutes,
    };
  }

  static AppointmentModel fromMap(Map<String, dynamic> map) {
    return AppointmentModel(
      id: map['id'],
      vetId: map['vetId'],
      farmerId: map['farmerId'],
      vetName: map['vetName'],
      farmerName: map['farmerName'],
      scheduledDate: (map['scheduledDate'] as Timestamp).toDate(),
      timeSlot: map['timeSlot'],
      status: map['status'],
      animalType: map['animalType'],
      reason: map['reason'],
      isEmergency: map['isEmergency'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      notes: map['notes'],
      durationMinutes: map['durationMinutes'],
    );
  }
}