import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../services/consultation_service.dart';
import '../services/payment_service.dart';
import 'booking_success_page.dart';

class ConsultationModePage extends StatefulWidget {
  final int consultationId;
  final String token;

  const ConsultationModePage({
    super.key,
    required this.consultationId,
    required this.token,
  });

  @override
  State<ConsultationModePage> createState() =>
      _ConsultationModePageState();
}

class _ConsultationModePageState
    extends State<ConsultationModePage> {

  bool isLoading = false;

  int? selectedType;

  late Razorpay _razorpay;

  //////////////////////////////////////////////////////
  // INIT
  //////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();

    _razorpay = Razorpay();

    _razorpay.on(
      Razorpay.EVENT_PAYMENT_SUCCESS,
      _handlePaymentSuccess,
    );

    _razorpay.on(
      Razorpay.EVENT_PAYMENT_ERROR,
      _handlePaymentError,
    );

    _razorpay.on(
      Razorpay.EVENT_EXTERNAL_WALLET,
      _handleExternalWallet,
    );
  }

  //////////////////////////////////////////////////////
  // DISPOSE
  //////////////////////////////////////////////////////

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  //////////////////////////////////////////////////////
  // SELECT CONSULTATION MODE
  //////////////////////////////////////////////////////

  Future<void> selectMode(int appointmentTypeId) async {

    setState(() {
      isLoading = true;
    });

    try {

      final success =
          await ConsultationService.updateConsultationType(
        consultationId: widget.consultationId,
        appointmentTypeId: appointmentTypeId,
        token: widget.token,
      );

      if (!mounted) return;

      if (success) {

        setState(() {
          selectedType = appointmentTypeId;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              appointmentTypeId == 1
                  ? "Online consultation selected"
                  : "Offline consultation selected",
              style: GoogleFonts.poppins(),
            ),
          ),
        );

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to update consultation type",
              style: GoogleFonts.poppins(),
            ),
          ),
        );
      }

    } catch (e) {

      print("MODE ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Something went wrong",
            style: GoogleFonts.poppins(),
          ),
        ),
      );

    } finally {

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  //////////////////////////////////////////////////////
  // CREATE PAYMENT + OPEN RAZORPAY
  //////////////////////////////////////////////////////

  Future<void> makePayment() async {

    if (selectedType == null) return;

    setState(() {
      isLoading = true;
    });

    try {

      final paymentResponse =
          await PaymentService.createPayment(
        consultationId: widget.consultationId,
        appointmentTypeId: selectedType!,
        token: widget.token,
      );

      if (paymentResponse != null) {

        var options = {

          'key': paymentResponse['payment']['key'],

          'amount':
              paymentResponse['payment']['amount'] * 100,

          'name': 'NirogNet',

          'description': 'Doctor Consultation',

          'order_id':
              paymentResponse['payment']
                  ['razorpay_order_id'],

          'prefill': {
            'contact': '9999999999',
            'email': 'test@test.com',
          },

          'theme': {
            'color': '#2563EB',
          },
        };

        _razorpay.open(options);

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to create payment",
              style: GoogleFonts.poppins(),
            ),
          ),
        );
      }

    } catch (e) {

      print("PAYMENT ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Something went wrong",
            style: GoogleFonts.poppins(),
          ),
        ),
      );

    } finally {

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  //////////////////////////////////////////////////////
  // PAYMENT SUCCESS
  //////////////////////////////////////////////////////

  void _handlePaymentSuccess(
    PaymentSuccessResponse response,
  ) async {

    print("PAYMENT SUCCESS CALLBACK HIT");

    try {

      //////////////////////////////////////////////////////
      // VERIFY PAYMENT
      //////////////////////////////////////////////////////

      bool success =
          await PaymentService.verifyPayment(

        consultationId: widget.consultationId,

        razorpayOrderId:
            response.orderId ?? "",

        razorpayPaymentId:
            response.paymentId ?? "",

        razorpaySignature:
            response.signature ?? "",

        token: widget.token,
      );

      print("VERIFY RESULT: $success");

      if (!mounted) return;

      //////////////////////////////////////////////////////
      // SUCCESS
      //////////////////////////////////////////////////////

      if (success) {

        print("GOING TO SUCCESS PAGE");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BookingSuccessPage(
              token: widget.token,
            ),
          ),
        );

      } else {

        //////////////////////////////////////////////////////
        // VERIFICATION FAILED
        //////////////////////////////////////////////////////

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Payment verification failed",
              style: GoogleFonts.poppins(),
            ),
          ),
        );
      }

    } catch (e) {

      print("PAYMENT VERIFY ERROR: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Payment verification crashed",
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    }
  }

  //////////////////////////////////////////////////////
  // PAYMENT ERROR
  //////////////////////////////////////////////////////

  void _handlePaymentError(
    PaymentFailureResponse response,
  ) {

    print("PAYMENT FAILED");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Payment Failed",
          style: GoogleFonts.poppins(),
        ),
      ),
    );
  }

  //////////////////////////////////////////////////////
  // EXTERNAL WALLET
  //////////////////////////////////////////////////////

  void _handleExternalWallet(
    ExternalWalletResponse response,
  ) {

    print("EXTERNAL WALLET");
  }

  //////////////////////////////////////////////////////
  // MODE CARD
  //////////////////////////////////////////////////////

  Widget buildModeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required int typeId,
  }) {

    final bool isSelected =
        selectedType == typeId;

    return GestureDetector(

      onTap: isLoading
          ? null
          : () async {
              await selectMode(typeId);
            },

      child: AnimatedContainer(

        duration:
            const Duration(milliseconds: 250),

        width: double.infinity,

        padding: const EdgeInsets.all(20),

        margin: const EdgeInsets.only(bottom: 20),

        decoration: BoxDecoration(

          color: isSelected
              ? color.withOpacity(0.08)
              : Colors.white,

          borderRadius:
              BorderRadius.circular(20),

          border: Border.all(
            color: isSelected
                ? color
                : Colors.transparent,
            width: 2,
          ),

          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
            ),
          ],
        ),

        child: Row(
          children: [

            CircleAvatar(

              radius: 28,

              backgroundColor:
                  color.withOpacity(0.15),

              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),

            const SizedBox(width: 18),

            Expanded(
              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    title,

                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,

                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 30,
              ),
          ],
        ),
      ),
    );
  }

  //////////////////////////////////////////////////////
  // UI
  //////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF7F9FC),

      appBar: AppBar(

        title: Text(
          "Select Consultation Mode",

          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),

        backgroundColor: Colors.white,

        foregroundColor: Colors.blueAccent,

        elevation: 1,
      ),

      body: SafeArea(

        child: Padding(

          padding: const EdgeInsets.all(20),

          child: Column(

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Text(
                "Choose how you’d like to consult",

                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Select your preferred appointment type",

                style: GoogleFonts.poppins(
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 30),

              //////////////////////////////////////////////////////
              // ONLINE
              //////////////////////////////////////////////////////

              buildModeCard(
                icon: Icons.video_call,
                title: "Online Consultation",
                subtitle:
                    "Video/phone consultation from home",
                color: Colors.blueAccent,
                typeId: 1,
              ),

              //////////////////////////////////////////////////////
              // OFFLINE
              //////////////////////////////////////////////////////

              buildModeCard(
                icon: Icons.local_hospital,
                title: "Offline Consultation",
                subtitle:
                    "Visit hospital/clinic physically",
                color: Colors.green,
                typeId: 2,
              ),

              const Spacer(),

              //////////////////////////////////////////////////////
              // PAYMENT BUTTONS
              //////////////////////////////////////////////////////

              if (selectedType != null) ...[

                //////////////////////////////////////////////////////
                // ONLINE CONSULTATION
                //////////////////////////////////////////////////////

                if (selectedType == 1)

                  SizedBox(

                    width: double.infinity,
                    height: 58,

                    child: ElevatedButton(

                      onPressed:
                          isLoading
                              ? null
                              : makePayment,

                      style:
                          ElevatedButton.styleFrom(

                        backgroundColor:
                            Colors.blueAccent,

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  16),
                        ),
                      ),

                      child: isLoading

                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )

                          : Text(
                              "Proceed to Pay",

                              style:
                                  GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                //////////////////////////////////////////////////////
                // OFFLINE CONSULTATION
                //////////////////////////////////////////////////////

                if (selectedType == 2) ...[

                  //////////////////////////////////////////////////////
                  // PAY ONLINE
                  //////////////////////////////////////////////////////

                  SizedBox(

                    width: double.infinity,
                    height: 58,

                    child: ElevatedButton.icon(

                      onPressed:
                          isLoading
                              ? null
                              : makePayment,

                      icon: const Icon(
                        Icons.payment,
                        color: Colors.white,
                      ),

                      label: isLoading

                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )

                          : Text(
                              "Pay Online",

                              style:
                                  GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),

                      style:
                          ElevatedButton.styleFrom(

                        backgroundColor:
                            Colors.green,

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  //////////////////////////////////////////////////////
                  // PAY OFFLINE
                  //////////////////////////////////////////////////////

                  SizedBox(

                    width: double.infinity,
                    height: 58,

                    child: OutlinedButton.icon(

                      onPressed:
                          isLoading
                              ? null
                              : () async {

                                  setState(() {
                                    isLoading = true;
                                  });

                                  try {

                                    bool success =
                                        await PaymentService
                                            .createOfflinePayment(

                                      consultationId:
                                          widget.consultationId,

                                      token:
                                          widget.token,
                                    );

                                    if (!mounted) return;

                                    if (success) {

                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              BookingSuccessPage(
                                            isOfflinePayment:
                                                true,
                                            token:
                                                widget.token,
                                          ),
                                        ),
                                      );

                                    } else {

                                      ScaffoldMessenger.of(
                                              context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Failed to create offline payment",
                                            style:
                                                GoogleFonts.poppins(),
                                          ),
                                        ),
                                      );
                                    }

                                  } catch (e) {

                                    print(e);

                                    ScaffoldMessenger.of(
                                            context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Something went wrong",
                                          style:
                                              GoogleFonts.poppins(),
                                        ),
                                      ),
                                    );

                                  } finally {

                                    if (mounted) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                    }
                                  }
                                },

                      icon: const Icon(
                        Icons.local_hospital,
                        color: Colors.green,
                      ),

                      label: Text(
                        "Pay at Hospital",

                        style:
                            GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),

                      style:
                          OutlinedButton.styleFrom(

                        side: const BorderSide(
                          color: Colors.green,
                          width: 2,
                        ),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  16),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}