import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rx_logix/services/user_service.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../models/profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc()..add(LoadProfileEvent()),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _schoolNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _standardController = TextEditingController();
  final _streamController = TextEditingController();
  final _fatherProfessionController = TextEditingController();
  final _motherProfessionController = TextEditingController();

  String _selectedSegment = 'School';
  String _selectedMedium = 'English';

  final List<String> _mediumOptions = ['English', 'English1', 'Hindi'];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = await UserService.getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        _nameController.text = user.fullName;
        _emailController.text = user.email;
        _phoneController.text = user.mobileNumber;
        _schoolNameController.text = user.schoolName;
        _standardController.text = user.standard.toString();
        _selectedMedium = user.medium;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is ProfileSavedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile saved successfully')),
            );
            Navigator.pop(context);
          } else if (state is ProfileLoadedState) {
            _populateFields(state.profile);
          }
        },
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  // title: Text(
                  //   'Profile',
                  //   style: TextStyle(
                  //     color: Theme.of(context).colorScheme.onPrimary,
                  //   ),
                  // ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                    ),
                    child: Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Text(
                          _nameController.text.isNotEmpty
                              ? _nameController.text[0].toUpperCase()
                              : 'A',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: state is ProfileLoadingState
                    ? const Center(child: CircularProgressIndicator())
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildSection(
                                'Personal Information',
                                [
                                  _buildTextField(
                                    controller: _nameController,
                                    label: 'Full Name',
                                    icon: Icons.person,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: _emailController,
                                    label: 'Email',
                                    icon: Icons.email,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: _phoneController,
                                    label: 'Mobile Number',
                                    icon: Icons.phone,
                                    keyboardType: TextInputType.phone,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _buildSection(
                                'Academic Information',
                                [
                                  _buildTextField(
                                    controller: _schoolNameController,
                                    label: 'School Name',
                                    icon: Icons.school,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildDropdown(
                                    label: 'Medium',
                                    value: _selectedMedium,
                                    items: _mediumOptions,
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedMedium = value!;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: _standardController,
                                    label: 'Standard',
                                    icon: Icons.grade,
                                    keyboardType: TextInputType.number,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _buildSection(
                                'Additional Information',
                                [
                                  _buildTextField(
                                    controller: _locationController,
                                    label: 'Location',
                                    icon: Icons.location_on,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: _fatherProfessionController,
                                    label: "Father's Profession",
                                    icon: Icons.work,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildTextField(
                                    controller: _motherProfessionController,
                                    label: "Mother's Profession",
                                    icon: Icons.work,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              ElevatedButton(
                                onPressed: () => _saveProfile(context),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Save Profile',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
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

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: items.contains(value) ? value : items[0],
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  void _populateFields(Profile profile) {
    _nameController.text = profile.fullName;
    _emailController.text = profile.email;
    _phoneController.text = profile.mobileNumber;
    _schoolNameController.text = profile.schoolName;
    _locationController.text = profile.location;
    _standardController.text = profile.standard.toString();
    _streamController.text = profile.stream;
    _fatherProfessionController.text = profile.fatherProfession;
    _motherProfessionController.text = profile.motherProfession;
    _selectedMedium = profile.medium;
    _selectedSegment = profile.segment;
  }

  void _saveProfile(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ProfileBloc>().add(
            SaveProfileEvent(
              fullName: _nameController.text,
              email: _emailController.text,
              mobileNumber: _phoneController.text,
              schoolName: _schoolNameController.text,
              location: _locationController.text,
              segment: _selectedSegment,
              standard: _standardController.text,
              stream: _streamController.text,
              medium: _selectedMedium,
              fatherProfession: _fatherProfessionController.text,
              motherProfession: _motherProfessionController.text,
            ),
          );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _schoolNameController.dispose();
    _locationController.dispose();
    _standardController.dispose();
    _streamController.dispose();
    _fatherProfessionController.dispose();
    _motherProfessionController.dispose();
    super.dispose();
  }
}
