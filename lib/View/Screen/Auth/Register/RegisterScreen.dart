import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Controllers
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _userNameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nationalityNoCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  // State variables
  bool _isActive = true;
  int _gender = 0; // 0 = Male, 1 = Female
  int _roleId = 0;
  int _nationalityCountryId = 0;
  bool _obscurePassword = true;
  int _currentStep = 0;
  File? _profileImage;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Colors
  static const Color _primary = Color(0xFF0F3460);
  static const Color _secondary = Color(0xFF16213E);
  static const Color _accent = Color(0xFF533483);
  static const Color _gold = Color(0xFFE94560);
  static const Color _cardBg = Color(0xFF1A1A2E);
  static const Color _inputBg = Color(0xFF16213E);
  static const Color _white = Colors.white;
  static const Color _textLight = Color(0xFFB0BEC5);

  final List<String> _countries = [
    'Saudi Arabia',
    'Egypt',
    'UAE',
    'Kuwait',
    'Jordan',
    'Lebanon',
    'Iraq',
    'Syria',
    'Other',
  ];

  final List<String> _roles = ['User', 'Admin', 'Moderator', 'Editor'];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _profileImage = File(picked.path));
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      _slideController.reset();
      setState(() => _currentStep++);
      _slideController.forward();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _slideController.reset();
      setState(() => _currentStep--);
      _slideController.forward();
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final data = {
        "firstName": _firstNameCtrl.text,
        "lastName": _lastNameCtrl.text,
        "email": _emailCtrl.text,
        "userName": _userNameCtrl.text,
        "password": _passwordCtrl.text,
        "isActive": _isActive,
        "nationalityNo": _nationalityNoCtrl.text,
        "roleId": _roleId,
        "phoneNumber": int.tryParse(_phoneCtrl.text) ?? 0,
        "age": int.tryParse(_ageCtrl.text) ?? 0,
        "address": _addressCtrl.text,
        "gender": _gender,
        "nationalityCountryId": _nationalityCountryId,
        "imagePath": _profileImage?.path ?? "",
        "note": _noteCtrl.text,
      };
      // TODO: Send data to API
      debugPrint(data.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Registration Successful! 🎉'),
          backgroundColor: _accent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cardBg,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // Background decoration
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [_accent.withOpacity(0.3), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -60,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [_gold.withOpacity(0.2), Colors.transparent],
                  ),
                ),
              ),
            ),

            // Main Content
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildStepIndicator(),
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildCurrentStep(),
                      ),
                    ),
                  ),
                  _buildNavigationButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        children: [
          // Profile Image
          GestureDetector(
            onTap: _pickImage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [_accent, _gold],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _accent.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: _profileImage != null
                  ? ClipOval(
                      child: Image.file(_profileImage!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_rounded,
                          color: _white,
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Upload',
                          style: TextStyle(
                            color: _white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [_white, _textLight],
            ).createShader(bounds),
            child: const Text(
              'Create Account',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Fill in your details to get started',
            style: TextStyle(color: _textLight, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Personal', 'Account', 'Details'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: isActive || isDone
                              ? LinearGradient(colors: [_gold, _accent])
                              : null,
                          color: isActive || isDone ? null : _inputBg,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        steps[i],
                        style: TextStyle(
                          color: isActive ? _white : _textLight,
                          fontSize: 11,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < steps.length - 1) const SizedBox(width: 8),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildPersonalStep();
      case 1:
        return _buildAccountStep();
      case 2:
        return _buildDetailsStep();
      default:
        return const SizedBox();
    }
  }

  // ─── STEP 1: Personal Info ───────────────────────────────────────────────
  Widget _buildPersonalStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildField(
                  controller: _firstNameCtrl,
                  label: 'First Name',
                  icon: Icons.person_outline_rounded,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildField(
                  controller: _lastNameCtrl,
                  label: 'Last Name',
                  icon: Icons.person_outline_rounded,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ),
            ],
          ),
          _buildField(
            controller: _phoneCtrl,
            label: 'Phone Number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          _buildField(
            controller: _ageCtrl,
            label: 'Age',
            icon: Icons.cake_outlined,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          _buildField(
            controller: _addressCtrl,
            label: 'Address',
            icon: Icons.location_on_outlined,
            maxLines: 2,
          ),
          _buildGenderSelector(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildGenderSelector() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.wc_rounded, color: _accent, size: 18),
              const SizedBox(width: 8),
              Text(
                'Gender',
                style: TextStyle(
                  color: _textLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _genderOption(0, 'Male', Icons.male_rounded),
              const SizedBox(width: 12),
              _genderOption(1, 'Female', Icons.female_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _genderOption(int value, String label, IconData icon) {
    final selected = _gender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _gender = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: selected
                ? LinearGradient(colors: [_accent, _gold])
                : null,
            color: selected ? null : _cardBg,
            border: Border.all(
              color: selected
                  ? Colors.transparent
                  : _textLight.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: _white, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: _white,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── STEP 2: Account Info ────────────────────────────────────────────────
  Widget _buildAccountStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildField(
            controller: _userNameCtrl,
            label: 'Username',
            icon: Icons.alternate_email_rounded,
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          _buildField(
            controller: _emailCtrl,
            label: 'Email Address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v!.isEmpty) return 'Required';
              if (!v.contains('@')) return 'Invalid email';
              return null;
            },
          ),
          _buildPasswordField(),
          _buildDropdownField(
            label: 'Role',
            icon: Icons.badge_outlined,
            value: _roles[_roleId],
            items: _roles,
            onChanged: (v) => setState(() => _roleId = _roles.indexOf(v!)),
          ),
          _buildActiveToggle(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_outline_rounded, color: _accent, size: 18),
              const SizedBox(width: 8),
              Text(
                'Password',
                style: TextStyle(
                  color: _textLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordCtrl,
            obscureText: _obscurePassword,
            style: TextStyle(color: _white, fontSize: 14),
            validator: (v) {
              if (v!.isEmpty) return 'Required';
              if (v.length < 6) return 'Min 6 characters';
              return null;
            },
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: TextStyle(color: _textLight.withOpacity(0.5)),
              border: InputBorder.none,
              isDense: true,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: _textLight,
                  size: 18,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveToggle() {
    return _buildCard(
      child: Row(
        children: [
          Icon(Icons.toggle_on_outlined, color: _accent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Status',
                  style: TextStyle(
                    color: _white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Account is ${_isActive ? "active" : "inactive"}',
                  style: TextStyle(color: _textLight, fontSize: 11),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _isActive,
            onChanged: (v) => setState(() => _isActive = v),
            activeColor: _gold,
            activeTrackColor: _accent.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  // ─── STEP 3: Additional Details ──────────────────────────────────────────
  Widget _buildDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildField(
            controller: _nationalityNoCtrl,
            label: 'Nationality / National ID',
            icon: Icons.credit_card_outlined,
          ),
          _buildDropdownField(
            label: 'Country of Nationality',
            icon: Icons.flag_outlined,
            value: _countries[_nationalityCountryId],
            items: _countries,
            onChanged: (v) =>
                setState(() => _nationalityCountryId = _countries.indexOf(v!)),
          ),
          _buildField(
            controller: _noteCtrl,
            label: 'Note / Bio',
            icon: Icons.note_alt_outlined,
            maxLines: 4,
          ),
          const SizedBox(height: 20),
          _buildSummaryCard(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accent.withOpacity(0.4), width: 1),
        gradient: LinearGradient(
          colors: [_accent.withOpacity(0.15), _gold.withOpacity(0.08)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_outline, color: _gold, size: 18),
              const SizedBox(width: 8),
              Text(
                'Summary',
                style: TextStyle(
                  color: _white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _summaryRow('Name', '${_firstNameCtrl.text} ${_lastNameCtrl.text}'),
          _summaryRow('Email', _emailCtrl.text),
          _summaryRow('Username', _userNameCtrl.text),
          _summaryRow('Gender', _gender == 0 ? 'Male' : 'Female'),
          _summaryRow('Role', _roles[_roleId]),
          _summaryRow('Status', _isActive ? '✅ Active' : '❌ Inactive'),
        ],
      ),
    );
  }

  Widget _summaryRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(key, style: TextStyle(color: _textLight, fontSize: 11)),
          ),
          Text(
            '• ',
            style: TextStyle(color: _accent, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: TextStyle(
                color: _white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Navigation Buttons ──────────────────────────────────────────────────
  Widget _buildNavigationButtons() {
    final isLast = _currentStep == 2;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: _buildButton(
                label: 'Back',
                icon: Icons.arrow_back_rounded,
                onPressed: _prevStep,
                outline: true,
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: _buildButton(
              label: isLast ? 'Register' : 'Continue',
              icon: isLast ? Icons.check_rounded : Icons.arrow_forward_rounded,
              onPressed: isLast ? _submit : _nextStep,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool outline = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: outline
              ? null
              : LinearGradient(
                  colors: [_gold, _accent],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          border: outline
              ? Border.all(color: _textLight.withOpacity(0.3))
              : null,
          boxShadow: outline
              ? []
              : [
                  BoxShadow(
                    color: _gold.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: _white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, color: _white, size: 18),
          ],
        ),
      ),
    );
  }

  // ─── Shared Widgets ──────────────────────────────────────────────────────
  Widget _buildCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _inputBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _white.withOpacity(0.05)),
      ),
      child: child,
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _accent, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: _textLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            validator: validator,
            maxLines: maxLines,
            style: TextStyle(color: _white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Enter $label',
              hintStyle: TextStyle(color: _textLight.withOpacity(0.4)),
              border: InputBorder.none,
              isDense: true,
              errorStyle: TextStyle(color: _gold, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _accent, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: _textLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: value,
            isExpanded: true,
            dropdownColor: _secondary,
            underline: const SizedBox(),
            iconEnabledColor: _textLight,
            style: TextStyle(color: _white, fontSize: 14),
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  ImagePicker() {}
}

class ImageSource {
  static const gallery = 0;
}
