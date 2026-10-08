import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../dashboard/main_scaffold.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _institutionController = TextEditingController();

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

  Future<void> _submit(bool isLogin) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final userProvider = context.read<UserProvider>();
      bool success = false;

      if (isLogin) {
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

        success = await userProvider.register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          institution: _institutionController.text.trim(),
          role: _selectedRole!,
          location: _selectedLocation,
        );
      }

      setState(() => _isLoading = false);

      if (success) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScaffold()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isLogin 
              ? 'Login failed. Check credentials or server.' 
              : 'Registration failed. Email might exist.')
          ),
        );
      }
    }
  }

  void _continueAsDemo() {
    context.read<UserProvider>().updateProfile(
      name: 'Demo Student',
      institution: 'Munnarivu Academy',
      role: 'School Student',
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

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: const InputDecoration(
        labelText: 'Email Address',
        prefixIcon: Icon(Icons.email),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) => value == null || value.isEmpty ? 'Please enter your email' : null,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: const InputDecoration(
        labelText: 'Password',
        prefixIcon: Icon(Icons.lock),
        border: OutlineInputBorder(),
      ),
      obscureText: true,
      validator: (value) => value == null || value.isEmpty ? 'Please enter a password' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome to Munnarivu'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: "Login"),
              Tab(text: "Register"),
            ],
          ),
        ),
        body: Form(
          key: _formKey,
          child: TabBarView(
            children: [
              // LOGIN TAB
              SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    _buildEmailField(),
                    const SizedBox(height: 16),
                    _buildPasswordField(),
                    const SizedBox(height: 32),
                    FilledButton(
                      onPressed: _isLoading ? null : () => _submit(true),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white) 
                          : const Text('Login'),
                    ),
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: _continueAsDemo,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Quick Demo Login (Student - Coimbatore)'),
                    ),
                  ],
                ),
              ),

              // REGISTER TAB
              SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
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
                    _buildEmailField(),
                    const SizedBox(height: 16),
                    _buildPasswordField(),
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
                    Text('I am a:', style: Theme.of(context).textTheme.titleMedium),
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
                    const SizedBox(height: 32),
                    FilledButton(
                      onPressed: _isLoading ? null : () => _submit(false),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white) 
                          : const Text('Create Account'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
