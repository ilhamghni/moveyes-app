import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  Profile? _profile;
  bool _isLoading = true;
  String? _errorMessage;
  
  // Text editing controllers for the update form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // Load profile data
  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await _profileService.getProfile();
      setState(() {
        _profile = profile;
        _nameController.text = profile.user.name;
        _bioController.text = profile.bio;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Update profile
  Future<void> _updateProfile() async {
    // Show a dialog to edit profile details
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
            ),
            TextField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              
              try {
                final updatedProfile = await _profileService.updateProfile(
                  name: _nameController.text,
                  bio: _bioController.text,
                );
                
                setState(() {
                  _profile = updatedProfile;
                  _isLoading = false;
                });
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated successfully')),
                  );
                }
              } catch (e) {
                setState(() {
                  _errorMessage = e.toString();
                  _isLoading = false;
                });
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating profile: $_errorMessage')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: _buildBody(),
      floatingActionButton: _isLoading || _profile == null ? null : FloatingActionButton(
        onPressed: _updateProfile,
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: $_errorMessage',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProfile,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
    
    if (_profile == null) {
      return const Center(child: Text('No profile data available'));
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    _profile!.user.name.isNotEmpty ? _profile!.user.name[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 40, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _profile!.user.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  _profile!.user.email,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          
          // Profile details
          ListTile(
            title: const Text('User ID'),
            subtitle: Text(_profile!.userId.toString()),
            leading: const Icon(Icons.fingerprint),
          ),
          ListTile(
            title: const Text('Bio'),
            subtitle: Text(_profile!.bio.isNotEmpty ? _profile!.bio : 'No bio added yet'),
            leading: const Icon(Icons.info_outline),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
