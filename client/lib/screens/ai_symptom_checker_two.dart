import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cura/services/symptom_service.dart';
import 'dart:io';
// Make sure the path is correct
class AISymptomChecker extends StatefulWidget {
  const AISymptomChecker({super.key});

  @override
  State<AISymptomChecker> createState() => _AISymptomCheckerState();
}

class _AISymptomCheckerState extends State<AISymptomChecker> {
  final SymptomService _symptomService = SymptomService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  List<File> uploadedFiles = [];
 
 

  // Suggested quick replies
  List<String> _suggestedReplies = [
    "I have a headache",
    "I'm feeling feverish",
    "I have stomach pain",
    "I feel dizzy",
    "Show common symptoms",
  ];

  @override
  void initState() {
    super.initState();
    _addBotMessage(
      "Hello! I'm your AI health assistant. 👋\n\nI can help you understand your symptoms and suggest possible conditions. Please describe how you're feeling today.",
      showSuggestions: true,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _suggestedReplies = []; // Clear suggestions after user sends message
    });
    _scrollToBottom();
  }

  void _addBotMessage(String text, {bool showSuggestions = false}) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      if (showSuggestions) {
        _updateSuggestedReplies(text);
      }
    });
    _scrollToBottom();
  }

  void _updateSuggestedReplies(String botMessage) {
    // Update suggested replies based on conversation context
    if (botMessage.toLowerCase().contains('headache')) {
      _suggestedReplies = [
        "It's mild",
        "It's severe",
        "It comes and goes",
        "I also feel nauseous",
        "It's been 2 days",
      ];
    } else if (botMessage.toLowerCase().contains('fever')) {
      _suggestedReplies = [
        "Above 100°F",
        "Above 103°F",
        "With chills",
        "For 2 days",
        "With body aches",
      ];
    } else if (botMessage.toLowerCase().contains('how long')) {
      _suggestedReplies = [
        "Since today",
        "2-3 days",
        "A week",
        "More than a week",
        "On and off",
      ];
    }
  }

  Future<void> _handleSubmit(String text) async {
    if (text.trim().isEmpty) return;

    _messageController.clear();
    _addUserMessage(text);

    // Show typing indicator
    setState(() {
      _isTyping = true;
    });

    // Simulate API call delay
    //await Future.delayed(const Duration(seconds: 2));
    await _generateBotResponse(text);
    setState(() {
      _isTyping = false;
    });

    // // Mock bot response (replace with actual API call)
    // _generateBotResponse(text);
  }

  // REPLACE the old _generateBotResponse method with this one
Future<void> _generateBotResponse(String userMessage) async {
  try {
    // Call the Flask API via our service
    final String aiReply = await _symptomService.analyzeSymptom(userMessage);
    
    // Add the bot's response to the chat
    _addBotMessage(aiReply, showSuggestions: true);

  } catch (e) {
    // If the API call fails, show an error message in the chat
    _addBotMessage(
      "I'm sorry, I couldn't process that. Please ensure you are logged in and have an internet connection. Error: ${e.toString()}",
      showSuggestions: false,
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E8E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF008069),
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.medical_services,
                color: Color(0xFF008069),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Symptom Checker',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Always here to help',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              _showOptionsMenu(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Disclaimer banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: const Color(0xFFFFF3CD),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Color(0xFF856404)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This is AI assistance only. For emergencies, call 911.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF856404),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Chat messages
          Expanded(
            child: Stack(
              children: [
                // Background pattern (optional)
                // Container(
                //   decoration: BoxDecoration(
                //     image: DecorationImage(
                //       image: AssetImage('assets/chat_bg.png'), // Optional WhatsApp-style background
                //       fit: BoxFit.cover,
                //       opacity: 0.1,
                //     ),
                //   ),
                // ),
                
                // Messages list
                ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length && _isTyping) {
                      return const TypingIndicator();
                    }
                    return ChatBubble(message: _messages[index]);
                  },
                ),
              ],
            ),
          ),
          
          // Suggested replies
          if (_suggestedReplies.isNotEmpty)
            Container(
              height: 40,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: _suggestedReplies.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(
                        _suggestedReplies[index],
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF008069)),
                      onPressed: () {
                        _handleSubmit(_suggestedReplies[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          
          // Input field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.emoji_emotions_outlined),
                          color: Colors.grey[600],
                          onPressed: () {},
                        ),
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: 'Describe your symptoms...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8),
                            ),
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                            onSubmitted: _handleSubmit,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.attach_file),
                          color: Colors.grey[600],
                          onPressed: () {
                            _showAttachmentOptions(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF008069),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      _handleSubmit(_messageController.text);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Clear Chat'),
                onTap: () {
                  setState(() {
                    _messages.clear();
                    _addBotMessage(
                      "Chat cleared. How can I help you today?",
                      showSuggestions: true,
                    );
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Symptom History'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to history page
                },
              ),
              ListTile(
                leading: const Icon(Icons.emergency),
                title: const Text('Emergency Contacts'),
                onTap: () {
                  Navigator.pop(context);
                  _showEmergencyContacts(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                onTap: () {
                  Navigator.pop(context);
                  _showAboutDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAttachmentOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.image, color: Colors.purple),
                ),
                title: const Text('Upload Medical Report'),
                subtitle: const Text('Share lab reports or prescriptions'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement image picker
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.blue),
                ),
                title: const Text('Take Photo'),
                subtitle: const Text('Capture symptoms visually'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement camera
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.note_add, color: Colors.green),
                ),
                title: const Text('Medical History'),
                subtitle: const Text('Add your medical history'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to medical history form
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEmergencyContacts(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Emergency Contacts'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.local_hospital, color: Colors.red),
                title: const Text('Emergency'),
                subtitle: const Text('911'),
                onTap: () {
                  // Make call
                },
              ),
              ListTile(
                leading: const Icon(Icons.local_hospital, color: Colors.blue),
                title: const Text('Nearest Hospital'),
                subtitle: const Text('Apollo Hospital'),
                onTap: () {
                  // Show directions
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('About AI Health Assistant'),
          content: const Text(
            'This AI assistant helps you understand your symptoms and suggests possible conditions. '
            'It uses advanced AI to analyze your symptoms but should not replace professional medical advice.\n\n'
            'Always consult a healthcare provider for proper diagnosis and treatment.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

// Chat Message Model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

// Chat Bubble Widget
class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: message.isUser ? const Color(0xFFDCF8C6) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(message.isUser ? 12 : 0),
            bottomRight: Radius.circular(message.isUser ? 0 : 12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isUser) ...[
              const Text(
                'AI Assistant',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF008069),
                ),
              ),
              const SizedBox(height: 2),
            ],
            Text(
              message.text,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('HH:mm').format(message.timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                if (message.isUser) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.done_all,
                    size: 14,
                    color: Colors.blue[600],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Typing Indicator Widget
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'AI Assistant',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF008069),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Row(
                  children: List.generate(3, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      child: CircleAvatar(
                        radius: 4,
                        backgroundColor: Colors.grey[400]?.withOpacity(
                          _animation.value > (index * 0.3) 
                            ? 1.0 
                            : 0.3,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}