import 'package:expense_repository/expense_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gaxiola_final_gastos/screens/add_expense/blocs/create_categorybloc/create_category_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future getCategoryCreation(BuildContext context) {
  List<String> myCategoriesIcons = [
    'entertainment',
    'food',
    'home',
    'pet',
    'shopping',
    'tech',
    'travel'
  ];

  return showDialog(
    context: context,
    builder: (ctx) {
      bool isExpended = false;
      String iconSelected = '';
      Color categoryColor = Colors.white;
      TextEditingController categoryNameController = TextEditingController();
      TextEditingController categoryIconController = TextEditingController();
      TextEditingController categoryColorController = TextEditingController();
      bool isLoading = false;
      Category category = Category.empty;

      return BlocProvider.value(
        value: context.read<CreateCategoryBloc>(),
        child: StatefulBuilder(
          builder: (ctx, setState) {
            return BlocListener<CreateCategoryBloc, CreateCategoryState>(
              listener: (context, state) {
                if (state is CreateCategorySuccess) {
                  Navigator.pop(ctx, category);
                } else if (state is CreateCategoryLoading) {
                  setState(() {
                    isLoading = true;
                  });
                }
              },
              child: AlertDialog(
                title: const Text('Create a Category'),
                content: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: categoryNameController,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Name',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        controller: categoryIconController,
                        onTap: () {
                          setState(() {
                            isExpended = !isExpended;
                          });
                        },
                        textAlignVertical: TextAlignVertical.center,
                        readOnly: true,
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          suffixIcon: const Icon(
                            CupertinoIcons.chevron_down,
                            size: 12,
                          ),
                          fillColor: Colors.white,
                          hintText: 'Icon',
                          border: OutlineInputBorder(
                              borderRadius: isExpended
                                  ? const BorderRadius.vertical(
                                      top: Radius.circular(12))
                                  : BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                        ),
                      ),
                      isExpended
                          ? Container(
                              width: MediaQuery.of(context).size.width,
                              height: 200,
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(
                                      bottom: Radius.circular(12))),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GridView.builder(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            mainAxisSpacing: 5,
                                            crossAxisSpacing: 5),
                                    itemCount: myCategoriesIcons.length,
                                    itemBuilder: (context, int i) {
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            iconSelected = myCategoriesIcons[i];
                                          });
                                        },
                                        child: Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 3,
                                                  color: iconSelected ==
                                                          myCategoriesIcons[i]
                                                      ? Colors.green
                                                      : Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              image: DecorationImage(
                                                  image: AssetImage(
                                                      'assets/${myCategoriesIcons[i]}.png'))),
                                        ),
                                      );
                                    }),
                              ),
                            )
                          : Container(),
                      const SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        controller: categoryColorController,
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (ctx2) {
                                return AlertDialog(
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ColorPicker(
                                        pickerColor: categoryColor,
                                        onColorChanged: (value) {
                                          setState(() {
                                            categoryColor = value;
                                          });
                                        },
                                      ),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 50,
                                        child: TextButton(
                                            onPressed: () {
                                              Navigator.pop(ctx2);
                                            },
                                            style: TextButton.styleFrom(
                                                backgroundColor: Colors.black,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12))),
                                            child: const Text(
                                              'Save Color',
                                              style: TextStyle(
                                                  fontSize: 22,
                                                  color: Colors.white),
                                            )),
                                      )
                                    ],
                                  ),
                                );
                              });
                        },
                        textAlignVertical: TextAlignVertical.center,
                        readOnly: true,
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: categoryColor,
                          hintText: 'Color',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: kToolbarHeight,
                        child: isLoading == true
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : TextButton(
                                onPressed: () async {
                                  // Crear un ID único para la categoría y gasto
                                  String categoryId = const Uuid().v1();
                                  String expenseId = const Uuid().v1();

                                  setState(() {
                                    category = Category(
                                      categoryId: categoryId,
                                      name: categoryNameController.text,
                                      icon: iconSelected,
                                      color: categoryColor.value,
                                      totalExpenses:
                                          0, // Se puede agregar un valor inicial
                                    );
                                  });

                                  // Verificar si la categoría ya existe en Firestore
                                  var categorySnapshot = await FirebaseFirestore
                                      .instance
                                      .collection('categories')
                                      .where('categoryId',
                                          isEqualTo: categoryId)
                                      .get();

                                  if (categorySnapshot.docs.isEmpty) {
                                    // Si no existe, crear la categoría
                                    await FirebaseFirestore.instance
                                        .collection('categories')
                                        .add({
                                      'categoryId': categoryId,
                                      'name': category.name,
                                      'icon': category.icon,
                                      'color': category.color,
                                      'totalExpenses': category.totalExpenses,
                                    });

                                    // Crear el gasto (Expense) relacionado
                                    Expense newExpense = Expense(
                                      expenseId: expenseId,
                                      amount: 100, // Debe ser un valor entero
                                      category: category,
                                      date: DateTime.now(),
                                    );

                                    // Agregar gasto si no existe ya
                                    var expenseSnapshot =
                                        await FirebaseFirestore.instance
                                            .collection('expenses')
                                            .where('expenseId',
                                                isEqualTo: expenseId)
                                            .get();

                                    if (expenseSnapshot.docs.isEmpty) {
                                      // Agregar gasto
                                      await FirebaseFirestore.instance
                                          .collection('expenses')
                                          .add({
                                        'expenseId': expenseId,
                                        'amount': newExpense.amount,
                                        'category': newExpense.category.name,
                                        'date': newExpense.date,
                                      });
                                    }
                                  }
                                },
                                style: TextButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12))),
                                child: const Text(
                                  'Save',
                                  style: TextStyle(
                                      fontSize: 22, color: Colors.white),
                                )),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
