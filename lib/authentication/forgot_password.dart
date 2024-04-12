import 'package:flutter/material.dart';
import 'package:ebook_app_scratch/authentication/widgets/input_widget.dart';
import 'package:ebook_app_scratch/authentication/authentication.dart';
import 'package:get/get.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _securityNumberController = TextEditingController();
  final AuthenticationController _authenticationController = Get.put(AuthenticationController());

  bool emailsent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Forgot password page', style: TextStyle(fontSize: 25.0),),
                const SizedBox(height: 30.0,),
                InputWidget(hintText: 'Email', controller: _emailController, obscureText: false),
                const SizedBox(height: 20.0,),
          
                Visibility(
                  visible: emailsent,
                  child: Column(
                    children: [
                      
                      InputWidget(hintText: 'New password', controller: _newPasswordController, obscureText: true),
          
                      const SizedBox(height: 20.0,),
                      InputWidget(hintText: 'Confirm password', controller: _confirmPasswordController, obscureText: true), 
          
                      const SizedBox(height: 20.0,),
                      const Text("Please check your email, we sent the security number"),
                      InputWidget(hintText: 'Security number', controller: _securityNumberController, obscureText: false), 
                      const SizedBox(height: 20.0,),
                    ],
                  )
                ),
                
                Visibility(
                  visible: emailsent,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      await _authenticationController.changePassword(
                        email: _emailController.text.trim(),
                        password: _newPasswordController.text.trim(),
                        passwordConfirmation: _confirmPasswordController.text.trim(),
                        securityNumber: _securityNumberController.text.trim(),
                      );
                    }, 
                    child: Obx(() {
                      return _authenticationController.isLoading.value
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text('Change password', style: TextStyle(fontSize: 18),);
                    }),
                  ),
                ),
                            
                
                Visibility(
                  visible: !emailsent,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      await _authenticationController.forgotPassword(
                        email: _emailController.text.trim(),
                      );
                      await _checkSentEmail();
                    }, 
                    child: Obx(() {
                      return _authenticationController.isLoading.value
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text('Send', style: TextStyle(fontSize: 18),);
                    }),
                  ),
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }

  _checkSentEmail() async
  {
    emailsent = _authenticationController.emailsent.value;
    setState(() {
        emailsent = emailsent;  
      });  
  }
}