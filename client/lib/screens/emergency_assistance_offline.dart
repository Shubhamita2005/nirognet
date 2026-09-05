import 'package:flutter/material.dart';

// You can now import this file and use:
// Navigator.push(context, MaterialPageRoute(builder: (context) => const EmergencyAssessmentPage()));

class EmergencyAssessmentPage extends StatefulWidget {
  const EmergencyAssessmentPage({super.key});

  @override
  _EmergencyAssessmentPageState createState() =>
      _EmergencyAssessmentPageState();
}

// DATA_MODEL
class Question {
  final int id;
  final String text;
  final List<String> options;
  const Question({required this.id, required this.text, required this.options});
}

enum AssessmentLevel { urgent, serious, minor }

class AssessmentResult {
  final AssessmentLevel level;
  final String title;
  final String summary;
  const AssessmentResult({
    required this.level,
    required this.title,
    required this.summary,
  });
}
// END DATA_MODEL

class _EmergencyAssessmentPageState extends State<EmergencyAssessmentPage> {
  final List<Question> questions = const <Question>[
    Question(
      id: 1,
      text: "1. Is the person conscious and responsive?",
      options: <String>[
        "Conscious and responsive",
        "Partially responsive",
        "Unresponsive",
      ],
    ),
    Question(
      id: 2,
      text: "2. Is the person breathing normally?",
      options: <String>[
        "Breathing normally",
        "Difficulty breathing",
        "Not breathing",
      ],
    ),
    Question(
      id: 3,
      text: "3. Is there any visible bleeding?",
      options: <String>["No bleeding", "Minor bleeding", "Severe bleeding"],
    ),
    Question(
      id: 4,
      text: "4. What type of pain or discomfort is present?",
      options: <String>["No pain", "Mild pain", "Severe pain"],
    ),
    Question(
      id: 5,
      text: "5. Are there any signs of shock or distress?",
      options: <String>[
        "No signs",
        "Pale, sweating, anxious",
        "Severe signs (faint/unresponsive)",
      ],
    ),
  ];

  final Map<int, int> answers = <int, int>{};
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void selectOption(int qid, int optIndex) {
    setState(() {
      answers[qid] = optIndex;
    });

    Future<void>.delayed(const Duration(milliseconds: 200)).then((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool get allAnswered => answers.length == questions.length;

  AssessmentResult computeAssessment() {
    int urgentScore = 0;
    if (answers[1] == 2) {
      urgentScore += 5;
    } else if (answers[1] == 1)
      urgentScore += 2;
    if (answers[2] == 2) {
      urgentScore += 6;
    } else if (answers[2] == 1)
      urgentScore += 3;
    if (answers[3] == 2) {
      urgentScore += 5;
    } else if (answers[3] == 1)
      urgentScore += 1;
    if (answers[4] == 2) urgentScore += 2;
    if (answers[5] == 2) {
      urgentScore += 5;
    } else if (answers[5] == 1)
      urgentScore += 3;

    if (urgentScore >= 8) {
      return const AssessmentResult(
        level: AssessmentLevel.urgent,
        title: "URGENT MEDICAL ATTENTION",
        summary:
            "This situation requires urgent medical attention. Seek immediate help.",
      );
    } else if (urgentScore >= 4) {
      return const AssessmentResult(
        level: AssessmentLevel.serious,
        title: "MEDICAL ATTENTION ADVISED",
        summary:
            "Patient needs medical attention soon. Monitor condition and seek help.",
      );
    } else {
      return const AssessmentResult(
        level: AssessmentLevel.minor,
        title: "NON-URGENT / MONITOR",
        summary:
            "No immediate life-threatening signs found. Provide basic first aid and monitor.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> chatWidgets = <Widget>[];

    for (final Question q in questions) {
      chatWidgets.add(ChatBubble(text: q.text, fromUser: false));

      if (answers.containsKey(q.id)) {
        final int idx = answers[q.id]!;
        chatWidgets.add(ChatBubble(text: q.options[idx], fromUser: true));
      } else {
        chatWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
            child: Wrap(
              runSpacing: 6,
              children: List<Widget>.generate(
                q.options.length,
                (int i) => SizedBox(
                  width: MediaQuery.of(context).size.width * 0.88,
                  child: OptionButton(
                    questionId: q.id,
                    optionIndex: i,
                    label: q.options[i],
                    isSelected: answers[q.id] == i,
                    onPressed: allAnswered ? null : () => selectOption(q.id, i),
                  ),
                ),
              ),
            ),
          ),
        );
        break;
      }
    }

    if (allAnswered) {
      final AssessmentResult res = computeAssessment();
      chatWidgets.add(const SizedBox(height: 6));
      chatWidgets.add(AssessmentCard(result: res));
    }

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
      body: Container(
        color: Colors.grey[100],
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              color: Colors.teal[50],
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              child: const Row(
                children: <Widget>[
                  Icon(Icons.shield, color: Colors.teal),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "I'll help assess the emergency situation. Please answer each question accurately. If this is a life-threatening emergency, call 104 immediately.",
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 20, top: 10),
                children: chatWidgets,
              ),
            ),
            SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                color: Colors.white,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            answers.clear();
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text("New Assessment"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        final String snack = allAnswered
                            ? "Call 104 — Emergency helpline (simulate)"
                            : "Please finish the assessment to see recommendations";
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(snack)));
                      },
                      icon: const Icon(Icons.call),
                      label: const Text("Call 104"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ Supporting widgets below
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.text,
    this.fromUser = false,
    this.maxWidthFactor = 0.78,
  });

  final String text;
  final bool fromUser;
  final double maxWidthFactor;

  @override
  Widget build(BuildContext context) {
    final Color bgColor = fromUser
        ? Colors.teal.shade100
        : Colors.teal.shade300;
    final Color textColor = fromUser ? Colors.black87 : Colors.white;
    final BorderRadius radius = fromUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          );

    return Row(
      mainAxisAlignment: fromUser
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: <Widget>[
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * maxWidthFactor,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: radius,
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(text, style: TextStyle(color: textColor, fontSize: 15)),
          ),
        ),
      ],
    );
  }
}

