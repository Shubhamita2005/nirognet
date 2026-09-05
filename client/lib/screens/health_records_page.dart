import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'prescriptions_page.dart';
import 'health_reports_page.dart';

class HealthRecordsPage extends StatefulWidget {
  const HealthRecordsPage({super.key});

  @override
  State<HealthRecordsPage> createState() =>
      _HealthRecordsPageState();
}

class _HealthRecordsPageState
    extends State<HealthRecordsPage> {
  final TextEditingController medicineController =
      TextEditingController();

  List<String> medicines = [];

  @override
  void dispose() {
    medicineController.dispose();
    super.dispose();
  }

  // =========================
  // ADD MEDICINE
  // =========================
  void addMedicine() {
    final medicine =
        medicineController.text.trim();

    if (medicine.isEmpty) return;

    setState(() {
      medicines.add(medicine);
      medicineController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Medicine added successfully",
          style: GoogleFonts.poppins(),
        ),
      ),
    );
  }

  // =========================
  // REMOVE MEDICINE
  // =========================
  void removeMedicine(int index) {
    setState(() {
      medicines.removeAt(index);
    });
  }

  // =========================
  // BUTTON CARD
  // =========================
  Widget buildMainButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 42,
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.blueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF7FDFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme:
            const IconThemeData(color: Colors.black),
        title: Text(
          "Health Records",
          style: GoogleFonts.poppins(
            color: Colors.blueAccent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // =========================
              // PRESCRIPTIONS BUTTON
              // =========================
              buildMainButton(
                icon: Icons.description,
                title: "Prescriptions",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const PrescriptionsPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // =========================
              // HEALTH REPORTS BUTTON
              // =========================
              buildMainButton(
                icon: Icons.medical_information,
                title: "Health Reports",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const HealthReportsPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              // =========================
              // MEDICINES TITLE
              // =========================
              Text(
                "Current Medicines",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueAccent,
                ),
              ),

              const SizedBox(height: 12),

              // =========================
              // MEDICINES BOX
              // =========================
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(22),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      "My Medicines",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w600,
                        color:
                            Colors.blueAccent,
                      ),
                    ),

                    const SizedBox(height: 15),

                    // =========================
                    // INPUT FIELD
                    // =========================
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller:
                                medicineController,
                            decoration:
                                InputDecoration(
                              hintText:
                                  "Enter medicine name",
                              hintStyle:
                                  GoogleFonts
                                      .poppins(),
                              filled: true,
                              fillColor:
                                  const Color(
                                      0xFFF3F7FA),
                              border:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            14),
                                borderSide:
                                    BorderSide
                                        .none,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                            width: 10),

                        ElevatedButton(
                          onPressed:
                              addMedicine,
                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                const Color(
                                    0xFF9EE3E0),
                            foregroundColor:
                                Colors.black,
                            padding:
                                const EdgeInsets
                                      .symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          14),
                            ),
                          ),
                          child: const Icon(
                              Icons.add),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // =========================
                    // MEDICINE CARDS
                    // =========================
                    medicines.isEmpty
                        ? Center(
                            child: Text(
                              "No medicines added yet",
                              style:
                                  GoogleFonts
                                      .poppins(
                                color:
                                    Colors.grey,
                              ),
                            ),
                          )
                        : Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: medicines
                                .asMap()
                                .entries
                                .map(
                                  (entry) {
                                    final index =
                                        entry.key;
                                    final medicine =
                                        entry.value;

                                    return Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                        horizontal:
                                            14,
                                        vertical:
                                            10,
                                      ),
                                      decoration:
                                          BoxDecoration(
                                        color:
                                            const Color(
                                                0xFF9EE3E0),
                                        borderRadius:
                                            BorderRadius.circular(
                                                16),
                                      ),
                                      child: Row(
                                        mainAxisSize:
                                            MainAxisSize.min,
                                        children: [
                                          Text(
                                            medicine,
                                            style:
                                                GoogleFonts.poppins(
                                              fontWeight:
                                                  FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(
                                              width:
                                                  8),
                                          GestureDetector(
                                            onTap: () =>
                                                removeMedicine(
                                                    index),
                                            child:
                                                const Icon(
                                              Icons
                                                  .close,
                                              size:
                                                  18,
                                              color:
                                                  Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                )
                                .toList(),
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