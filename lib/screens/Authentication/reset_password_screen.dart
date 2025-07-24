// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
// import 'package:wealth_app/constants/colors.dart';
// import 'package:wealth_app/widgets/custom_button.dart';

// class ResetPasswordScreen extends StatefulWidget {
//   const ResetPasswordScreen({super.key});

//   @override
//   State<ResetPasswordScreen> createState() => _OtpScreenState();
// }

// class _OtpScreenState extends State<ResetPasswordScreen> {
//   String otpCode = '';
//   late String email;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final args = ModalRoute.of(context)!.settings.arguments;
//     if (args != null && args is String) {
//       email = args;
//     } else {
//       email = 'your email';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             SizedBox(height: MediaQuery.of(context).size.height * 0.06),

//             // Logo
//             SvgPicture.asset(
//               'assets/images/otp_logo.svg',
//               height: MediaQuery.of(context).size.height * 0.10,
//               width: MediaQuery.of(context).size.width * 0.43,
//             ),
//             const SizedBox(height: 30),

//             const Text(
//               "Reset Password",
//               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               "We sent a code to $email",
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontSize: 14, color: Colors.grey),
//             ),
//             const SizedBox(height: 30),

//             // OTP Field
//             OtpTextField(
//               numberOfFields: 5,
//               borderColor: AppColors.buttonColor,
//               focusedBorderColor: AppColors.buttonColor,
//               showFieldAsBox: true,
//               fieldWidth: 40,
//               borderRadius: BorderRadius.circular(10),
//               onCodeChanged: (value) {
//                 otpCode = value;
//               },
//               onSubmit: (code) {
//                 setState(() {
//                   otpCode = code;
//                 });
//               },
//             ),

//             const SizedBox(height: 30),

//             // Verify Button
//             CustomButton(
//               text: "Verify",
//               onPressed: () {
//                 if (otpCode.length != 5) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text("Please enter a valid OTP")),
//                   );
//                   return;
//                 }

//                 if (otpCode == '12345') {
//                   Navigator.pushNamed(context, '/set-new-password');
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text("Incorrect OTP")),
//                   );
//                 }
//               },
//             ),

//             const SizedBox(height: 20),

//           //  Resent OTP
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text(
//                   "Resend OTP ",
//                   style: TextStyle(color: Colors.black),
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     ScaffoldMessenger.of(
//                       context,
//                     ).showSnackBar(const SnackBar(content: Text("OTP Resent")));
//                   },
//                   child: Text(
//                     "Click Here",
//                     style: TextStyle(
//                       color: AppColors.buttonColor,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
