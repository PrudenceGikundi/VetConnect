import 'package:flutter/material.dart';
import 'package:vetconnectapp/models/farmer_model.dart';
import 'package:vetconnectapp/core/services/farmer_service.dart';

class FarmerViewModel extends ChangeNotifier {
  final FarmerService _farmerService;
  List<FarmerModel> _farmers = [];
  bool _isLoading = false;

  FarmerViewModel(this._farmerService);

  List<FarmerModel> get farmers => _farmers;
  bool get isLoading => _isLoading;

  Future<void> loadFarmers() async {
    _isLoading = true;
    notifyListeners();

    _farmers = await _farmerService.getFarmers();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateFarmerProfile(FarmerModel farmer) async {
    await _farmerService.updateFarmer(farmer);
    int index = _farmers.indexWhere((f) => f.id == farmer.id);
    if (index != -1) {
      _farmers[index] = farmer;
      notifyListeners();
    }
  }

  void addFarmer(FarmerModel farmer) {
    _farmers.add(farmer);
    notifyListeners();
  }

  void removeFarmer(String farmerId) {
    _farmers.removeWhere((farmer) => farmer.id == farmerId);
    notifyListeners();
  }
}