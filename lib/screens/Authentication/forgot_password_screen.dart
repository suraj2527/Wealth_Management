// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:wealth_app/constants/colors.dart';
// import 'package:wealth_app/constants/text_styles.dart';
// import 'package:wealth_app/widgets/custom_button.dart';

// class ForgotPasswordScreen extends StatefulWidget {
//   const ForgotPasswordScreen({super.key});

//   @override
//   State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
// }

// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
//   final emailController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               SizedBox(height: MediaQuery.of(context).size.height * 0.06),
//               SvgPicture.asset(
//                 'assets/images/forget_logo.svg',
//                 height: MediaQuery.of(context).size.height * 0.10,
//                 width: MediaQuery.of(context).size.width * 0.43,
//               ),
//               const SizedBox(height: 30),
//               const Text(
//                 "Forgot Password",
//                 style: TextStyle(fontSize: 24, fontWeight: AppTextStyle.mediumWeight),
//               ),
//               const SizedBox(height: 20),

//               // Label text
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   "Email address",
//                   style: TextStyle(color: AppColors.mainFontColor, fontWeight: FontWeight.w500),
//                 ),
//               ),
//               const SizedBox(height: 6),

//               // Email input
//               TextFormField(
//                 controller: emailController,
//                 keyboardType: TextInputType.emailAddress,
//                 decoration: InputDecoration(
//                   hintText: "yourname@gmail.com",
//                   hintStyle: TextStyle(color: AppColors.placeholderColor),
//                   filled: true,
//                   fillColor: Colors.grey.shade100,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Email is required';
//                   }
//                   if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
//                     return 'Enter a valid email';
//                   }
//                   return null;
//                 },
//               ),

//               const SizedBox(height: 24),

//               // OTP button
//               CustomButton(
//                 text: "Reset Password",
//                 onPressed: () {
//                   if (_formKey.currentState!.validate()) {
//                     Navigator.pushNamed(
//                       context,
//                       '/otp',
//                       arguments: emailController.text,
//                     );
//                   }
//                 },
//               ),

//               const SizedBox(height: 12),
//               GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     SvgPicture.asset(
//                       'assets/icons/arrow_back.svg',
//                       height: 18,
//                       width: 18,
//                       colorFilter: ColorFilter.mode(
//                         AppColors.buttonColor,
//                         BlendMode.srcIn,
//                       ),
//                     ),
//                     const SizedBox(width: 6),
//                     RichText(
//                       text: TextSpan(
//                         children: [
//                           TextSpan(
//                             text: "Back to Login ",
//                             style: TextStyle(
//                               color: Colors.black,
//                               fontSize: 14,
//                               fontWeight: FontWeight.w400,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
