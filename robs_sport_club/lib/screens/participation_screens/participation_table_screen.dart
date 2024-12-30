import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'edit_participation_screen.dart';

class ParticipationTableScreen extends StatefulWidget {
  const ParticipationTableScreen({Key? key}) : super(key: key);

  @override
  State<ParticipationTableScreen> createState() => _ParticipationTableScreenState();
}

class _ParticipationTableScreenState extends State<ParticipationTableScreen> {
  late Future<List<Map<String, dynamic>>> _participationsFuture;
  List<Map<String, dynamic>> _filteredData = [];
  String? _selectedCoach, _selectedLocation, _selectedTeamNo, _selectedChildName;

  @override
  void initState() {
    super.initState();
    _participationsFuture = fetchParticipations();
  }

  Future<List<Map<String, dynamic>>> fetchParticipations() async {
    try {
      final participations = await ApiService.getAllParticipations();
      return participations.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to fetch participations: $e');
    }
  }

  bool isFutureOrToday(String date) {
    final today = DateTime.now();
    final participationDate = DateTime.parse(date);
    return participationDate.isAtSameMomentAs(today) || participationDate.isAfter(today);
  }

  void _applyFilters(List<Map<String, dynamic>> data) {
    setState(() {
      _filteredData = data.where((item) {
        final matchesCoach = _selectedCoach == null || item['coach'] == _selectedCoach;
        final matchesLocation = _selectedLocation == null || item['location'] == _selectedLocation;
        final matchesTeamNo = _selectedTeamNo == null || item['teamNo'] == _selectedTeamNo;
        final matchesChildName = _selectedChildName == null || item['childName'] == _selectedChildName;
        return matchesCoach && matchesLocation && matchesTeamNo && matchesChildName;
      }).toList();
    });
  }

  void _resetFilters(List<Map<String, dynamic>> data) {
    setState(() {
      _selectedCoach = null;
      _selectedLocation = null;
      _selectedTeamNo = null;
      _selectedChildName = null;
      _filteredData = data;
    });
  }

  Widget _buildDropdown({
    required String label,
    required String field,
    required List<Map<String, dynamic>> data,
    required Function(String?) onChanged,
  }) {
    final values = data
        .map((e) => e[field] as String?)
        .where((value) => value != null)
        .toSet()
        .toList();
    values.sort();
    return DropdownButton<String>(
      hint: Text('Filter by $label'),
      value: field == 'coach'
          ? _selectedCoach
          : field == 'location'
          ? _selectedLocation
          : field == 'teamNo'
          ? _selectedTeamNo
          : _selectedChildName,
      items: values.map((value) => DropdownMenuItem(value: value, child: Text(value!))).toList(),
      onChanged: onChanged,
    );
  }

  Future<void> deleteParticipation(BuildContext context, int id, String date) async {
    if (!isFutureOrToday(date)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deleting past participation is not allowed.')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this participation?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await ApiService.deleteParticipation(id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Participation deleted successfully!')),
        );
        // Refresh the table
        setState(() {
          _participationsFuture = fetchParticipations();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete participation: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Participation Table')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _participationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No participation records found.'));
          }

          final participations = snapshot.data!;
          if (_filteredData.isEmpty) {
            _filteredData = participations;
          }

          return Column(
            children: [
              // Filters Section
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildDropdown(
                        label: 'Coach',
                        field: 'coach',
                        data: participations,
                        onChanged: (value) {
                          setState(() {
                            _selectedCoach = value;
                            _applyFilters(participations);
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildDropdown(
                        label: 'Location',
                        field: 'location',
                        data: participations,
                        onChanged: (value) {
                          setState(() {
                            _selectedLocation = value;
                            _applyFilters(participations);
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildDropdown(
                        label: 'TeamNo',
                        field: 'teamNo',
                        data: participations,
                        onChanged: (value) {
                          setState(() {
                            _selectedTeamNo = value;
                            _applyFilters(participations);
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildDropdown(
                        label: 'Child Name',
                        field: 'childName',
                        data: participations,
                        onChanged: (value) {
                          setState(() {
                            _selectedChildName = value;
                            _applyFilters(participations);
                          });
                        },
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () => _resetFilters(participations),
                        child: const Text('Reset Filters'),
                      ),
                    ],
                  ),
                ),
              ),
              // Table Section
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Child Name')),
                        DataColumn(label: Text('Type')),
                        DataColumn(label: Text('Team No')),
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Time')),
                        DataColumn(label: Text('Duration (min)')),
                        DataColumn(label: Text('Location')),
                        DataColumn(label: Text('Coach')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: _filteredData.map((participation) {
                        final isEditable = isFutureOrToday(participation['date']);
                        return DataRow(cells: [
                          DataCell(Text(participation['childName'] ?? '-')),
                          DataCell(Text(participation['participationType'] ?? '-')),
                          DataCell(Text(participation['teamNo'] ?? '-')),
                          DataCell(Text(participation['date'] ?? '-')),
                          DataCell(Text(participation['timeStart'] ?? '-')),
                          DataCell(Text(participation['duration'].toString())),
                          DataCell(Text(participation['location'] ?? '-')),
                          DataCell(Text(participation['coach'] ?? '-')),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                color: isEditable ? Colors.blue : Colors.grey,
                                onPressed: isEditable
                                    ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditParticipationScreen(
                                        participation: participation,
                                      ),
                                    ),
                                  );
                                }
                                    : null,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: isEditable ? Colors.red : Colors.grey,
                                onPressed: isEditable
                                    ? () => deleteParticipation(context, participation['id'], participation['date'])
                                    : null,
                              ),
                            ],
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
