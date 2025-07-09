import 'package:flutter/material.dart';
import 'package:quickcard/shared/widgets/labeled_text_field.dart';

class AddAuthorityScreen extends StatefulWidget {
  final int schoolId;

  const AddAuthorityScreen({super.key, required this.schoolId});

  @override
  State<AddAuthorityScreen> createState() => _AddAuthorityScreenState();
}

class _AddAuthorityScreenState extends State<AddAuthorityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isSubmitting = false;

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isSubmitting = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Authority added successfully!')),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assign New Authority')),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Add & Assign New Authority',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This will add a new user as an authority to this school.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 32),
                _buildLabeledField(
                  controller: _nameController,
                  label: "Name",
                  hint: "Enter full name",
                  validator: (v) => v!.isEmpty ? "Name is required" : null,
                ),
                const SizedBox(height: 16),
                _buildLabeledField(
                  controller: _emailController,
                  label: "Email",
                  hint: "Enter email address",
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v!.isEmpty) return "Email is required";
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    return emailRegex.hasMatch(v) ? null : "Invalid email";
                  },
                ),
                const SizedBox(height: 16),
                _buildLabeledField(
                  controller: _phoneController,
                  label: "Phone",
                  hint: "Enter phone number",
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? "Phone is required" : null,
                ),
                const SizedBox(height: 16),
                _buildLabeledField(
                  controller: _passwordController,
                  label: "Password",
                  hint: "Enter password",
                  keyboardType: TextInputType.visiblePassword,
                  isObscure: true,
                  validator: (v) => v!.length < 8 ? "Min 8 characters" : null,
                ),
                const SizedBox(height: 16),
                _buildLabeledField(
                  controller: _addressController,
                  label: "Address",
                  hint: "Enter address",
                  maxLines: 2,
                  validator: (v) => null,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitForm,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.person_add),
                    label: Text(
                      _isSubmitting ? 'Submitting...' : 'Add Authority',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabeledField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool isObscure = false,
    int maxLines = 1,
  }) {
    return FormField<String>(
      validator: (value) => validator?.call(controller.text),
      builder: (fieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LabeledTextField(
              label: label,
              hintText: hint,
              controller: controller,
              keyboardType: keyboardType,
            ),
            if (fieldState.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 6),
                child: Text(
                  fieldState.errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }
}
