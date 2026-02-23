import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';

/// Profile Screen — displays user info with editable form and various widgets.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController(text: 'Dara Student');
  final _emailCtrl = TextEditingController(text: 'dara@university.edu');
  final _phoneCtrl = TextEditingController(text: '+855 12 345 678');
  bool _isEditing = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          // ── IconButton to toggle edit mode ──
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            tooltip: _isEditing ? 'Cancel' : 'Edit Profile',
            onPressed: () => setState(() => _isEditing = !_isEditing),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            // ── Avatar with Network Image ──
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: AppConstants.primaryColor.withValues(
                      alpha: 0.1,
                    ),
                    child: const CircleAvatar(
                      radius: 52,
                      backgroundImage: NetworkImage(
                        'https://i.pravatar.cc/150?img=12',
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Camera feature coming soon!'),
                            ),
                          );
                        },
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Dara Student',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Computer Science — Year 4',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // ── Profile Form with validation ──
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: _nameCtrl,
                    label: 'Full Name',
                    prefixIcon: Icons.person,
                    validator: Validators.required,
                  ),
                  CustomTextField(
                    controller: _emailCtrl,
                    label: 'Email',
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  CustomTextField(
                    controller: _phoneCtrl,
                    label: 'Phone',
                    prefixIcon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: Validators.required,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (_isEditing) ...[
              // ── Save (ElevatedButton) ──
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Save Changes'),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      setState(() => _isEditing = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
              // ── Discard (TextButton) ──
              TextButton(
                onPressed: () => setState(() => _isEditing = false),
                child: const Text('Discard Changes'),
              ),
            ] else ...[
              // ── Info cards ──
              _InfoTile(
                icon: Icons.school,
                title: 'University',
                subtitle: 'Royal University of Phnom Penh',
              ),
              _InfoTile(
                icon: Icons.book,
                title: 'Course',
                subtitle: 'CS361 — Mobile App Development',
              ),
              _InfoTile(
                icon: Icons.calendar_today,
                title: 'Semester',
                subtitle: 'Spring 2026',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppConstants.primaryColor.withValues(alpha: 0.1),
          child: Icon(icon, color: AppConstants.primaryColor),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
