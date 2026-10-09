import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../dashboard/main_scaffold.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _institutionController = TextEditingController();
  
  bool _isLogin = false;
  bool _isLoading = false;
  String? _selectedRole;
  String _selectedLocation = 'Coimbatore'; // Default

  final List<String> _roles = [
    'School Student',
    'College Student',
    'Teaching Staff',
    'Non-Teaching Staff'
  ];

  final List<String> _locations = [
    'Coimbatore',
    'Chennai',
    'Nilgiris',
    'Madurai',
    'Tiruchirappalli',
    'Salem',
    'Kanyakumari'
  ];

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final userProvider = context.read<UserProvider>();
      bool success = false;

      Map<String, dynamic>? registerResult;
      if (_isLogin) {
        success = await userProvider.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        if (_selectedRole == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a role')),
          );
          setState(() => _isLoading = false);
          return;
        }

        registerResult = await userProvider.register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          institution: _institutionController.text.trim(),
          role: _selectedRole!,
          location: _selectedLocation,
        );
      }

      setState(() => _isLoading = false);

      if (_isLogin) {
        if (success) {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainScaffold()),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login failed. Check credentials.')),
          );
        }
      } else {
        if (registerResult != null && registerResult['success'] == true) {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const MainScaffold()),
          );
        } else {
          if (!mounted) return;
          String errorMsg = registerResult != null ? (registerResult['message'] ?? 'Registration failed.') : 'Registration failed.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg)),
          );
        }
      }
    }
  }

  void _continueAsDemo() {
    context.read<UserProvider>().updateProfile(
      name: 'Demo Student',
      institution: 'Munnarivu Academy',
      role: 'Student',
      location: 'Coimbatore',
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScaffold()),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _institutionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Create Account'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Welcome to Munnarivu!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _isLogin ? 'Please sign in to continue.' : 'Let\'s personalize your disaster awareness journey.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value == null || value.isEmpty ? 'Please enter your email' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) => value == null || value.isEmpty ? 'Please enter a password' : null,
              ),
              const SizedBox(height: 16),

              if (!_isLogin) ...[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Your Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _institutionController,
                  decoration: const InputDecoration(
                    labelText: 'Institution Name',
                    prefixIcon: Icon(Icons.school),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter institution name' : null,
                ),
                const SizedBox(height: 24),

                Text(
                  'I am a:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _roles.map((role) {
                    return ChoiceChip(
                      label: Text(role),
                      selected: _selectedRole == role,
                      onSelected: (selected) {
                        setState(() {
                          _selectedRole = selected ? role : null;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                DropdownButtonFormField<String>(
                  initialValue: _selectedLocation,
                  decoration: const InputDecoration(
                    labelText: 'Location / District',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                  items: _locations.map((String location) {
                    return DropdownMenuItem<String>(
                      value: location,
                      child: Text(location),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      if (newValue != null) {
                        _selectedLocation = newValue;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),

                Card(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: Theme.of(context).colorScheme.onSecondaryContainer),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Your location helps Munnarivu highlight disaster topics relevant to your region.",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              FilledButton(
                onPressed: _isLoading ? null : _submit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : Text(_isLogin ? 'Login to Account' : 'Start Learning'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(_isLogin ? 'New User? Create an Account' : 'Already have an account? Login'),
              ),
              const Divider(),
              OutlinedButton(
                onPressed: _continueAsDemo,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Continue as Demo Student (Offline Mode)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
