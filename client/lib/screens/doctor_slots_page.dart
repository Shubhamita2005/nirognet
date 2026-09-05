import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/doctor.dart';
import '../models/doctor_slot.dart';
import '../services/consultation_service.dart';
import '../widgets/slot_card.dart';
import 'consultation_mode_page.dart';

class DoctorSlotsPage extends StatefulWidget {
  final Doctor doctor;
  final String token;

  const DoctorSlotsPage({
    super.key,
    required this.doctor,
    required this.token,
  });

  @override
  State<DoctorSlotsPage> createState() =>
      _DoctorSlotsPageState();
}

class _DoctorSlotsPageState
    extends State<DoctorSlotsPage> {
  DateTime selectedDate = DateTime.now();

  List<DoctorSlot> slots = [];
  bool isLoading = false;
  bool isBooking = false;

  DoctorSlot? selectedSlot;

  List<String> availableDays = [];

  @override
  void initState() {
    super.initState();
    extractAvailableDays();
    setInitialValidDate();
    fetchSlots();
  }

  // =========================
  // AVAILABLE DAYS
  // =========================
  void extractAvailableDays() {
    availableDays = widget.doctor.slots
        .map((slot) =>
            slot['day'].toString().toLowerCase())
        .toSet()
        .toList();
  }

  // =========================
  // FIRST VALID DATE
  // =========================
  void setInitialValidDate() {
    DateTime current = DateTime.now();

    for (int i = 0; i < 30; i++) {
      final dayName =
          getDayName(current.weekday);

      if (availableDays.contains(dayName)) {
        selectedDate = current;
        break;
      }

      current =
          current.add(const Duration(days: 1));
    }
  }

  // =========================
  // DAY NAME
  // =========================
  String getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return "monday";
      case DateTime.tuesday:
        return "tuesday";
      case DateTime.wednesday:
        return "wednesday";
      case DateTime.thursday:
        return "thursday";
      case DateTime.friday:
        return "friday";
      case DateTime.saturday:
        return "saturday";
      case DateTime.sunday:
        return "sunday";
      default:
        return "";
    }
  }

  // =========================
  // FORMAT DATE
  // =========================
  String get formattedDate {
    return "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
  }

  // =========================
  // CHECK DATE VALID
  // =========================
  bool isDateAvailable(DateTime date) {
    final dayName =
        getDayName(date.weekday);
    return availableDays.contains(dayName);
  }

  // =========================
  // FETCH SLOTS
  // =========================
  Future<void> fetchSlots() async {
    if (!isDateAvailable(selectedDate)) {
      setState(() {
        slots = [];
        selectedSlot = null;
      });
      return;
    }

    setState(() {
      isLoading = true;
      selectedSlot = null;
    });

    try {
      final data =
          await ConsultationService.fetchDoctorSlots(
        widget.doctor.id,
        formattedDate,
        widget.token,
      );

      setState(() {
        slots = data
            .map(
              (e) => DoctorSlot.fromJson(e),
            )
            .toList();
      });
    } catch (e) {
      debugPrint("SLOT ERROR: $e");

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Failed to load slots",
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  // =========================
  // DATE PICKER
  // =========================
  Future<void> pickDate() async {
    final picked =
        await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now()
          .add(const Duration(days: 30)),
      selectableDayPredicate: (date) {
        return isDateAvailable(date);
      },
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
      fetchSlots();
    }
  }

  // =========================
  // DATE SELECTOR
  // =========================
  Widget buildDateSelector() {
    final today = DateTime.now();

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 30,
        itemBuilder: (context, index) {
          final date =
              today.add(Duration(days: index));

          final available =
              isDateAvailable(date);

          final selected =
              selectedDate.year ==
                      date.year &&
                  selectedDate.month ==
                      date.month &&
                  selectedDate.day ==
                      date.day;

          return GestureDetector(
            onTap: available
                ? () {
                    setState(() =>
                        selectedDate = date);
                    fetchSlots();
                  }
                : null,
            child: Container(
              width: 65,
              margin:
                  const EdgeInsets.only(
                      right: 10),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.blueAccent
                    : available
                        ? const Color(
                            0xFF9EE3E0)
                        : Colors.grey.shade300,
                borderRadius:
                    BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Text(
                    getDayName(
                            date.weekday)
                        .substring(0, 3)
                        .toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontWeight:
                          FontWeight.w600,
                      color: selected
                          ? Colors.white
                          : available
                              ? Colors.black
                              : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${date.day}",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                      color: selected
                          ? Colors.white
                          : available
                              ? Colors.black
                              : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // =========================
  // BOOK SLOT (FIXED)
  // =========================
  Future<void> bookSelectedSlot() async {
    if (selectedSlot == null) return;

    setState(() => isBooking = true);

    try {
      String slotTime =
          selectedSlot!.time;

      if (slotTime.length == 5) {
        slotTime = "$slotTime:00";
      }

      final dateTime =
          "$formattedDate $slotTime";

      final consultationId =
          await ConsultationService
              .bookConsultation(
        doctorId: widget.doctor.id,
        dateTime: dateTime,
        token: widget.token,
      );

      if (consultationId != null) {
      print("TOKEN PASSING TO MODE PAGE: ${widget.token}");


Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ConsultationModePage(
      consultationId: consultationId,
      token: widget.token,
    ),
  ),
);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              "Booking failed",
              style:
                  GoogleFonts.poppins(),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("BOOK ERROR: $e");

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Booking error occurred",
            style:
                GoogleFonts.poppins(),
          ),
        ),
      );
    }

    if (mounted) {
      setState(() => isBooking = false);
    }
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    final availableDaysText =
        widget.doctor.slots
            .map((slot) => slot['day'])
            .toSet()
            .join(", ");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme:
            const IconThemeData(
                color: Colors.black),
        title: Text(
          widget.doctor.name,
          style: GoogleFonts.poppins(
            color: Colors.blueAccent,
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                "📅 Available: $availableDaysText",
                style: GoogleFonts.poppins(
                  fontWeight:
                      FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              buildDateSelector(),
              const SizedBox(height: 20),
              //////////////////////////////////////////////////////
// DOCTOR FEE CARD
//////////////////////////////////////////////////////

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(18),

  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),

    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
      ),
    ],
  ),

  child: Row(
    children: [

      //////////////////////////////////////////////////////
      // ICON
      //////////////////////////////////////////////////////

      Container(
        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          shape: BoxShape.circle,
        ),

        child: const Icon(
          Icons.currency_rupee,
          color: Colors.green,
          size: 28,
        ),
      ),

      const SizedBox(width: 16),

      //////////////////////////////////////////////////////
      // TEXT
      //////////////////////////////////////////////////////

      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(
              "Consultation Fee",

              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              "₹${widget.doctor.fee}",

              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),

const SizedBox(height: 20),
              Expanded(
                child: isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(),
                      )
                    : GridView.builder(
                        itemCount:
                            slots.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              3,
                        ),
                        itemBuilder:
                            (context,
                                index) {
                          final slot =
                              slots[index];

                          return SlotCard(
                            time:
                                slot.time,
                            available:
                                slot.available,
                            isSelected:
                                selectedSlot ==
                                    slot,
                            onTap: slot
                                    .available
                                ? () {
                                    setState(
                                        () {
                                      selectedSlot =
                                          slot;
                                    });
                                  }
                                : null,
                          );
                        },
                      ),
              ),
              ElevatedButton(
                onPressed:
                    selectedSlot != null
                        ? bookSelectedSlot
                        : null,
                child: Text(
                    "Confirm Booking"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}