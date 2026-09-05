import 'package:flutter/material.dart';
import 'medicine_category_screen.dart'; 

class MedicineAvailabilityPage extends StatelessWidget {
  MedicineAvailabilityPage({super.key});

  final List<Map<String, String>> previouslyViewed = [
    {"name": "Aspirin", "desc": "Pain reliever, anti-inflammatory", "status": "Available"},
    {"name": "Metformin", "desc": "Diabetes medication", "status": "Available"},
    {"name": "Amoxicillin", "desc": "Antibiotic", "status": "Low Stock"},
    {"name": "Atorvastatin", "desc": "Cholesterol medication", "status": "Available"},
  ];

  // Updated to match your database categories
  final List<Map<String, dynamic>> categories = [
    {"icon": Icons.thermostat, "label": "Fever"},
    {"icon": Icons.healing, "label": "Painkiller"},
    {"icon": Icons.medication, "label": "Antibiotic"},
    {"icon": Icons.coronavirus, "label": "Allergy"},
    {"icon": Icons.monitor_heart, "label": "Diabetes"},
    {"icon": Icons.water_drop, "label": "Hydration"},
    {"icon": Icons.local_hospital, "label": "Acidity"},
    {"icon": Icons.visibility, "label": "View All"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: const [
            Icon(Icons.medication, color: Colors.blueAccent, size: 28),
            SizedBox(width: 8),
            Text(
              "Medicine Availability",
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.black87, size: 30),
            onPressed: () => print("User Profile clicked"),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Column(
                children: [
                  Text(
                    "Find Your Medicines",
                    style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text("Check availability and search by category", style: TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              // CHANGED: Added onSubmitted to trigger when the user hits 'Search' on the keyboard
              onSubmitted: (query) {
                if (query.trim().isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MedicineCategoryScreen(
                        categoryName: query, // Pass the search query
                        isSearch: true,      // Tell the screen this is a search, not a category click
                      ),
                    ),
                  );
                }
              },
              decoration: InputDecoration(
                hintText: "Search medicine by name",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () => print("Filter menu opened"),
                ),
                filled: true,
                fillColor: Colors.blue.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            const Text("Browse by Category", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            
            GridView.builder(
              itemCount: categories.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MedicineCategoryScreen(
                            categoryName: categories[index]["label"], 
                            isSearch: false, // Default behavior
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(categories[index]["icon"], size: 28, color: Colors.black87),
                          const SizedBox(height: 4),
                          Text(
                            categories[index]["label"],
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.blueAccent),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 25),
            
            const Text(
              "Previously Viewed Medicines",
              style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: previouslyViewed.length,
                itemBuilder: (context, index) {
                  final item = previouslyViewed[index];
                  final statusColor = item["status"] == "Low Stock" ? Colors.orange : Colors.blueAccent;

                  return InkWell(
                    onTap: () => print("Viewed details for ${item['name']}"),
                    child: ListTile(
                      title: Text(
                        item["name"]!,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                      subtitle: Text(item["desc"]!),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusColor),
                        ),
                        child: Text(
                          item["status"]!,
                          style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}