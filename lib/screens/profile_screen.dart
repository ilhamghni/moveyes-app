import 'package:flutter/material.dart';
import '../models/profile.dart';
import '../services/profile_service.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();
  Profile? _profile;
  bool _isLoading = true;
  String? _errorMessage;
  
  // Text editing controllers for the update form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _hobbiesController = TextEditingController();
  final TextEditingController _avatarUrlController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _letterboxdController = TextEditingController();
  
  // Store ScaffoldMessengerState to safely show snackbars
  late ScaffoldMessengerState _scaffoldMessenger;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Store ScaffoldMessengerState for safe access later
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _nicknameController.dispose();
    _hobbiesController.dispose();
    _avatarUrlController.dispose();
    _twitterController.dispose();
    _instagramController.dispose();
    _letterboxdController.dispose();
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
      if (mounted) {
        setState(() {
          _profile = profile;
          _nameController.text = profile.user.name;
          _bioController.text = profile.bio;
          _nicknameController.text = profile.nickname ?? '';
          _hobbiesController.text = profile.hobbies ?? '';
          _avatarUrlController.text = profile.avatarUrl ?? '';
          
          // Set social media controllers
          if (profile.socialMedia != null) {
            _twitterController.text = profile.socialMedia!['twitter'] ?? '';
            _instagramController.text = profile.socialMedia!['instagram'] ?? '';
            _letterboxdController.text = profile.socialMedia!['letterboxd'] ?? '';
          }
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // Update profile
  Future<void> _updateProfile() async {
    // Create a local reference to the scaffold messenger
    final messenger = _scaffoldMessenger;
    
    // Show a dialog to edit profile details
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF211F30),
        title: const Text('Update Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: 'Nickname',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _hobbiesController,
                decoration: const InputDecoration(
                  labelText: 'Hobbies',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _avatarUrlController,
                decoration: const InputDecoration(
                  labelText: 'Avatar URL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white24),
              const Text('Social Media', 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _twitterController,
                decoration: const InputDecoration(
                  labelText: 'Twitter',
                  prefixText: '@',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _instagramController,
                decoration: const InputDecoration(
                  labelText: 'Instagram',
                  prefixText: '@',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _letterboxdController,
                decoration: const InputDecoration(
                  labelText: 'Letterboxd',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () async {
              // Close the dialog first
              Navigator.pop(dialogContext);
              
              // Show loading indicator
              if (mounted) {
                setState(() => _isLoading = true);
              }
              
              try {
                // Create social media map
                final socialMedia = {
                  'twitter': _twitterController.text.isEmpty ? null : _twitterController.text,
                  'instagram': _instagramController.text.isEmpty ? null : _instagramController.text,
                  'letterboxd': _letterboxdController.text.isEmpty ? null : _letterboxdController.text,
                };
                
                // Remove null values
                socialMedia.removeWhere((key, value) => value == null);
                
                // Update profile with the service
                final updatedProfile = await _profileService.updateProfile(
                  name: _nameController.text,
                  bio: _bioController.text,
                  nickname: _nicknameController.text.isNotEmpty ? _nicknameController.text : null,
                  hobbies: _hobbiesController.text.isNotEmpty ? _hobbiesController.text : null,
                  avatarUrl: _avatarUrlController.text.isNotEmpty ? _avatarUrlController.text : null,
                  socialMedia: socialMedia.isNotEmpty ? socialMedia : null,
                );
                
                // Update UI if widget is still mounted
                if (mounted) {
                  setState(() {
                    _profile = updatedProfile;
                    _isLoading = false;
                  });
                  
                  // Use the stored messenger instead of ScaffoldMessenger.of(context)
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                // Handle errors and update UI if still mounted
                final errorMessage = e.toString();
                
                if (mounted) {
                  setState(() {
                    _errorMessage = errorMessage;
                    _isLoading = false;
                  });
                  
                  // Use the stored messenger
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Error updating profile: $errorMessage'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE21221),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Logout function
  Future<void> _logout() async {
    try {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      _scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error logging out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF15141F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF15141F),
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
      floatingActionButton: _isLoading || _profile == null ? null : FloatingActionButton(
        onPressed: _updateProfile,
        backgroundColor: const Color(0xFFE21221),
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFE21221)));
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: $_errorMessage',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade400),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE21221),
                foregroundColor: Colors.white,
              ),
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
                // Avatar display
                if (_profile!.avatarUrl != null && _profile!.avatarUrl!.isNotEmpty)
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(_profile!.avatarUrl!),
                    backgroundColor: const Color(0xFF211F30),
                    onBackgroundImageError: (_, __) {
                      // Fallback when image loading fails
                    },
                    child: (_profile!.avatarUrl == null || _profile!.avatarUrl!.isEmpty) 
                      ? Text(
                          _profile!.user.name.isNotEmpty ? _profile!.user.name[0].toUpperCase() : '?',
                          style: const TextStyle(fontSize: 40, color: Colors.white),
                        ) 
                      : null,
                  )
                else
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFFE21221),
                    child: Text(
                      _profile!.user.name.isNotEmpty ? _profile!.user.name[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 40, color: Colors.white),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  _profile!.user.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_profile!.nickname != null && _profile!.nickname!.isNotEmpty)
                  Text(
                    _profile!.nickname!,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                Text(
                  _profile!.user.email,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white24),
          
          // Profile details
          ListTile(
            title: const Text('User ID'),
            subtitle: Text(_profile!.userId.toString()),
            leading: const Icon(Icons.fingerprint, color: Color(0xFFE21221)),
          ),
          
          ListTile(
            title: const Text('Bio'),
            subtitle: Text(_profile!.bio.isNotEmpty ? _profile!.bio : 'No bio added yet'),
            leading: const Icon(Icons.info_outline, color: Color(0xFFE21221)),
          ),
          
          // Only show hobbies if available
          if (_profile!.hobbies != null && _profile!.hobbies!.isNotEmpty)
            ListTile(
              title: const Text('Hobbies'),
              subtitle: Text(_profile!.hobbies!),
              leading: const Icon(Icons.interests, color: Color(0xFFE21221)),
            ),
          
          // Social media section
          if (_profile!.socialMedia != null && _profile!.socialMedia!.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Social Media',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Twitter
            if (_profile!.socialMedia!['twitter'] != null)
              ListTile(
                title: const Text('Twitter'),
                subtitle: Text(_profile!.socialMedia!['twitter']),
                leading: const Icon(Icons.alternate_email, color: Color(0xFF1DA1F2)),
              ),
              
            // Instagram
            if (_profile!.socialMedia!['instagram'] != null)
              ListTile(
                title: const Text('Instagram'),
                subtitle: Text(_profile!.socialMedia!['instagram']),
                leading: const Icon(Icons.camera_alt, color: Color(0xFFE1306C)),
              ),
              
            // Letterboxd
            if (_profile!.socialMedia!['letterboxd'] != null)
              ListTile(
                title: const Text('Letterboxd'),
                subtitle: Text(_profile!.socialMedia!['letterboxd']),
                leading: const Icon(Icons.movie_filter, color: Color(0xFF00E054)),
              ),
          ],
          
          const SizedBox(height: 20),
          const Divider(color: Colors.white24),
          
          // Additional options
          ListTile(
            title: const Text('My Favorites'),
            leading: const Icon(Icons.favorite, color: Color(0xFFE21221)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).pushNamed('/favorites'),
          ),
          
          ListTile(
            title: const Text('Edit Profile'),
            leading: const Icon(Icons.edit, color: Color(0xFFE21221)),
            trailing: const Icon(Icons.chevron_right),
            onTap: _updateProfile,
          ),
          
          const SizedBox(height: 20),
          const Divider(color: Colors.white24),
          
          // Logout button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
