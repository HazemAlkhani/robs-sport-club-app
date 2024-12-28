import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class EditChildScreen extends StatefulWidget {
  final int userId; // Logged-in user's ID
  final int childId; // Child's ID to edit

  const EditChildScreen({Key? key, required this.userId, required this.childId})
      : super(key: key);

  @override
  _EditChildScreenState createState() => _EditChildScreenState();
}

class _EditChildScreenState extends State<EditChildScreen> {
  final TextEditingController childNameController = TextEditingController();
  String? selectedTeam;
  String? selectedSportType;

  final List<String> teams = ["U5", "U6", "U7", "U8", "U9", "U10", "U11", "U12", "U13", "U14", "U15"];
  final List<String> sportTypes = ["Football", "Handball", "Basketball", "Gymnastic"];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchChildDetails();
  }

  Future<void> fetchChildDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      final children = await ApiService.getChildrenByUser(widget.userId);
      final childDetails =
      children.firstWhere((child) => child['id'] == widget.childId, orElse: () => null);

      if (childDetails == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Child not found or not owned by you')),
        );
        Navigator.pop(context); // Go back if the child doesn't belong to the user
        return;
      }

      childNameController.text = childDetails['childName'];
      selectedTeam = childDetails['teamNo'];
      selectedSportType = childDetails['sportType'];
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch child details: $error')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveChanges() async {
    if (childNameController.text.isEmpty || selectedTeam == null || selectedSportType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final updatedData = {
        'ChildId': widget.childId,
        'ChildName': childNameController.text.trim(),
        'TeamNo': selectedTeam!,
        'SportType': selectedSportType!,
      };

      await ApiService.updateChild(updatedData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Child details updated successfully')),
      );
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update child details: $error')),
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
      appBar: AppBar(title: const Text('Edit Child')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: childNameController,
              decoration: const InputDecoration(labelText: 'Child Name'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedTeam,
              onChanged: (value) {
                setState(() {
                  selectedTeam = value;
                });
              },
              items: teams
                  .map((team) => DropdownMenuItem(
                value: team,
                child: Text(team),
              ))
                  .toList(),
              decoration: const InputDecoration(labelText: 'Select Team'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedSportType,
              onChanged: (value) {
                setState(() {
                  selectedSportType = value;
                });
              },
              items: sportTypes
                  .map((sport) => DropdownMenuItem(
                value: sport,
                child: Text(sport),
              ))
                  .toList(),
              decoration: const InputDecoration(labelText: 'Select Sport Type'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: saveChanges,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
