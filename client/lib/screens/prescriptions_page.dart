import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';

class PrescriptionsPage extends StatefulWidget {
  const PrescriptionsPage({super.key});

  @override
  State<PrescriptionsPage> createState() =>
      _PrescriptionsPageState();
}

class _PrescriptionsPageState
    extends State<PrescriptionsPage> {
  List<File> prescriptions = [];

  // =========================
  // PICK IMAGE OR PDF
  // =========================
  Future<void> uploadPrescription() async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.image),
                title: Text(
                  "Upload Image",
                  style: GoogleFonts.poppins(),
                ),
                onTap: () async {
                  Navigator.pop(context);

                  final picked =
                      await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );

                  if (picked != null) {
                    setState(() {
                      prescriptions.add(
                        File(picked.path),
                      );
                    });
                  }
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.picture_as_pdf),
                title: Text(
                  "Upload PDF",
                  style: GoogleFonts.poppins(),
                ),
                onTap: () async {
                  Navigator.pop(context);

                  final result =
                      await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf'],
                  );

                  if (result != null &&
                      result.files.single.path !=
                          null) {
                    setState(() {
                      prescriptions.add(
                        File(
                          result
                              .files
                              .single
                              .path!,
                        ),
                      );
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // OPEN FILE
  // =========================
  void openFile(File file) {
    final extension =
        file.path.split('.').last.toLowerCase();

    if (extension == 'pdf') {
      OpenFile.open(file.path);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.white,
              iconTheme:
                  const IconThemeData(
                color: Colors.black,
              ),
            ),
            body: Center(
              child: InteractiveViewer(
                child: Image.file(file),
              ),
            ),
          ),
        ),
      );
    }
  }

  // =========================
  // FILE CARD
  // =========================
  Widget buildFileCard(File file) {
    final extension =
        file.path.split('.').last.toLowerCase();

    if (extension == 'pdf') {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.picture_as_pdf,
              color: Colors.red,
              size: 55,
            ),
            const SizedBox(height: 10),
            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 8,
              ),
              child: Text(
                file.path.split('/').last,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(20),
        image: DecorationImage(
          image: FileImage(file),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // =========================
  // DELETE FILE
  // =========================
  void deletePrescription(int index) {
    setState(() {
      prescriptions.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Prescription removed",
          style: GoogleFonts.poppins(),
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
            const IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          "Prescriptions",
          style: GoogleFonts.poppins(
            color: Colors.blueAccent,
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ),

      floatingActionButton:
          FloatingActionButton(
        backgroundColor:
            Colors.blueAccent,
        onPressed:
            uploadPrescription,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),

      body: prescriptions.isEmpty
          ? Center(
              child: Text(
                "No prescriptions uploaded",
                style:
                    GoogleFonts.poppins(
                  fontSize: 15,
                ),
              ),
            )
          : GridView.builder(
              padding:
                  const EdgeInsets.all(
                16,
              ),
              itemCount:
                  prescriptions.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing:
                    14,
                mainAxisSpacing:
                    14,
                childAspectRatio:
                    0.9,
              ),
              itemBuilder:
                  (context, index) {
                final file =
                    prescriptions[index];

                return GestureDetector(
                  onTap: () =>
                      openFile(file),
                  onLongPress: () =>
                      deletePrescription(
                          index),
                  child:
                      buildFileCard(
                          file),
                );
              },
            ),
    );
  }
}