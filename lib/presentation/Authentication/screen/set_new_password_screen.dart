// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:wealth_app/constants/colors.dart';
// import 'package:wealth_app/widgets/custom_button.dart';

// class SetNewPasswordScreen extends StatefulWidget {
//   const SetNewPasswordScreen({super.key});

//   @override
//   State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
// }

// class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final newPassword = TextEditingController();
//   final confirmPassword = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               SizedBox(height: MediaQuery.of(context).size.height * 0.06),

//               // Logo
//               SvgPicture.asset(
//                 'assets/images/new_password_logo.svg',
//                 height: MediaQuery.of(context).size.height * 0.10,
//                 width: MediaQuery.of(context).size.width * 0.43,
//               ),
//               const SizedBox(height: 30),

//               // Heading
//               const Text(
//                 'Set New Password',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.mainFontColor,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               const Text(
//                 'Must be at least 8 characters',
//                 style: TextStyle(color: AppColors.placeholderColor),
//               ),
//               const SizedBox(height: 30),

//               // New Password Label
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   "New Password",
//                   style: TextStyle(
//                     color: AppColors.mainFontColor,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 6),

//               // New Password Field
//               TextFormField(
//                 controller: newPassword,
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   hintText: '********',
//                   hintStyle: TextStyle(color: AppColors.placeholderColor),
//                   filled: true,
//                   fillColor: Colors.grey.shade100,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.length < 8) {
//                     return 'Password must be at least 8 characters';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),

//               // Confirm Password Label
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   "Confirm Password",
//                   style: TextStyle(
//                     color: AppColors.mainFontColor,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 6),

//               // Confirm Password Field
//               TextFormField(
//                 controller: confirmPassword,
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   hintText: '********',
//                   hintStyle: TextStyle(color: AppColors.placeholderColor),
//                   filled: true,
//                   fillColor: Colors.grey.shade100,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value != newPassword.text) {
//                     return 'Passwords do not match';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 24),

//               // Reset Button
//               CustomButton(
//                 text: 'Reset Password',
//                 onPressed: () {
//                   if (_formKey.currentState!.validate()) {
//                     Navigator.pushNamed(context, '/dashboard');
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Please fix the errors above'),
//                       ),
//                     );
//                   }
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
