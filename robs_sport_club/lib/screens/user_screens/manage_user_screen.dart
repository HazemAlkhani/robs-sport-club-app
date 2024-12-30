import 'package:flutter/material.dart';
import 'package:robs_sport_club/services/api_service.dart';

class ManageUserScreen extends StatefulWidget {
  final int userId; // User ID for fetching and updating details

  const ManageUserScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ManageUserScreen> createState() => _ManageUserScreenState();
}

class _ManageUserScreenState extends State<ManageUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _parentNameController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final userDetails = await ApiService.getUserById(widget.userId);
      _emailController.text = userDetails['email'] ?? '';
      _mobileController.text = userDetails['mobile'] ?? '';
      _parentNameController.text = userDetails['parentName'] ?? '';
    } catch (e) {
      _showError('Failed to fetch user details: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserDetails() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService.updateUser(
        widget.userId,
        {
          'email': _emailController.text,
          'mobile': _mobileController.text,
          'parentName': _parentNameController.text,
          if (_passwordController.text.isNotEmpty)
            'password': _passwordController.text,
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User details updated successfully!')),
      );
    } catch (e) {
      _showError('Failed to update user details: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage User'),
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
                'Update User Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Parent Name Field
              TextFormField(
                controller: _parentNameController,
                decoration: const InputDecoration(
                  labelText: 'Parent Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a parent name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
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
                decoration: const InputDecoration(
                  labelText: 'Mobile',
                  border: OutlineInputBorder(),
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
                decoration: const InputDecoration(
                  labelText: 'Password (Leave blank to keep current)',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Update Button
              ElevatedButton(
                onPressed: _isLoading ? null : _updateUserDetails,
                child: const Text('Update Details'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
