import 'package:flutter/material.dart';
import 'chart.dart'; // Asegúrate de importar el archivo correcto

class StatScreen extends StatelessWidget {
  const StatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos de las categorías y gastos (esto puede venir de tu base de datos o lógica de negocio)
    final Map<String, double> categoryExpenses = {
      'Food': 200.0,
      'Transport': 0.0,
      'Entertainment': 150.0,
      'Bills': 400.0,
      'Shopping': 0.0,
    };

    // Filtramos las categorías y gastos que tengan un valor mayor que 0
    final filteredCategories = <String>[];
    final filteredExpenses = <double>[];
    final filteredCategoryIcons = <IconData>[];

    // Asumimos que los íconos son iguales al orden de las categorías
    final categoryIcons = {
      'Food': Icons.fastfood,
      'Transport': Icons.directions_car,
      'Entertainment': Icons.movie,
      'Bills': Icons.account_balance_wallet,
      'Shopping': Icons.shopping_cart,
    };

    categoryExpenses.forEach((category, expense) {
      if (expense > 0) {
        // Solo agregar categorías con gastos mayores que 0
        filteredCategories.add(category);
        filteredExpenses.add(expense);
        filteredCategoryIcons.add(categoryIcons[category]!);
      }
    });

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transactions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
                child: MyChart(
                  categories: filteredCategories, // Usamos los datos filtrados
                  expenses: filteredExpenses,
                  categoryIcons:
                      filteredCategoryIcons, // Usamos los íconos filtrados
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
