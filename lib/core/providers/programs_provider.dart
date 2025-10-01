import 'package:flutter/material.dart';

import '../models/program_model.dart';
import '../services/firebase_service.dart';

class ProgramsProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  
  List<ProgramModel> _programs = [];
  List<ProgramModel> _todayPrograms = [];
  ProgramModel? _currentLiveProgram;
  String _selectedCategory = 'all';
  String _selectedDay = 'today';
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ProgramModel> get programs => _programs;
  List<ProgramModel> get todayPrograms => _todayPrograms;
  List<ProgramModel> get filteredPrograms {
    List<ProgramModel> filtered = _selectedDay == 'today' ? _todayPrograms : _programs;
    
    if (_selectedCategory != 'all') {
      filtered = filtered.where((program) => 
          program.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
    }
    
    return filtered;
  }
  
  ProgramModel? get currentLiveProgram => _currentLiveProgram;
  String get selectedCategory => _selectedCategory;
  String get selectedDay => _selectedDay;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Category filtering
  void setCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners();
    }
  }

  // Day filtering
  void setDay(String day) {
    if (_selectedDay != day) {
      _selectedDay = day;
      notifyListeners();
      _loadProgramsForDay(day);
    }
  }

  // Load programs
  Future<void> loadPrograms() async {
    _setLoading(true);
    _clearError();

    try {
      // Load today's programs
      await loadTodayPrograms();
      
      // Load current live program
      await loadCurrentLiveProgram();
      
    } catch (e) {
      _setError('Erreur lors du chargement des programmes: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadTodayPrograms() async {
    try {
      _todayPrograms = await _firebaseService.getTodayPrograms();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading today programs: $e');
      _setError('Erreur lors du chargement des programmes du jour');
    }
  }

  Future<void> loadCurrentLiveProgram() async {
    try {
      _currentLiveProgram = await _firebaseService.getCurrentLiveProgram();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading current live program: $e');
    }
  }

  Future<void> _loadProgramsForDay(String day) async {
    _setLoading(true);
    _clearError();

    try {
      DateTime? startDate;
      DateTime? endDate;
      
      final now = DateTime.now();
      
      switch (day) {
        case 'today':
          startDate = DateTime(now.year, now.month, now.day);
          endDate = startDate.add(const Duration(days: 1));
          break;
        case 'tomorrow':
          startDate = DateTime(now.year, now.month, now.day + 1);
          endDate = startDate.add(const Duration(days: 1));
          break;
        case 'week':
          startDate = DateTime(now.year, now.month, now.day);
          endDate = startDate.add(const Duration(days: 7));
          break;
      }

      if (startDate != null && endDate != null) {
        _programs = await _firebaseService.getPrograms(
          startDate: startDate,
          endDate: endDate,
        );
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement des programmes: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Program reminders
  Future<void> toggleReminder(String programId) async {
    try {
      // This would integrate with local notifications and Firebase
      // For now, just track the action
      await _firebaseService.trackEvent('program_reminder_toggle', {
        'program_id': programId,
      });
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling reminder: $e');
    }
  }

  // Watch live program
  Future<void> watchLiveProgram(String programId) async {
    try {
      await _firebaseService.trackEvent('live_program_watch', {
        'program_id': programId,
      });
    } catch (e) {
      debugPrint('Error tracking live program watch: $e');
    }
  }

  // Real-time updates
  void startListeningToTodayPrograms() {
    _firebaseService.watchTodayPrograms().listen(
      (programs) {
        _todayPrograms = programs;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('Error listening to today programs: $error');
      },
    );
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // Get programs by category
  List<ProgramModel> getProgramsByCategory(String category) {
    if (category == 'all') return _programs;
    return _programs.where((program) => 
        program.category.toLowerCase() == category.toLowerCase()).toList();
  }

  // Get live programs
  List<ProgramModel> get livePrograms {
    return _programs.where((program) => program.isCurrentlyLive).toList();
  }

  // Get upcoming programs (next 3 hours)
  List<ProgramModel> get upcomingPrograms {
    final now = DateTime.now();
    final threeHoursLater = now.add(const Duration(hours: 3));
    
    return _programs.where((program) => 
        program.startTime.isAfter(now) && 
        program.startTime.isBefore(threeHoursLater)
    ).toList();
  }

  // Categories
  static const List<Map<String, String>> categories = [
    {'id': 'all', 'name': 'Tout'},
    {'id': 'culte', 'name': 'Culte'},
    {'id': 'enseignement', 'name': 'Enseignement'},
    {'id': 'musique', 'name': 'Musique'},
    {'id': 'jeunesse', 'name': 'Jeunesse'},
    {'id': 'special', 'name': 'Spécial'},
  ];

  static const List<Map<String, String>> days = [
    {'id': 'today', 'name': 'Aujourd\'hui'},
    {'id': 'tomorrow', 'name': 'Demain'},
    {'id': 'week', 'name': 'Cette semaine'},
  ];
}