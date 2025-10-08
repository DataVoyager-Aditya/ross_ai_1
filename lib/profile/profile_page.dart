import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ross_ai_1/auth/provider/auth_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String role = "";
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isDesktop ? 90 : 80),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32.0 : 20.0,
                vertical: isDesktop ? 24.0 : 20.0,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/home'),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: Image.asset(
                        "assets/images/logo1.png",
                        height: isDesktop ? 50 : 45,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    "Profile",
                    style: TextStyle(
                      fontSize: isDesktop ? 24 : 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E293B),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.home_rounded,
                        color: const Color(0xFF3B82F6),
                        size: isDesktop ? 24 : 20,
                      ),
                      onPressed: () => Navigator.pushNamed(context, '/home'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Consumer<FirebaseAuthProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          var userProfile = provider.userProfile ?? {};
          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32.0 : 24.0,
                vertical: isDesktop ? 48.0 : 32.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 500 : double.infinity,
                ),
                child: Container(
                  padding: EdgeInsets.all(isDesktop ? 40 : 32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.white, Colors.grey.shade50],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 30,
                        offset: const Offset(0, 8),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 60,
                        offset: const Offset(0, 16),
                        spreadRadius: 0,
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade100, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Header
                      Text(
                        "Profile Settings",
                        style: TextStyle(
                          fontSize: isDesktop ? 28 : 24,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E293B),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Manage your account information",
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Profile Avatar
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: isDesktop ? 50 : 45,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: isDesktop ? 48 : 43,
                            backgroundColor: Colors.grey.shade200,
                            child: Text(
                              userProfile["name"].toString().substring(0, 1),
                              style: TextStyle(
                                fontSize: isDesktop ? 24 : 20,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: nameController
                          ..text = userProfile["name"].toString(),
                        decoration: InputDecoration(
                          labelText: "Full Name",
                          labelStyle: TextStyle(
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF3B82F6).withOpacity(0.15),
                                  const Color(0xFF1D4ED8).withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.person_outline,
                              color: const Color(0xFF1D4ED8),
                              size: 20,
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: const Color(0xFF3B82F6),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: emailController
                          ..text = userProfile["email"].toString(),
                        decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle: TextStyle(
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF3B82F6).withOpacity(0.15),
                                  const Color(0xFF1D4ED8).withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.email_outlined,
                              color: const Color(0xFF1D4ED8),
                              size: 20,
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: const Color(0xFF3B82F6),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: userProfile["role"].toString(),
                        decoration: InputDecoration(
                          labelText: "Role",
                          labelStyle: TextStyle(
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF3B82F6).withOpacity(0.15),
                                  const Color(0xFF1D4ED8).withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.work_outline,
                              color: const Color(0xFF1D4ED8),
                              size: 20,
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: const Color(0xFF3B82F6),
                              width: 2,
                            ),
                          ),
                        ),
                        items:
                            [
                              'Legal Assistant',
                              'Law Student',
                              'Lawyer',
                              'Other',
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    color: const Color(0xFF1E293B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged: (val) => setState(() => role = val!),
                      ),
                      const SizedBox(height: 40),
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3B82F6),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () {
                                userProfile["name"] = nameController.text
                                    .trim();
                                userProfile["email"] = emailController.text
                                    .trim();
                                userProfile["role"] = role;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Text("Profile updated successfully!"),
                                      ],
                                    ),
                                    backgroundColor: const Color(0xFF10B981),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                "Update Profile",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFEF4444),
                                side: BorderSide(
                                  color: const Color(0xFFEF4444),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                backgroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                final shouldSignOut = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    title: Text(
                                      "Sign Out",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF1E293B),
                                      ),
                                    ),
                                    content: Text(
                                      "Are you sure you want to sign out?",
                                      style: TextStyle(
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text("Cancel"),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFEF4444,
                                          ),
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: Text("Sign Out"),
                                      ),
                                    ],
                                  ),
                                );

                                if (shouldSignOut == true && context.mounted) {
                                  Future.microtask(() => provider.signOut());
                                  if (context.mounted) {
                                    Navigator.pushNamed(context, '/signin');
                                  }
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.logout_rounded, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Sign Out",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
