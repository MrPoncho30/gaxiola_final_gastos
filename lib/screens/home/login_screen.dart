import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gaxiola_final_gastos/screens/home/blocs/get_expenses_bloc/get_expenses_bloc.dart';
import 'package:gaxiola_final_gastos/screens/home/views/home_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_repository/expense_repository.dart'; // Asegúrate de tener el repo adecuado
import 'package:google_mobile_ads/google_mobile_ads.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  late BannerAd _bannerAd;
  bool _isBannerAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _bannerAd.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId:
          'ca-app-pub-3940256099942544/6300978111', // Reemplaza con tu ID de anuncio
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          print('Error al cargar el banner: $error');
          ad.dispose();
          setState(() {
            _isBannerAdLoaded = false;
          });
        },
      ),
    );
    _bannerAd.load();
  }

  // Función para manejar el inicio de sesión
  Future<void> _login() async {
    setState(() {
      _isLoading = true; // Mostrar indicador de carga
    });

    try {
      // Intentar autenticar al usuario
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Navegar a MyAppView con BlocProvider y obtener los gastos
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Expense Tracker",
            theme: ThemeData(
              colorScheme: ColorScheme.light(
                background: Colors.grey.shade100,
                onBackground: Colors.black,
                primary: const Color(0xFF00B2E7),
                secondary: const Color(0xFFE064F7),
                tertiary: const Color(0xFFFF8D6C),
                outline: Colors.grey,
              ),
            ),
            home: BlocProvider(
              create: (context) => GetExpensesBloc(
                FirebaseExpenseRepo(),
              )..add(GetExpenses()), // Aquí solicitamos los gastos
              child: const HomeScreen(),
            ),
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = "Usuario no encontrado.";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Contraseña incorrecta.";
      } else {
        errorMessage = e.message ?? "Ocurrió un error.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      setState(() {
        _isLoading = false; // Ocultar indicador de carga
      });
    }
  }

  // Función para registrar un nuevo usuario
  Future<void> _register() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Register New User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar el diálogo
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                _isLoading = true; // Mostrar indicador de carga
              });

              try {
                // Intentar registrar al nuevo usuario
                //QUIERO DORMIR
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: _emailController.text.trim(),
                  password: _passwordController.text.trim(),
                );

                Navigator.pop(context); // Cerrar el diálogo
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Registro exitoso')),
                );
              } on FirebaseAuthException catch (e) {
                String errorMessage = e.message ?? "Ocurrió un error.";
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(errorMessage)),
                );
              } finally {
                setState(() {
                  _isLoading = false; // Ocultar indicador de carga
                });
              }
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _login,
                          child: const Text("Login"),
                        ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: _register,
                    child: const Text(
                      'No account? Register here',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isBannerAdLoaded)
            Container(
              height: _bannerAd.size.height.toDouble(),
              width: _bannerAd.size.width.toDouble(),
              child: AdWidget(ad: _bannerAd),
            ),
        ],
      ),
    );
  }
}
