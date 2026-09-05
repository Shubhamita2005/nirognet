import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../models/specialty.dart';
import '../models/doctor.dart';
import 'book_consultation_specialty.dart';
import 'profile_page.dart';
import '../main_scaffold.dart';

class InfoChip extends StatelessWidget {
  final String text;
  const InfoChip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.blueAccent,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class BookConsultationScreen extends StatefulWidget {
  final String token;

  const BookConsultationScreen({
    super.key,
    required this.token,
  });

  @override
  State<BookConsultationScreen> createState() =>
      _BookConsultationScreenState();
}

class _BookConsultationScreenState
    extends State<BookConsultationScreen> {
  List<Specialty> specialties = [];
  List<Specialty> filteredSpecialties = [];

  List<Doctor> allDoctors = [];
  List<Doctor> filteredDoctors = [];

  bool isLoading = true;
  bool showDoctorResults = false;

  final TextEditingController searchController =
      TextEditingController();


  @override
  void initState() {
    super.initState();
    fetchSpecialties().then((_) {
      fetchAllDoctors();
    });
  }

  // ================= FETCH SPECIALTIES =================
  Future<void> fetchSpecialties() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:5000/api/specialties"),
      );

      final body = jsonDecode(response.body);
      final List data =
          body is List ? body : body["specialties"] ?? [];

      specialties =
          data.map((e) => Specialty.fromJson(e)).toList();

      setState(() {
        filteredSpecialties = specialties;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("ERROR: $e");
      setState(() => isLoading = false);
    }
  }

  // ================= FETCH DOCTORS (FIXED) =================
  Future<void> fetchAllDoctors() async {
    try {
      Map<int, Doctor> doctorMap = {};

      for (var spec in specialties) {
        final response = await http.get(
          Uri.parse(
              "http://10.0.2.2:5000/api/specialties/${spec.id}/doctors"),
          headers: {"Authorization": "Bearer $widget.Token"},
        );

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          final List data = decoded["doctors"] ?? [];

          for (var item in data) {
            final doc = Doctor.fromJson(item);

            if (doctorMap.containsKey(doc.id)) {
              doctorMap[doc.id]!.slots.addAll(doc.slots);
            } else {
              doctorMap[doc.id] = doc;
            }
          }
        }
      }

      setState(() {
        allDoctors = doctorMap.values.toList();
      });
    } catch (e) {
      debugPrint("ERROR FETCHING DOCTORS: $e");
    }
  }

  // ================= SEARCH =================
  void filterSearch(String query) {
    final q =
        query.toLowerCase().replaceAll("dr ", "").trim();

    final doctorMatches = allDoctors.where((d) {
      return d.name
          .toLowerCase()
          .replaceAll("dr ", "")
          .contains(q);
    }).toList();

    if (doctorMatches.isNotEmpty && query.isNotEmpty) {
      setState(() {
        filteredDoctors = doctorMatches;
        showDoctorResults = true;
      });
    } else {
      setState(() {
        filteredSpecialties = specialties.where((spec) {
          return spec.name.toLowerCase().contains(q);
        }).toList();
        showDoctorResults = false;
      });
    }
  }

  // ================= ICONS (RESTORED) =================
  IconData getIcon(String name) {
    switch (name.toLowerCase()) {
      case "cardiology":
        return Icons.favorite;
      case "dermatology":
        return Icons.spa;
      case "orthopedics":
        return Icons.accessibility_new;
      case "neurology":
        return Icons.psychology;
      case "pediatrics":
        return Icons.child_care;
      case "gynecology":
        return Icons.female;
      case "ophthalmology":
        return Icons.remove_red_eye;
      case "psychiatry":
        return Icons.psychology_alt;
      case "dentistry":
        return Icons.medical_services;
      default:
        return Icons.local_hospital;
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      // HEADER
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
  icon: const Icon(Icons.arrow_back),
  onPressed: () {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => MainScaffold(token: widget.token),
      ),
      (route) => false,
    );
  },
),
                          Row(
                            children: [
                              const Icon(Icons.medical_information,
                                  color: Colors.blueAccent),
                              const SizedBox(width: 6),
                              Text(
                                "Book Consultation",
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blueAccent,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon:
                                const Icon(Icons.account_circle, size: 30),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const ProfilePage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // SEARCH BAR
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF9EE3E0),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.search),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: searchController,
                                  onChanged: filterSearch,
                                  decoration: InputDecoration(
                                    hintText:
                                        "Search doctor or specialty...",
                                    border: InputBorder.none,
                                    hintStyle:
                                        GoogleFonts.poppins(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // DOCTOR RESULTS (FIXED UI)
                      if (showDoctorResults)
                        ListView.builder(
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          itemCount: filteredDoctors.length,
                          itemBuilder: (context, index) {
                            final doctor =
                                filteredDoctors[index];

                            return Container(
                              margin:
                                  const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 5)
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(doctor.name,
                                      style:
                                          GoogleFonts.poppins(
                                              fontWeight:
                                                  FontWeight.w600)),

                                  Text("🏥 ${doctor.hospital}"),

                                  const SizedBox(height: 6),

                                  ...doctor.slots.map((slot) =>
                                      Text(
                                          "📅 ${slot['day']}  ⏰ ${slot['time']}")),

                                  const SizedBox(height: 10),

                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                    children: [
                                      Text(
                                        doctor.isAvailable
                                            ? "Available"
                                            : "Not Available",
                                        style:
                                            GoogleFonts.poppins(
                                          color: doctor
                                                  .isAvailable
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed:
                                            doctor.isAvailable
                                                ? () {}
                                                : null,
                                        style:
                                            ElevatedButton
                                                .styleFrom(
                                          backgroundColor:
                                              const Color(
                                                  0xFF9EE3E0),
                                          foregroundColor:
                                              Colors.black,
                                        ),
                                        child:
                                            const Text("Book"),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            );
                          },
                        ),

                      // SPECIALTY GRID (RESTORED WITH ICONS)
                      if (!showDoctorResults)
                        GridView.builder(
                          physics:
                              const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount:
                              filteredSpecialties.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemBuilder: (context, index) {
                            final specialty =
                                filteredSpecialties[index];

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        SpecialtyDoctorsScreen(
                                      specialtyId:
                                          specialty.id,
                                      specialtyName:
                                          specialty.name,
                                      token: widget.token,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4)
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      getIcon(specialty.name),
                                      color: Colors.black,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      specialty.name,
                                      textAlign:
                                          TextAlign.center,
                                      style:
                                          GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight:
                                            FontWeight.bold,
                                        color:
                                            Colors.blueAccent,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 80),

                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        child: const Text(
                            "EMERGENCY CONSULTATION"),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}