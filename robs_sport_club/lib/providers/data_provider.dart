import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:robs_sport_club/services/api_service.dart';
import 'package:robs_sport_club/models/child.dart';
import 'package:robs_sport_club/models/participation.dart';
import 'package:robs_sport_club/models/user.dart';

class DataProvider with ChangeNotifier {
  late final ApiService _apiService;
  List<Child> _children = [];
  List<Participation> _participations = [];
  List<User> _users = [];

  DataProvider() {
    try {
      _apiService = ApiService(); // Initialize ApiService
    } catch (e) {
      log('DataProvider initialization failed: $e', level: 1000);
      rethrow;
    }
  }

  // Getters for data
  List<Child> get children => _children;
  List<Participation> get participations => _participations;
  List<User> get users => _users;

  // Fetch all children
  Future<void> fetchChildren() async {
    try {
      final response = await _apiService.fetchChildren();
      _children = (response as List).map((json) => Child.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      log('Error fetching children: $e', level: 1000);
      rethrow;
    }
  }

  // Fetch all participations
  Future<void> fetchParticipations() async {
    try {
      final response = await _apiService.fetchParticipations();
      _participations =
          (response as List).map((json) => Participation.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      log('Error fetching participations: $e', level: 1000);
      rethrow;
    }
  }

  // Fetch all users
  Future<void> fetchUsers() async {
    try {
      final response = await _apiService.fetchUsers();
      _users = (response as List).map((json) => User.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      log('Error fetching users: $e', level: 1000);
      rethrow;
    }
  }

  // Add a new child
  Future<void> addChild(Child child) async {
    try {
      await _apiService.addChild(child.toJson());
      _children.add(child);
      notifyListeners();
    } catch (e) {
      log('Error adding child: $e', level: 1000);
      rethrow;
    }
  }

  // Add a new participation
  Future<void> addParticipation(Participation participation) async {
    try {
      await _apiService.addParticipation(participation.toJson());
      _participations.add(participation);
      notifyListeners();
    } catch (e) {
      log('Error adding participation: $e', level: 1000);
      rethrow;
    }
  }

  // Add a new user
  Future<void> addUser(User user) async {
    try {
      await _apiService.addUser(user.toJson());
      _users.add(user);
      notifyListeners();
    } catch (e) {
      log('Error adding user: $e', level: 1000);
      rethrow;
    }
  }
}
