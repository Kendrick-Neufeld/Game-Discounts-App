import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/choose_picture_controller.dart';
import '../widgets/image_picker_options.dart';
import 'login_view.dart';

class RegisterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Obtener el ImagePickerController
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
              // Avatar (cámara) colocado en la parte superior
              GestureDetector(
                onTap: () {
                  showImagePickerOptions(context); // Abre el selector de imagen
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
              SizedBox(height: 20), // Espacio entre el avatar y los campos de texto

              // Campos de texto para el registro
              TextField(
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(labelText: 'Apellido'),
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(labelText: 'Username'),
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 20),

              // Botón para registrar (sin imagen de perfil, solo registro)
              ElevatedButton(
                onPressed: () {
                  // Lógica de registro
                },
                child: Text('Register'),
              ),
              SizedBox(height: 20),

              // Enlace al login
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
                        MaterialPageRoute(builder: (context) => LoginView()),
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