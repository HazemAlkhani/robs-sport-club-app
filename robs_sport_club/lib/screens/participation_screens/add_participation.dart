import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/multi_select_dropdown.dart';

class AddParticipationScreen extends StatefulWidget {
  const AddParticipationScreen({Key? key}) : super(key: key);

  @override
  AddParticipationScreenState createState() => AddParticipationScreenState();
}

class AddParticipationScreenState extends State<AddParticipationScreen> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  String? selectedSportType;
  String? selectedTeam;
  String? participationType;
  List<String> childNames = [];
  List<String> selectedChildren = [];
  bool isLoading = false;

  Future<void> fetchChildren() async {
    if (selectedSportType == null || selectedTeam == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select sport type and team first.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final children = await ApiService.getChildrenByTeamAndSport(
        selectedTeam!,
        selectedSportType!,
      );
      setState(() {
        childNames = children.map<String>((child) => child['ChildName'].toString()).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching children: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> submitParticipation() async {
    if (selectedChildren.isEmpty ||
        dateController.text.isEmpty ||
        timeController.text.isEmpty ||
        durationController.text.isEmpty ||
        locationController.text.isEmpty ||
        participationType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required.')),
      );
      return;
    }

    final duration = int.tryParse(durationController.text);
    if (duration == null || duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Duration must be a positive integer.')),
      );
      return;
    }

    final dateRegExp = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    final timeRegExp = RegExp(r'^\d{2}:\d{2}$');

    if (!dateRegExp.hasMatch(dateController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid date format. Use YYYY-MM-DD.')),
      );
      return;
    }

    if (!timeRegExp.hasMatch(timeController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid time format. Use HH:MM.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      for (var child in selectedChildren) {
        final data = {
          'ChildName': child,
          'ParticipationType': participationType,
          'Date': dateController.text,
          'TimeStart': timeController.text,
          'Duration': duration,
          'Location': locationController.text,
        };

        await ApiService.addParticipation(data);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Participation added successfully')),
      );
      Navigator.pop(context); // Navigate back after success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add participation: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Participation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDropdown(
              label: 'Sport Type',
              value: selectedSportType,
              items: ["Football", "Handball", "Basketball", "Gymnastic"],
              onChanged: (value) {
                setState(() {
                  selectedSportType = value;
                  selectedTeam = null;
                  childNames = [];
                  selectedChildren = [];
                });
              },
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Team',
              value: selectedTeam,
              items: ["U5", "U6", "U7", "U8", "U9", "U10", "U11", "U12", "U13", "U14", "U15"],
              onChanged: (value) {
                setState(() {
                  selectedTeam = value;
                  fetchChildren();
                });
              },
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Participation Type',
              value: participationType,
              items: ["Match", "Training"],
              onChanged: (value) {
                setState(() {
                  participationType = value;
                });
              },
            ),
            const SizedBox(height: 16),
            MultiSelectDropdown(
              items: childNames,
              onSelectionChanged: (selected) {
                setState(() {
                  selectedChildren = selected;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(controller: dateController, label: 'Date', isDate: true),
            const SizedBox(height: 16),
            _buildTextField(controller: timeController, label: 'Start Time (HH:mm)'),
            const SizedBox(height: 16),
            _buildTextField(
              controller: durationController,
              label: 'Duration (minutes)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildTextField(controller: locationController, label: 'Location'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: submitParticipation,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Submit Participation'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool isDate = false,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      keyboardType: keyboardType,
      readOnly: isDate,
      onTap: isDate
          ? () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (pickedDate != null) {
          controller.text = pickedDate.toIso8601String().split('T').first;
        }
      }
          : null,
    );
  }
}
