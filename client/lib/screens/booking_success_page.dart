import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main_scaffold.dart';

class BookingSuccessPage extends StatefulWidget {
  final bool isOfflinePayment;

  final String token;

  const BookingSuccessPage({
    super.key,
    this.isOfflinePayment = false,
    required this.token,
  });

  @override
  State<BookingSuccessPage> createState() =>
      _BookingSuccessPageState();
}

class _BookingSuccessPageState
    extends State<BookingSuccessPage> {

  //////////////////////////////////////////////////////
  // INIT
  //////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();

    //////////////////////////////////////////////////////
    // AUTO REDIRECT AFTER 3 SECONDS
    //////////////////////////////////////////////////////

    Timer(const Duration(seconds: 3), () {

      if (!mounted) return;

      //////////////////////////////////////////////////////
      // GO TO MAIN SCAFFOLD
      //////////////////////////////////////////////////////

      Navigator.pushAndRemoveUntil(
        context,

        MaterialPageRoute(
          builder: (_) => MainScaffold(
            token: widget.token,
          ),
        ),

        (route) => false,
      );
    });
  }

  //////////////////////////////////////////////////////
  // UI
  //////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),

            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [

                //////////////////////////////////////////////////////
                // SUCCESS ICON
                //////////////////////////////////////////////////////

                Container(
                  width: 120,
                  height: 120,

                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 80,
                  ),
                ),

                const SizedBox(height: 30),

                //////////////////////////////////////////////////////
                // TITLE
                //////////////////////////////////////////////////////

                Text(
                  "Booking Confirmed!",
                  textAlign: TextAlign.center,

                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 14),

                //////////////////////////////////////////////////////
                // MESSAGE
                //////////////////////////////////////////////////////

                Text(
                  widget.isOfflinePayment
                      ? "Your appointment has been confirmed.\nPlease pay at the hospital."
                      : "Your payment was successful.\nAppointment confirmed.",

                  textAlign: TextAlign.center,

                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                //////////////////////////////////////////////////////
                // LOADING
                //////////////////////////////////////////////////////

                const CircularProgressIndicator(),

                const SizedBox(height: 18),

                Text(
                  "Redirecting to home...",

                  style: GoogleFonts.poppins(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}