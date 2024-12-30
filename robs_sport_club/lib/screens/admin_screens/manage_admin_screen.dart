import 'package:flutter/material.dart';
import 'package:robs_sport_club/services/api_service.dart';

class ManageAdminScreen extends StatefulWidget {
  final int adminId; // Admin ID for fetching and updating details

  const ManageAdminScreen({Key? key, required this.adminId}) : super(key: key);

  @override
  State<ManageAdminScreen> createState() => _ManageAdminScreenState();
}

class _ManageAdminScreenState extends State<ManageAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAdminDetails();
  }

  Future<void> _fetchAdminDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final adminDetails = await ApiService.getAdminDetails(widget.adminId);
      _emailController.text = adminDetails['email'] ?? '';
      _mobileController.text = adminDetails['mobile'] ?? '';
    } catch (e) {
      _showError('Failed to fetch admin details: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateAdminDetails() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService.updateAdminDetails(
        adminId: widget.adminId,
        email: _emailController.text,
        mobile: _mobileController.text,
        password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
      );
      _showMessage('Admin details updated successfully!');
    } catch (e) {
      _showError('Failed to update admin details: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Admin'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Update Admin Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Mobile Field
              TextFormField(
                controller: _mobileController,
                decoration: InputDecoration(
                  labelText: 'Mobile',
                  border: OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a mobile number';
                  }
                  if (!RegExp(r'^\+?\d{10,15}$').hasMatch(value)) {
                    return 'Please enter a valid mobile number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Password Field
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password (Leave blank to keep current)',
                  border: OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Update Button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _updateAdminDetails,
                icon: const Icon(Icons.update),
                label: const Text('Update Details'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
