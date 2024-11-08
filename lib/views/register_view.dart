import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/choose_picture_controller.dart';
import '../widgets/image_picker_options.dart';
import 'login_view.dart';
import '/services/DatabaseHelper.dart';
import '../models/user.dart';
import '/main.dart';

class RegisterView extends StatelessWidget {
  // Controladores para los campos de texto
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Función onLoginSuccess que puedes personalizar
  void _onLoginSuccess(BuildContext context, User user) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(user: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagePickerController = Provider.of<ImagePickerController>(context);

    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: Center(
        child: Container(
          width: 300,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  showImagePickerOptions(context);
                },
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Color(0xffFDCF09),
                  child: imagePickerController.image != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.file(
                      imagePickerController.image!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(50),
                    ),
                    width: 100,
                    height: 100,
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final String username = _usernameController.text;
                  final String password = _passwordController.text;
                  final String email = _emailController.text;

                  Uint8List? profilePicture;
                  if (imagePickerController.image != null) {
                    profilePicture = await imagePickerController.image!.readAsBytes();
                  }

                  final dbHelper = DatabaseHelper();
                  await dbHelper.insertUser(username, password, email, profilePicture);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Usuario registrado exitosamente")),
                  );

                  // Navegar a LoginView y pasar onLoginSuccess como parámetro
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginView(onLoginSuccess: (user) => _onLoginSuccess(context, user)),
                    ),
                  );
                },
                child: Text('Register'),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "¿Tienes una cuenta? ",
                    style: TextStyle(color: Colors.black87),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginView(onLoginSuccess: (user) => _onLoginSuccess(context, user)),
                        ),
                      );
                    },
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
