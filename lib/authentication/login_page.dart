import 'package:flutter/material.dart';
import 'package:ebook_app_scratch/authentication/authentication.dart';
import 'package:ebook_app_scratch/authentication/forgot_password.dart';
import 'package:ebook_app_scratch/authentication/register_page.dart';
import 'package:ebook_app_scratch/authentication/widgets/input_widget.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthenticationController _authenticationController = Get.put(AuthenticationController());

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
                const Text('Login page', style: TextStyle(fontSize: 25.0),),
                const SizedBox(height: 30.0,),
                InputWidget(hintText: 'Email', controller: _emailController, obscureText: false),
                const SizedBox(height: 20.0,),
                InputWidget(hintText: 'Password', controller: _passwordController, obscureText: true),
                const SizedBox(height: 20.0,),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    await _authenticationController.login(
                      email: _emailController.text.trim(), 
                      password: _passwordController.text.trim(),
                    );
                  }, 
                  child: Obx(() {
                    return _authenticationController.isLoading.value
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text('Login', style: TextStyle(fontSize: 18),);
                  }),
                ),
                const SizedBox(height: 20.0,),
                TextButton(
                  onPressed: () {
                    Get.to(() => const RegisterPage());
                  }, 
                  child: const Text('Register', style: TextStyle(fontSize: 16),),
                ),
                const SizedBox(height: 40.0,),
                TextButton(
                  onPressed: () {
                    Get.to(() => const ForgotPassword());
                  }, 
                  child: const Align(alignment: Alignment.centerLeft, child: Text('forgot password', style: TextStyle(fontSize: 16), textAlign: TextAlign.left)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}