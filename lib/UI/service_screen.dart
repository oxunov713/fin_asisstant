import 'package:flutter/material.dart';
import 'package:my_fin_asisstant/UI/services_detail.dart';
import 'package:my_fin_asisstant/models/models.dart';
import 'package:my_fin_asisstant/service/api_service.dart';
import 'package:my_fin_asisstant/service/text_to_speech_service.dart';

class ServicesSection extends StatefulWidget {
  const ServicesSection({super.key});

  @override
  _ServicesSectionState createState() => _ServicesSectionState();
}

class _ServicesSectionState extends State<ServicesSection> {
  late Future<List<AutoLoan>> loanList;
  final _tts = TextToSpeechService();

  @override
  void initState() {
    super.initState();
    loanList = fetchLoans();
  }

  Future<List<AutoLoan>> fetchLoans() async {
    return await ApiService().getLoans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Xizmatlar",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<AutoLoan>>(
        future: loanList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Xatolik: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Ma\'lumot mavjud emas'));
          } else {
            List<AutoLoan> loans = snapshot.data!;

            return GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: loans.length,
              itemBuilder: (context, index) {
                AutoLoan loan = loans[index];
                return ServiceCard(
                  icon: _getServiceIcon(loan.type!),
                  title: loan.type!,
                  onTap: () {
                    _tts.speak(loan.type!); // Speak the service type
                    _navigateToDetail(context, loan.type!);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  IconData _getServiceIcon(String serviceType) {
    switch (serviceType.toLowerCase()) {
      case 'avtokredit':
        return Icons.directions_car;
      case 'ipoteka':
        return Icons.home;
      case 'ta\'lim krediti':
        return Icons.school;
      case 'ishlab chiqarish krediti':
        return Icons.factory;
      default:
        return Icons.attach_money;
    }
  }

  void _navigateToDetail(BuildContext context, String serviceName) async {
    final loans = await ApiService().getLoanByName(serviceName);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AutoLoanOffersScreen(loans: loans),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final double iconSize;
  final double textSize;
  final double padding;

  const ServiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconSize = 40,
    this.textSize = 14,
    this.padding = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: iconSize, color: Theme.of(context).primaryColor),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: textSize,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}