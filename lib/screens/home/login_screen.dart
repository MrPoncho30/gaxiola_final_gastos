import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './views/home_screen.dart'; // Página de inicio después de un login exitoso

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;

  // Función para iniciar sesión con correo electrónico y contraseña
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    // Validar que los campos no estén vacíos
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa todos los campos')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Inicia sesión con Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Si el login es exitoso, redirige a la pantalla principal
      if (userCredential.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ), // Página de inicio
        );
        // Limpiar los campos
        _emailController.clear();
        _passwordController.clear();
      }
    } catch (e) {
      // Mostrar el error específico si ocurre
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 50),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Login'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                // Aquí puedes agregar la lógica para ir a la pantalla de registro
              },
              child: const Text('No tienes una cuenta? Regístrate'),
            ),
          ],
        ),
      ),
    );
  }
}
