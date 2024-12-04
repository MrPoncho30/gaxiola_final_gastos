import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_repository/expense_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importa FirebaseAuth
import 'package:gaxiola_final_gastos/screens/home/login_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // Importa Google Mobile Ads

class MainScreen extends StatefulWidget {
  final List<Expense> expenses;
  const MainScreen(this.expenses, {super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late BannerAd _bannerAd;
  bool _isBannerAdLoaded = false;

  late InterstitialAd _interstitialAd;
  bool _isInterstitialAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd(); // Carga el banner
    _loadInterstitialAd(); // Carga el anuncio intersticial
  }

  @override
  void dispose() {
    super.dispose();
    _bannerAd.dispose(); // Libera el recurso del banner
    if (_isInterstitialAdLoaded) {
      _interstitialAd.dispose(); // Libera el recurso del intersticial
    }
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Reemplaza con tu ID
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
        },
      ),
    );
    _bannerAd.load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', // Reemplaza con tu ID
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() {
            _interstitialAd = ad;
            _isInterstitialAdLoaded = true;
          });
        },
        onAdFailedToLoad: (error) {
          print('Error al cargar el intersticial: $error');
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (_isInterstitialAdLoaded) {
      _interstitialAd.show();
    } else {
      print('El anuncio intersticial no está cargado');
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String userEmail = user?.email ?? 'No email';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
        child: Column(
          children: [
            // Encabezado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.yellow[700],
                          ),
                        ),
                        Icon(
                          CupertinoIcons.person_fill,
                          color: Colors.yellow[800],
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome!",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        Text(
                          userEmail,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () async {
                    _showInterstitialAd(); // Mostrar anuncio antes de cerrar sesión
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  icon: const Icon(Icons.logout),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Banner principal
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width / 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                    Theme.of(context).colorScheme.tertiary,
                  ],
                  transform: const GradientRotation(pi / 4),
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 4,
                    color: Colors.grey.shade300,
                    offset: const Offset(5, 5),
                  ),
                ],
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('expenses')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  double total = 0.0;
                  for (var doc in snapshot.data!.docs) {
                    total += doc['amount'];
                  }

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Total Balance',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '\$ ${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
            // Transacciones
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transactions',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onBackground,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.outline,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: widget.expenses.length,
                itemBuilder: (context, int i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Color(
                                            widget.expenses[i].category.color),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Image.asset(
                                      'assets/${widget.expenses[i].category.icon}.png',
                                      scale: 2,
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  widget.expenses[i].category.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "\$${widget.expenses[i].amount}.00",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('MM/dd/yyyy').format(
                                    widget.expenses[i].date,
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground
                                        .withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isBannerAdLoaded)
              SizedBox(
                height: 50,
                child: AdWidget(ad: _bannerAd),
              ),
          ],
        ),
      ),
    );
  }
}
