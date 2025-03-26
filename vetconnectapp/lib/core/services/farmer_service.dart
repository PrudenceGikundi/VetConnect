import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vetconnectapp/models/farmer_model.dart';
import 'package:logger/logger.dart';

class FarmerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();
  
  // Collection reference
  final CollectionReference _farmersCollection = 
      FirebaseFirestore.instance.collection('farmers');
  
  // Get current farmer profile
  Future<FarmerModel?> getCurrentFarmer() async {
    try {
      String uid = _auth.currentUser!.uid;
      DocumentSnapshot farmerDoc = await _farmersCollection.doc(uid).get();
      
      if (farmerDoc.exists) {
        return FarmerModel.fromMap(
          farmerDoc.data() as Map<String, dynamic>
        );
      }
      return null;
    } catch (e) {
      _logger.e('Error getting farmer: $e');
      return null;
    }
  }
  
  // Create or update farmer profile
  Future<bool> saveFarmerProfile(FarmerModel farmer) async {
    try {
      await _farmersCollection.doc(farmer.id).set(farmer.toMap());
      return true;
    } catch (e) {
      _logger.e('Error saving farmer profile: $e');
      return false;
    }
  }
  
  // Get all farmers
  Future<List<FarmerModel>> getAllFarmers() async {
    try {
      QuerySnapshot snapshot = await _farmersCollection.get();
      
      return snapshot.docs.map((doc) {
        return FarmerModel.fromMap(
          doc.data() as Map<String, dynamic>
        );
      }).toList();
    } catch (e) {
      _logger.e('Error getting all farmers: $e');
      return [];
    }
  }
  
  // Get farmer by ID
  Future<FarmerModel?> getFarmerById(String farmerId) async {
    try {
      DocumentSnapshot farmerDoc = await _farmersCollection.doc(farmerId).get();
      
      if (farmerDoc.exists) {
        return FarmerModel.fromMap(
          farmerDoc.data() as Map<String, dynamic>
        );
      }
      return null;
    } catch (e) {
      _logger.e('Error getting farmer by ID: $e');
      return null;
    }
  }
  
  // Update farmer profile
  Future<bool> updateFarmerProfile(Map<String, dynamic> data, String farmerId) async {
    try {
      await _farmersCollection.doc(farmerId).update(data);
      return true;
    } catch (e) {
      _logger.e('Error updating farmer profile: $e');
      return false;
    }
  }
  
  // Delete farmer
  Future<bool> deleteFarmer(String farmerId) async {
    try {
      await _farmersCollection.doc(farmerId).delete();
      return true;
    } catch (e) {
      _logger.e('Error deleting farmer: $e');
      return false;
    }
  }
  
  // Get farmers by location
  Future<List<FarmerModel>> getFarmersByLocation(String location) async {
    try {
      QuerySnapshot snapshot = await _farmersCollection
          .where('location', isEqualTo: location)
          .get();
      
      return snapshot.docs.map((doc) {
        return FarmerModel.fromMap(
          doc.data() as Map<String, dynamic>
        );
      }).toList();
    } catch (e) {
      _logger.e('Error getting farmers by location: $e');
      return [];
    }
  }
  
  // Search farmers by name
  Future<List<FarmerModel>> searchFarmersByName(String name) async {
    try {
      // Firebase doesn't support direct case-insensitive search
      // Using a workaround with lowercase field
      String searchName = name.toLowerCase();
      
      QuerySnapshot snapshot = await _farmersCollection
          .where('nameLowercase', isGreaterThanOrEqualTo: searchName)
          .where('nameLowercase', isLessThanOrEqualTo: '$searchName\uf8ff')
          .get();
      
      return snapshot.docs.map((doc) {
        return FarmerModel.fromMap(
          doc.data() as Map<String, dynamic>
        );
      }).toList();
    } catch (e) {
      _logger.e('Error searching farmers: $e');
      return [];
    }
  }

  Future<List<FarmerModel>> getFarmers() async {
    QuerySnapshot snapshot = await _firestore.collection('farmers').get();
    return snapshot.docs.map((doc) => FarmerModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }

  Future<void> updateFarmer(FarmerModel farmer) async {
    await _firestore.collection('farmers').doc(farmer.id).update(farmer.toMap());
  }
}