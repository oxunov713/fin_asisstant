import 'package:flutter/material.dart';

import '../models/models.dart';
import '../service/api_service.dart';

class CardsPage extends StatefulWidget {
  const CardsPage({super.key});

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  late Future<UserModel?> _futureUser;

  @override
  void initState() {
    super.initState();
    _futureUser = ApiService().getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cards"),
        backgroundColor: const Color(0xff00D09E),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<UserModel?>(
        future: _futureUser,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;
          final cards = user?.cards ?? [];

          if (cards.isEmpty) {
            return const Center(child: Text('No cards available'));
          }

          return PageView.builder(
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              final color = index == 0
                  ? Colors.green
                  : index == 1
                  ? Colors.blue
                  : Colors.deepPurple;
              final icon = index == 0
                  ? Icons.credit_card
                  : index == 1
                  ? Icons.payment
                  : Icons.credit_score;
              final balance = card.expenses?.fold<double>(
                  0,
                      (prev, tx) =>
                  prev +
                      (tx.amount ?? 0)) ??
                  0;

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [color.withOpacity(0.9), color.withOpacity(0.6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(icon, color: Colors.white, size: 36),
                            const SizedBox(height: 20),
                            Text(
                              card.cardType ?? 'Card',
                              style: const TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              card.cardNumber ?? '',
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "$balance so'm",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Transactions", style: Theme.of(context).textTheme.titleMedium),
                      ),
                      const SizedBox(height: 12),
                      ...?card.expenses?.map((tx) {
                        return Card(
                          child: ListTile(
                            leading: Icon(
                              (tx.amount ?? 0) > 0 ? Icons.arrow_downward : Icons.arrow_upward,
                              color: (tx.amount ?? 0) > 0 ? Colors.green : Colors.red,
                            ),
                            title: Text(tx.categoryName ?? tx.receiverName ?? 'Transaction'),
                            subtitle: tx.receiverPhoneNumber != null
                                ? Text(tx.receiverPhoneNumber!)
                                : null,
                            trailing: Text(
                              "${(tx.amount ?? 0) > 0 ? '+' : ''}${tx.amount?.toInt()} so'm",
                              style: TextStyle(
                                color: (tx.amount ?? 0) > 0 ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.face_retouching_natural),
      ),
    );
  }
}
