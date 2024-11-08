import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/choose_picture_controller.dart';
import '../services/DatabaseHelper.dart';
import '../models/user.dart';

class UserProfileView extends StatefulWidget {
  final User user;
  final Function onLogout; // Add this callback

  UserProfileView({required this.user, required this.onLogout}); // Add onLogout here

  @override
  _UserProfileViewState createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Uint8List? _profilePicture;
  bool _isPasswordVisible = false; // Variable para controlar la visibilidad

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.user.username;
    _emailController.text = widget.user.email;
    _passwordController.text = widget.user.password;
    _profilePicture = widget.user.profilePicture;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Cancel
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Confirm logout
            child: Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      widget.onLogout(); // Call the logout function
      // Replace the current screen with the LoginView and remove all previous routes
      Navigator.pushNamedAndRemoveUntil(
        context, '/login', (route) => false,
      ); // Ensure '/login' is the name of your login route
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePickerController = Provider.of<ImagePickerController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil de Usuario'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                await imagePickerController.imgFromGallery();
                setState(() {
                  _profilePicture = imagePickerController.image != null
                      ? imagePickerController.image!.readAsBytesSync()
                      : _profilePicture;
                });
              },
              child: CircleAvatar(
                radius: 55,
                backgroundImage: _profilePicture != null ? MemoryImage(_profilePicture!) : null,
                child: _profilePicture == null ? Icon(Icons.camera_alt, size: 50) : null,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Nombre de usuario'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible, // Toggle visibility
              decoration: InputDecoration(
                labelText: 'Contraseña',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible; // Toggle visibility
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final dbHelper = DatabaseHelper();
                final updatedUser = User(
                  id: widget.user.id,
                  username: _usernameController.text,
                  email: _emailController.text,
                  password: _passwordController.text,
                  profilePicture: _profilePicture,
                );

                await dbHelper.updateUser(updatedUser);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Perfil actualizado exitosamente")),
                );
                Navigator.pop(context, updatedUser);
              },
              child: Text('Guardar Cambios'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _confirmLogout, // Call the logout confirmation
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}