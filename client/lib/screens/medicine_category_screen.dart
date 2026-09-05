// lib/screens/medicine_category_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'medicine_api_service.dart';
import 'medicine_model.dart';

class MedicineCategoryScreen extends StatefulWidget {
  final String categoryName;
  final bool isSearch; 

  const MedicineCategoryScreen({
    super.key, 
    required this.categoryName, 
    this.isSearch = false, 
  });

  @override
  State<MedicineCategoryScreen> createState() => _MedicineCategoryScreenState();
}

class _MedicineCategoryScreenState extends State<MedicineCategoryScreen> {
  late Future<List<Medicine>> futureMedicines;
  
  // CHANGED: 1. Added a TextEditingController to track what the user types
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    
    if (widget.isSearch) {
      futureMedicines = MedicineApiService.searchMedicines(widget.categoryName);
    } else {
      futureMedicines = MedicineApiService.getMedicinesByCategory(widget.categoryName);
    }

    // CHANGED: 2. Add a listener to update the UI whenever the text changes
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose(); // Always dispose controllers to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          widget.isSearch ? 'Search: "${widget.categoryName}"' : '${widget.categoryName} Medicines',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      // CHANGED: 3. Changed body to a Column so we can stack the SearchBar and the List
      body: Column(
        children: [
          // --- NEW SEARCH BAR ---
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Filter these medicines...",
                hintStyle: GoogleFonts.poppins(color: Colors.black38),
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () => _searchController.clear(),
                    )
                  : null, // Only show the clear 'X' button if there is text
                filled: true,
                fillColor: Colors.blue.shade50,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          
          // --- THE MEDICINE LIST ---
          // CHANGED: 4. Wrapped FutureBuilder in an Expanded widget so it takes up the rest of the screen
          Expanded(
            child: FutureBuilder<List<Medicine>>(
              future: futureMedicines,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Error loading medicines:\n${snapshot.error}',
                        style: GoogleFonts.poppins(color: Colors.redAccent),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          widget.isSearch 
                              ? 'No medicines found matching "${widget.categoryName}".'
                              : 'No medicines found in this category.',
                          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                // CHANGED: 5. Filter the list based on the search query before displaying it
                final allMedicines = snapshot.data!;
                final filteredMedicines = allMedicines.where((med) {
                  return med.name.toLowerCase().contains(_searchQuery);
                }).toList();

                // Handle the case where the user filters out everything
                if (filteredMedicines.isEmpty) {
                  return Center(
                    child: Text(
                      'No matches found for "$_searchQuery".',
                      style: GoogleFonts.poppins(color: Colors.black54),
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredMedicines.length, // Use the filtered list length
                  itemBuilder: (context, index) {
                    final med = filteredMedicines[index]; // Use the filtered list item

                    return Card(
                      elevation: 2,
                      shadowColor: Colors.black12,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        title: Text(
                          med.name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, 
                            color: Colors.blueAccent,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            med.description,
                            style: GoogleFonts.poppins(
                              fontSize: 13, 
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}