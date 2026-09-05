import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // ✅ Auth service instance
  final AuthService _authService = AuthService();

  // ✅ State variables
  Map<String, dynamic>? userData;
  bool isLoading = true;

  // 🔴 LOGOUT FUNCTION
  Future<void> _logout(BuildContext context) async {
    const storage = FlutterSecureStorage();

    await storage.delete(key: 'access_token');

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/get_started',
      (route) => false,
    );
  }

  // ✅ Load profile on startup
  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  // ✅ Fetch profile from backend
  Future<void> loadProfile() async {
    try {
      setState(() {
        isLoading = true;
      });

      final data = await _authService.getCurrentUserProfile();

      print("UPDATED PROFILE DATA: $data");

      setState(() {
        userData = data;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Profile load error: $e");

      setState(() {
        isLoading = false;
      });
    }
  }

  // ✅ Edit profile dialog
  void _showEditDialog() {
    final nameController =
        TextEditingController(text: userData?['name'] ?? '');

    final ageController =
        TextEditingController(text: userData?['age']?.toString() ?? '');

    final contactController =
        TextEditingController(text: userData?['contact'] ?? '');

    final addressController =
        TextEditingController(text: userData?['address'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Profile"),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Name",
                  ),
                ),

                TextField(
                  controller: ageController,
                  decoration: const InputDecoration(
                    labelText: "Age",
                  ),
                ),

                TextField(
                  controller: contactController,
                  decoration: const InputDecoration(
                    labelText: "Contact",
                  ),
                ),

                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: "Address",
                  ),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () async {
                try {
                  print("SAVE CLICKED");

                  await _authService.updateCurrentUserProfile({
                    "name": nameController.text,
                    "age": ageController.text,
                    "contact": contactController.text,
                    "address": addressController.text,
                  });

                  await loadProfile();

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Profile updated"),
                    ),
                  );
                } catch (e) {
                  print("❌ Update error: $e");

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Update failed"),
                    ),
                  );
                }
              },

              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: const Color(0xFF3ECFCF),

        title: Text(
          'Profile',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),

          onPressed: () => Navigator.of(context).pop(),
        ),

        centerTitle: true,
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // --- Language ---
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                    children: [
                      Text(
                        'Language',

                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      DropdownButton<String>(
                        value: 'English',

                        items: const [
                          DropdownMenuItem(
                            value: 'English',
                            child: Text('English'),
                          ),

                          DropdownMenuItem(
                            value: 'हिन्दी',
                            child: Text('हिन्दी'),
                          ),

                          DropdownMenuItem(
                            value: 'বাংলা',
                            child: Text('বাংলা'),
                          ),

                          DropdownMenuItem(
                            value: 'ગુજરાતી',
                            child: Text('ગુજરાતી'),
                          ),
                        ],

                        onChanged: (value) {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // --- Basic Info ---
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                    children: [
                      Text(
                        'Basic Info',

                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      IconButton(
                        onPressed: _showEditDialog,

                        icon: const Icon(
                          Icons.edit,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),

                  Container(
                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F9F9),

                      borderRadius: BorderRadius.circular(12),

                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Text('Name: ${userData?['name'] ?? ''}'),
                        Text('Age: ${userData?['age'] ?? ''}'),
                        Text('Gender: ${userData?['gender'] ?? ''}'),
                        Text('Contact: ${userData?['contact'] ?? ''}'),
                        Text('Email: ${userData?['email'] ?? ''}'),
                        Text('Address: ${userData?['address'] ?? ''}'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // --- Health Info ---
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                    children: [
                      Text(
                        'Health Info',

                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      IconButton(
                        onPressed: () {},

                        icon: const Icon(
                          Icons.edit,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),

                  Container(
                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F9F9),

                      borderRadius: BorderRadius.circular(12),

                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        Text(
                          'Blood Group: ${userData?['blood_group'] ?? ''}',
                        ),

                        Text(
                          'Blood Pressure: ${userData?['blood_pressure'] ?? ''}',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 🔴 Logout Button
                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton(
                      onPressed: () => _logout(context),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,

                        padding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),

                      child: const Text(
                        'Logout',

                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}