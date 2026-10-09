import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/learning_progress_provider.dart';
import '../../providers/achievement_provider.dart';
import '../dashboard/main_scaffold.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  final _loginKey = GlobalKey<FormState>();
  final _registerKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  final TextEditingController _registerPasswordController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  final TextEditingController _institutionController = TextEditingController();

  bool _isLoading = false;
  bool _isLogin = true; // Toggle between login and register
  bool _obscurePassword = true;
  bool _obscureConfirmPass = true;
  bool _acceptTerms = false;
  String? _selectedRole;
  String _selectedLocation = 'Coimbatore';

  final List<String> _roles = [
    'School Student',
    'College Student',
    'Teaching Staff',
    'Non-Teaching Staff'
  ];

  final List<String> _locations = [
    'Coimbatore', 'Chennai', 'Nilgiris', 'Madurai', 'Tiruchirappalli', 'Salem', 'Kanyakumari'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _loginPasswordController.dispose();
    _registerPasswordController.dispose();
    _confirmPassController.dispose();
    _institutionController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (!_loginKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    final userProvider = context.read<UserProvider>();
    bool success = await userProvider.login(
      _emailController.text.trim(),
      _loginPasswordController.text,
    );
    _loginPasswordController.clear(); // Explicitly erase temp plain-text password from memory immediately!
    setState(() => _isLoading = false);

    if (success) {
      if (!mounted) return;
      
      // Actively pull the logged-in user's exact progress from the backend before displaying Dashboard
      if (userProvider.userId != null) {
        await context.read<LearningProgressProvider>().syncProgress(userProvider.userId!);
        await context.read<AchievementProvider>().fetchAchievements(userProvider.userId!);
      }
      
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScaffold()),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed. Please check your credentials.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _submitRegister() async {
    if (!_registerKey.currentState!.validate()) return;
    
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must accept the Terms and Conditions to register.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a role.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final userProvider = context.read<UserProvider>();
    final result = await userProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _registerPasswordController.text,
      institution: _institutionController.text.trim(),
      role: _selectedRole!,
      location: _selectedLocation,
    );
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account created successfully. Please log in.'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      
      final safeEmail = _emailController.text.trim();
      final safePassword = _registerPasswordController.text;
      
      setState(() {
        _isLogin = true;
        _nameController.clear();
        _confirmPassController.clear();
        _institutionController.clear();
        _selectedRole = null;
        
        _emailController.text = safeEmail;
        _loginPasswordController.text = safePassword;
        _registerPasswordController.clear();
      });
      // Do not navigate automatically to Dashboard; wait for explicit login.
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Registration failed.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= 6; 
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    Iterable<String>? autofillHints,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && obscureText,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      enableSuggestions: false,
      autocorrect: false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF00695C)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00695C), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
      ),
      validator: validator,
    );
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF8), 
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF004D40).withValues(alpha: 0.1),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              padding: const EdgeInsets.all(32.0),
              child: AutofillGroup(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isLogin ? _buildLoginForm() : _buildRegisterForm(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoHeader(String title, String subtitle) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFFE0F2F1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.shield, size: 64, color: Color(0xFF00695C)),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF004D40),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  void _formKeyResetAndClear(GlobalKey<FormState> key) {
     key.currentState?.reset();
     _nameController.clear();
     _emailController.clear();
     _loginPasswordController.clear();
     _registerPasswordController.clear();
     _confirmPassController.clear();
     _institutionController.clear();
  }

  Widget _buildLoginForm() {
    return Form(
      key: _loginKey,
      child: Column(
        key: const ValueKey('login'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLogoHeader('Welcome Back', 'Access your learning dashboard.'),
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email, AutofillHints.username],
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter your email';
              if (!_isValidEmail(v.trim())) return 'Please enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _loginPasswordController,
            label: 'Password',
            icon: Icons.lock_outline,
            isPassword: true,
            obscureText: _obscurePassword,
            autofillHints: const [AutofillHints.password],
            onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
            validator: (v) => v == null || v.isEmpty ? 'Please enter your password' : null,
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _isLoading ? null : _submitLogin,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF00695C),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Don't have an account?", style: TextStyle(color: Colors.grey.shade700)),
              TextButton(
                onPressed: () => setState(() {
                  _isLogin = false;
                  _formKeyResetAndClear(_registerKey);
                }),
                child: const Text('Join Munnarivu', style: TextStyle(color: Color(0xFF00695C), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(height: 32),
          OutlinedButton(
            onPressed: _continueAsDemo,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Quick Demo Login (Student)'),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      key: _registerKey,
      child: Column(
        key: const ValueKey('register'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLogoHeader('Join Munnarivu', 'Learn, prepare, and stay safe.'),
          _buildTextField(
            controller: _nameController,
            label: 'Full Name',
            icon: Icons.person_outline,
            validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your full name' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email, AutofillHints.newUsername],
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter your email';
              if (!_isValidEmail(v.trim())) return 'Please enter a valid email format';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _registerPasswordController,
            label: 'Password (Min 6 chars)',
            icon: Icons.lock_outline,
            isPassword: true,
            obscureText: _obscurePassword,
            autofillHints: const [AutofillHints.newPassword],
            onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter a password';
              if (!_isValidPassword(v)) return 'Password must be at least 6 characters';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _confirmPassController,
            label: 'Confirm Password',
            icon: Icons.lock_reset,
            isPassword: true,
            obscureText: _obscureConfirmPass,
            autofillHints: const [AutofillHints.newPassword],
            onToggleVisibility: () => setState(() => _obscureConfirmPass = !_obscureConfirmPass),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please confirm your password';
              if (v != _registerPasswordController.text) return 'Passwords do not match';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _institutionController,
            label: 'Institution Name',
            icon: Icons.school_outlined,
            validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your institution name' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedLocation,
            decoration: InputDecoration(
              labelText: 'Location / District',
              prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF00695C)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00695C), width: 2)),
              filled: true,
              fillColor: Colors.white,
            ),
            items: _locations.map((String location) {
              return DropdownMenuItem<String>(
                value: location,
                child: Text(location),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() => _selectedLocation = newValue);
              }
            },
          ),
          const SizedBox(height: 24),
          const Text('I am a:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF004D40))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _roles.map((role) {
              final isSelected = _selectedRole == role;
              return FilterChip(
                label: Text(role),
                selected: isSelected,
                selectedColor: const Color(0xFFB2DFDB),
                checkmarkColor: const Color(0xFF00695C),
                labelStyle: TextStyle(color: isSelected ? const Color(0xFF00695C) : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                onSelected: (selected) => setState(() => _selectedRole = selected ? role : null),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                value: _acceptTerms,
                activeColor: const Color(0xFF00695C),
                onChanged: (val) => setState(() => _acceptTerms = val ?? false),
              ),
              Expanded(
                child: Text(
                  'I agree to the Terms and Conditions of joining Munnarivu.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isLoading ? null : _submitRegister,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF00695C),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Already joined?", style: TextStyle(color: Colors.grey.shade700)),
              TextButton(
                onPressed: () => setState(() {
                  _isLogin = true;
                  _formKeyResetAndClear(_loginKey);
                }),
                child: const Text('Back to Login', style: TextStyle(color: Color(0xFF00695C), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
