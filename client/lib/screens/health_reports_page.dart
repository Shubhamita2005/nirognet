import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';

class HealthReportsPage extends StatefulWidget {
  const HealthReportsPage({super.key});

  @override
  State<HealthReportsPage> createState() =>
      _HealthReportsPageState();
}

class _HealthReportsPageState
    extends State<HealthReportsPage> {
  List<File> reports = [];

  // =========================
  // PICK IMAGE OR PDF
  // =========================
  Future<void> uploadReport() async {
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
                      reports.add(File(picked.path));
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
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
                      result.files.single.path != null) {
                    setState(() {
                      reports.add(
                        File(result.files.single.path!),
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
  // VIEW FILE
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
              iconTheme: const IconThemeData(
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
          borderRadius: BorderRadius.circular(20),
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
  void deleteReport(int index) {
    setState(() {
      reports.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Report removed",
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
          "Health Reports",
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
        onPressed: uploadReport,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),

      body: reports.isEmpty
          ? Center(
              child: Text(
                "No health reports uploaded",
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
                  reports.length,
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
                    reports[index];

                return GestureDetector(
                  onTap: () =>
                      openFile(file),
                  onLongPress: () =>
                      deleteReport(
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