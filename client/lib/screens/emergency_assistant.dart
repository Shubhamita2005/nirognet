import 'package:flutter/material.dart';

class EmergencyAssistantApp extends StatelessWidget {
  const EmergencyAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emergency Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.teal, useMaterial3: true),
      home: const EmergencyAssistantPage(),
    );
  }
}

class EmergencyAssistantPage extends StatefulWidget {
  const EmergencyAssistantPage({super.key});

  @override
  State<EmergencyAssistantPage> createState() => _EmergencyAssistantPageState();
}

class _EmergencyAssistantPageState extends State<EmergencyAssistantPage> {
  final TextEditingController _controller = TextEditingController();

  final List<Map<String, dynamic>> messages = [
    {
      "isUser": false,
      "text":
          "Hello! I'm here to help with your emergency. Please describe your symptoms or what happened. I can provide first aid tips and suggest nearby hospitals with their resources and doctor availability. You can also attach images if needed.",
    },
  ];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      messages.add({"isUser": true, "text": _controller.text});
    });

    // Simulated AI response
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        messages.add({
          "isUser": false,
          "text":
              "I'm sorry to hear that you're experiencing these symptoms. Breathing difficulties and chest pain can be serious and may need immediate attention.\n\n"
              "Here’s what you can do while waiting for help:\n\n"
              "1️⃣ Stay calm and try to breathe slowly.\n"
              "2️⃣ Sit upright, avoid lying down.\n"
              "3️⃣ Loosen tight clothing.\n"
              "4️⃣ Take slow, deep breaths.\n"
              "5️⃣ If symptoms worsen, call emergency services immediately.\n\n"
              "Nearby Hospitals:",
          "hospitals": [
            {
              "name": "City General Hospital",
              "distance": "0.8 km",
              "doctors": 45,
              "beds": "120 (ICU: 25, Emergency: 30)",
              "ventilators": "15 (Available)",
              "blood": "Full Stock",
            },
            {
              "name": "Metro Medical Center",
              "distance": "1.2 km",
              "doctors": 62,
              "beds": "180 (ICU: 35, Emergency: 45)",
              "ventilators": "22 (Available)",
              "blood": "Limited Stock",
            },
            {
              "name": "Regional Health Institute",
              "distance": "2.1 km",
              "doctors": 38,
              "beds": "95 (ICU: 18, Emergency: 20)",
              "ventilators": "12 (Available)",
              "blood": "Full Stock",
            },
          ],
        });
      });
    });

    _controller.clear();
  }

  Widget _buildHospitalCard(Map<String, dynamic> hospital) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hospital["name"],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 18,
                  color: Colors.redAccent,
                ),
                Text(" ${hospital["distance"]}  •  "),
                const Icon(Icons.person, size: 18, color: Colors.teal),
                Text(" ${hospital["doctors"]} doctors"),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "Beds: ${hospital["beds"]}",
              style: const TextStyle(fontSize: 13),
            ),
            Text(
              "Ventilators: ${hospital["ventilators"]}",
              style: const TextStyle(fontSize: 13),
            ),
            Text(
              "Blood Bank: ${hospital["blood"]}",
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.teal.shade700,
                ),
                onPressed: () {},
                icon: const Icon(Icons.call),
                label: const Text("Call"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    bool isUser = msg["isUser"];
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.teal.shade100 : Colors.blue.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg["text"],
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            if (msg.containsKey("hospitals")) ...[
              const SizedBox(height: 10),
              const Text(
                "Nearby Hospitals",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              ...msg["hospitals"]
                  .map<Widget>((h) => _buildHospitalCard(h))
                  .toList(),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Emergency Assistant",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.warning_amber_rounded, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: false,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(messages[index]);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.teal),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Describe your symptoms...",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