class OptionButton extends StatelessWidget {
  const OptionButton({
    super.key,
    required this.questionId,
    required this.optionIndex,
    required this.label,
    required this.isSelected,
    this.onPressed,
  });

  final int questionId;
  final int optionIndex;
  final String label;
  final bool isSelected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? Colors.teal.shade50 : Colors.white,
          side: BorderSide(color: Colors.teal.shade300),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: const TextStyle(color: Colors.black87, fontSize: 15),
          ),
        ),
      ),
    );
  }
}

class AssessmentCard extends StatelessWidget {
  const AssessmentCard({super.key, required this.result});

  final AssessmentResult result;

  @override
  Widget build(BuildContext context) {
    Color cardColor;
    IconData icon;
    Color iconColor;
    switch (result.level) {
      case AssessmentLevel.urgent:
        cardColor = Colors.red.shade50;
        icon = Icons.warning;
        iconColor = Colors.redAccent;
        break;
      case AssessmentLevel.serious:
        cardColor = Colors.orange.shade50;
        icon = Icons.health_and_safety;
        iconColor = Colors.orangeAccent;
        break;
      default:
        cardColor = Colors.green.shade50;
        icon = Icons.info;
        iconColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 28, color: iconColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  result.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(result.summary),
          const SizedBox(height: 12),
          const Text(
            "What Has Happened: Medical Shock",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            "The patient is showing signs of shock, which occurs when the body isn't getting enough blood flow. This could be due to blood loss, heart problems, severe infection, or allergic reaction.",
          ),
          const SizedBox(height: 12),
          const Text(
            "Immediate Actions:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _ActionItem("Call 104 for medical assistance"),
              _ActionItem("Keep the person calm and comfortable"),
              _ActionItem("Monitor breathing and consciousness"),
              _ActionItem("Apply pressure to control bleeding"),
              _ActionItem("Do not give food or water if unconscious"),
              _ActionItem("Prepare for transport to hospital"),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Call 104 — Emergency helpline (simulate)"),
                ),
              );
            },
            icon: const Icon(Icons.call),
            label: const Text("Call 104 - Emergency"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.check_circle_outline,
            size: 18,
            color: Colors.black54,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
