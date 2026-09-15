import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'theme_controller.dart';
import 'login_screen.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isSendingReset = false;

  Future<void> _sendPasswordReset() async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) return;

    setState(() => _isSendingReset = true);
    try {
      await _auth.sendPasswordResetEmail(email: user.email!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Password reset email sent to ${user.email}"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to send reset email: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingReset = false);
    }
  }

  Future<void> _logout() async {
    bool confirm = await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Confirm Logout"),
            content: const Text("Are you sure you want to log out of the Admin Portal?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC2185B)),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text("Logout", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      try {
        await _auth.signOut();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error logging out: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Settings"),
        backgroundColor: const Color(0xFFC2185B),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- ADMIN ACCOUNT HEADER ---
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFFC2185B),
                    child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "System Administrator",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? "admin@portal.com",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "Full Access Authority",
                            style: TextStyle(
                              color: Color(0xFFC2185B),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // --- PREFERENCES SECTION ---
          const Text("PREFERENCES",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: darkModeNotifier,
                  builder: (context, isDarkMode, child) {
                    return SwitchListTile(
                      secondary: const Icon(Icons.dark_mode, color: Color(0xFFC2185B)),
                      title: const Text("Dark Theme"),
                      subtitle: const Text("Toggle dark mode for admin dashboard"),
                      value: isDarkMode,
                      activeColor: const Color(0xFFC2185B),
                      onChanged: (value) => setDarkMode(value, isDriver: false),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // --- SECURITY SECTION ---
          const Text("SECURITY & AUTHENTICATION",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_reset, color: Color(0xFFC2185B)),
                  title: const Text("Reset Admin Password"),
                  subtitle: const Text("Receive a password reset link in your email"),
                  trailing: _isSendingReset
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: _isSendingReset ? null : _sendPasswordReset,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // --- SYSTEM INFORMATION SECTION ---
          const Text("SYSTEM DETAILS",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.verified_user_outlined, color: Color(0xFFC2185B)),
                  title: Text("Portal Context"),
                  subtitle: Text("Women Ride Safety - Admin Console"),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.cloud_done_outlined, color: Color(0xFFC2185B)),
                  title: Text("Database Status"),
                  subtitle: Text("Firebase Cloud Firestore Connected"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // --- LOGOUT BUTTON ---
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.logout),
            label: const Text("LOGOUT FROM ADMIN PORTAL",
                style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: _logout,
          ),
        ],
      ),
    );
  }
}