import 'package:flutter/material.dart';
import 'package:ebook_app_scratch/authentication/authentication.dart';
import 'package:ebook_app_scratch/authentication/login_page.dart';
import 'package:ebook_app_scratch/authentication/widgets/input_widget.dart';
import 'package:get/get.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
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
                const Text('Register Page', style: TextStyle(fontSize: 25),),
                const SizedBox(height: 30.0,),
                InputWidget(hintText: 'Name', controller: _nameController, obscureText: false),
                const SizedBox(height: 20.0,),
                InputWidget(hintText: 'UserName', controller: _userNameController, obscureText: false),
                const SizedBox(height: 20.0,),
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
                  onPressed: () async{
                    await _authenticationController.register(
                      name: _nameController.text.trim(), 
                      userName: _userNameController.text.trim(), 
                      email: _emailController.text.trim(), 
                      password: _passwordController.text.trim()
                    );
                  }, 
                  child: Obx(() {
                    return _authenticationController.isLoading.value
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                    : const Text('Register', style: TextStyle(fontSize: 18),);
                  }),
                ),
          
                const SizedBox(height: 20.0,),
          
                TextButton(
                  onPressed: () {
                    Get.to(() => const LoginPage());
                  }, 
                  child: const Text('Login', style: TextStyle(fontSize: 16),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}