import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/language_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/firebase_service.dart';

class ProgrammesScreen extends StatefulWidget {
  const ProgrammesScreen({super.key});

  @override
  State<ProgrammesScreen> createState() => _ProgrammesScreenState();
}

class _ProgrammesScreenState extends State<ProgrammesScreen> {
  String selectedDay = 'today';
  String selectedCategory = 'all';

  List<Map<String, dynamic>> _programs = [];
  bool _isLoading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _fetchPrograms();
  }

  Future<void> _fetchPrograms() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final programModels = await FirebaseService().getPrograms(
        category: selectedCategory != 'all' ? selectedCategory : null,
        startDate: selectedDay == 'today'
            ? DateTime.now()
            : selectedDay == 'tomorrow'
                ? DateTime.now().add(const Duration(days: 1))
                : null,
        endDate: selectedDay == 'today'
            ? DateTime.now().add(const Duration(days: 1))
            : selectedDay == 'tomorrow'
                ? DateTime.now().add(const Duration(days: 2))
                : null,
      );
      final programs =
          programModels.map((p) => (p as dynamic).toJson()).toList();
      setState(() {
        _programs = List<Map<String, dynamic>>.from(programs);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement des programmes';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.read<LanguageProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, Colors.white],
            stops: [0.3, 1.0],
          ),
        ),
        child: Column(
          children: [
            // Header
            SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            languageProvider.translate('programmes'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Grille des programmes Moi Église TV',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Day selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildDayButton('today', 'Aujourd\'hui'),
                  const SizedBox(width: 8),
                  _buildDayButton('tomorrow', 'Demain'),
                  const SizedBox(width: 8),
                  _buildDayButton('week', 'Cette semaine'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Category filter
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtrer par catégorie',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCategoryChip('all', 'Tout'),
                        _buildCategoryChip('culte', 'Culte'),
                        _buildCategoryChip('enseignement', 'Enseignement'),
                        _buildCategoryChip('musique', 'Musique'),
                        _buildCategoryChip('jeunesse', 'Jeunesse'),
                        _buildCategoryChip('special', 'Spécial'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Programs list
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.accent))
                  : _error != null
                      ? Center(
                          child: Text(_error!,
                              style: const TextStyle(color: Colors.red)))
                      : _programs.isEmpty
                          ? const Center(
                              child: Text('Aucun programme disponible'))
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _programs.length,
                              itemBuilder: (context, index) {
                                final program = _programs[index];
                                return _buildProgramCard(program);
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayButton(String value, String label) {
    final isSelected = selectedDay == value;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedDay = value;
          });
          _fetchPrograms();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primary : Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String value, String label) {
    final isSelected = selectedCategory == value;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedCategory = value;
          });
          _fetchPrograms();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgramCard(Map<String, dynamic> program) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${program['startTime']} - ${program['endTime']}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                if (program['isLive'] == true)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              program['title'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              program['description'],
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // Toggle notification
                  },
                  icon: const Icon(Icons.notifications_outlined, size: 16),
                  label: const Text('Me rappeler'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
                const SizedBox(width: 8),
                if (program['isLive'] == true)
                  ElevatedButton.icon(
                    onPressed: () {
                      // Watch now
                    },
                    icon: const Icon(Icons.tv, size: 16),
                    label: const Text('Regarder'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
