import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vetconnectapp/models/vet_model.dart';
import 'package:logger/logger.dart';

class VetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();
  
  // Collection reference
  final CollectionReference _vetsCollection = 
      FirebaseFirestore.instance.collection('vets');
  
  // Get current vet profile
  Future<VetModel?> getCurrentVet() async {
    try {
      String uid = _auth.currentUser!.uid;
      DocumentSnapshot vetDoc = await _vetsCollection.doc(uid).get();
      
      if (vetDoc.exists) {
        return VetModel.fromMap(
          vetDoc.data() as Map<String, dynamic>
        );
      }
      return null;
    } catch (e) {
      _logger.e('Error getting vet: $e');
      return null;
    }
  }
  
  // Create or update vet profile
  Future<bool> saveVetProfile(VetModel vet) async {
    try {
      await _vetsCollection.doc(vet.id).set(vet.toMap());
      return true;
    } catch (e) {
      _logger.e('Error saving vet profile: $e');
      return false;
    }
  }
  
  // Get all vets
  Future<List<VetModel>> getAllVets() async {
    try {
      QuerySnapshot snapshot = await _vetsCollection.get();
      
      return snapshot.docs.map((doc) {
        return VetModel.fromMap(
          doc.data() as Map<String, dynamic>
        );
      }).toList();
    } catch (e) {
      _logger.e('Error getting all vets: $e');
      return [];
    }
  }
  
  // Get vet by ID
  Future<VetModel?> getVetById(String vetId) async {
    try {
      DocumentSnapshot vetDoc = await _vetsCollection.doc(vetId).get();
      
      if (vetDoc.exists) {
        return VetModel.fromMap(
          vetDoc.data() as Map<String, dynamic>
        );
      }
      return null;
    } catch (e) {
      _logger.e('Error getting vet by ID: $e');
      return null;
    }
  }
  
  // Update vet profile
  Future<bool> updateVetProfile(Map<String, dynamic> data, String vetId) async {
    try {
      await _vetsCollection.doc(vetId).update(data);
      return true;
    } catch (e) {
      _logger.e('Error updating vet profile: $e');
      return false;
    }
  }
  
  // Delete vet
  Future<bool> deleteVet(String vetId) async {
    try {
      await _vetsCollection.doc(vetId).delete();
      return true;
    } catch (e) {
      _logger.e('Error deleting vet: $e');
      return false;
    }
  }
  
  // Get vets by specialization
  Future<List<VetModel>> getVetsBySpecialization(String specialization) async {
    try {
      QuerySnapshot snapshot = await _vetsCollection
          .where('specializations', arrayContains: specialization)
          .get();
      
      return snapshot.docs.map((doc) {
        return VetModel.fromMap(
          doc.data() as Map<String, dynamic>
        );
      }).toList();
    } catch (e) {
      _logger.e('Error getting vets by specialization: $e');
      return [];
    }
  }
  
  // Get vets by location
  Future<List<VetModel>> getVetsByLocation(String location) async {
    try {
      QuerySnapshot snapshot = await _vetsCollection
          .where('location', isEqualTo: location)
          .get();
      
      return snapshot.docs.map((doc) {
        return VetModel.fromMap(
          doc.data() as Map<String, dynamic>
        );
      }).toList();
    } catch (e) {
      _logger.e('Error getting vets by location: $e');
      return [];
    }
  }
  
  // Search vets by name
  Future<List<VetModel>> searchVetsByName(String name) async {
    try {
      // Firebase doesn't support direct case-insensitive search
      // Using a workaround with lowercase field
      String searchName = name.toLowerCase();
      
      QuerySnapshot snapshot = await _vetsCollection
          .where('nameLowercase', isGreaterThanOrEqualTo: searchName)
          .where('nameLowercase', isLessThanOrEqualTo: '$searchName\uf8ff')
          .get();
      
      return snapshot.docs.map((doc) {
        return VetModel.fromMap(
          doc.data() as Map<String, dynamic>
        );
      }).toList();
    } catch (e) {
      _logger.e('Error searching vets: $e');
      return [];
    }
  }
  
  // Get available vets (those who are currently online and accepting appointments)
  Future<List<VetModel>> getAvailableVets() async {
    try {
      QuerySnapshot snapshot = await _vetsCollection
          .where('isAvailable', isEqualTo: true)
          .get();
      
      return snapshot.docs.map((doc) {
        return VetModel.fromMap(
          doc.data() as Map<String, dynamic>
        );
      }).toList();
    } catch (e) {
      _logger.e('Error getting available vets: $e');
      return [];
    }
  }
}