// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:intl_phone_field/intl_phone_field.dart';
// import 'package:my_app/constants/app_colors.dart';
// import 'package:my_app/widgets/custom_button.dart';
// import 'package:provider/provider.dart';
// import 'package:my_app/providers/auth_provider.dart';

// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});

//   @override
//   State<SignupScreen> createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   String completePhoneNumber = '';
//   bool isPhoneValid = false;

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context);

//     return Scaffold(
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: Form(
//           key: _formKey,
//           autovalidateMode: AutovalidateMode.onUserInteraction,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               SizedBox(height: MediaQuery.of(context).size.height * 0.06),

//               // Logo
//               SvgPicture.asset(
//                 "assets/images/main_logo.svg",
//                 height: MediaQuery.of(context).size.height * 0.11,
//                 width: MediaQuery.of(context).size.width * 0.29,
//               ),
//               const SizedBox(height: 40),

//               const Text(
//                 "Create Your Account",
//                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 10),

//               // Email Field
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text("Email address", style: TextStyle(color: AppColors.mainFontColor)),
//               ),
//               const SizedBox(height: 6),
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
//                   if (value == null || value.isEmpty) return 'Email is required';
//                   if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Enter a valid email';
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 16),

//               // Password Field
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text("Password", style: TextStyle(color: AppColors.mainFontColor)),
//               ),
//               const SizedBox(height: 6),
//               TextFormField(
//                 controller: passwordController,
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   hintText: "********",
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

//               // Phone Number Field
//               Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text("Phone Number", style: TextStyle(color: AppColors.mainFontColor)),
//               ),
//               const SizedBox(height: 6),
//               IntlPhoneField(
//                 initialCountryCode: 'IN',
//                 decoration: InputDecoration(
//                   hintText: "9876543210",
//                   hintStyle: TextStyle(color: AppColors.placeholderColor),
//                   filled: true,
//                   fillColor: Colors.grey.shade100,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//                 onChanged: (phone) {
//                   completePhoneNumber = phone.completeNumber;
//                   isPhoneValid = phone.number.length == 10;
//                 },
//                 onSaved: (phone) {
//                   completePhoneNumber = phone!.completeNumber;
//                 },
//               ),

//               const SizedBox(height: 24),

//               // Button
//               CustomButton(
//                 text: "Create Account",
//                 onPressed: () async {
//                   FocusScope.of(context).unfocus();

//                   if (_formKey.currentState!.validate() && isPhoneValid) {
//                     try {
//                       await authProvider.loginWithAzure();

//                       if (authProvider.isLoggedIn) {
//                         Navigator.pushReplacementNamed(context, '/dashboard');
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('Signup failed.')),
//                         );
//                       }
//                     } catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text('Error: $e')),
//                       );
//                     }
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Please fix all required fields')),
//                     );
//                   }
//                 },
//               ),

//               const SizedBox(height: 12),

//               // Already have account
//               GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: RichText(
//                   text: TextSpan(
//                     children: [
//                       TextSpan(
//                         text: "Already have an account? ",
//                         style: TextStyle(color: AppColors.mainFontColor, fontSize: 14),
//                       ),
//                       TextSpan(
//                         text: "Sign in",
//                         style: TextStyle(color: AppColors.buttonColor, fontSize: 14, fontWeight: FontWeight.w500),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
