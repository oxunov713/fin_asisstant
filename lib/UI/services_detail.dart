import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/models.dart';

class AutoLoanOffersScreen extends StatelessWidget {
  final List<AutoLoan> loans;

  const AutoLoanOffersScreen({Key? key, required this.loans}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:BackButton(color: Colors.white,),
        title:  Text(
          loans.first.type!,
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt, color: Colors.white),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple, Colors.indigo],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: loans.length,
          itemBuilder: (context, index) {
            return _buildLoanCard(loans[index], context);
          },
        ),
      ),
    );
  }

  Widget _buildLoanCard(AutoLoan loan, BuildContext context) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bank header with logo and name
              _buildBankHeader(loan.bank!, context),
              const Divider(height: 24, color: Colors.grey),

              // Loan name and type
              Text(
                loan.loanName ?? 'Avtokredit',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              if (loan.type != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    loan.type!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ),
              const SizedBox(height: 16),

              // Loan details in a table-like format
              _buildDetailRow(
                context,
                'Kredit summasi:',
                '${_formatCurrency(loan.loanSum?.minAmount)} - ${_formatCurrency(loan.loanSum?.maxAmount)} ${loan.currency ?? 'so\'m'}',
                Icons.attach_money,
              ),
              _buildDetailRow(
                context,
                'Kredit muddati:',
                '${loan.loanTerm?.startTimeInMonths} - ${loan.loanTerm?.endTimeInMonths} oy',
                Icons.calendar_today,
              ),
              _buildDetailRow(
                context,
                'Foiz stavkasi:',
                '${loan.interestRate?.minRate}% - ${loan.interestRate?.maxRate}%',
                Icons.percent,
              ),
              _buildDetailRow(
                context,
                'Foiz to\'lovi:',
                loan.interestRate?.interestPaymentTerms ?? 'Har oy',
                Icons.payment,
              ),
              if (loan.hasDownPayment == true)
                _buildDetailRow(
                  context,
                  'Dastlabki to\'lov:',
                  'Talab qilinadi',
                  Icons.money_off,
                ),
              if (loan.collateral != null)
                _buildDetailRow(
                  context,
                  "Kredit ta'minoti:",
                  loan.collateral!,
                  Icons.security,
                ),

              // Application methods
              if (loan.applicationMethod != null &&
                  loan.applicationMethod!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ariza topshirish usullari:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children:
                            loan.applicationMethod!.map((method) {
                              return Chip(
                                label: Text(method),
                                backgroundColor: Colors.deepPurple.withOpacity(
                                  0.1,
                                ),
                                labelStyle: const TextStyle(
                                  color: Colors.deepPurple,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                ),

              // Required documents
              if (loan.requiredDocs != null && loan.requiredDocs!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ExpansionTile(
                      title: Text(
                        'Talab qilinadigan hujjatlar',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Column(
                            children:
                                loan.requiredDocs!.map((doc) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.chevron_right,
                                          size: 16,
                                          color: Colors.deepPurple,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            doc,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Action buttons
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                        side: const BorderSide(color: Colors.deepPurple),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        _showBankContacts(context, loan.bank!);
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone, size: 18),
                          SizedBox(width: 8),
                          Text('Aloqa'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        _launchWebsite(loan.bank!.website!);
                      },
                      child: const Row(spacing: 15  ,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [


                          Text('Ariza'), Icon(Icons.send, size: 18),
                        ],
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

  Widget _buildBankHeader(BankModel bank, BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.deepPurple, width: 2),
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: bank.image!,
                placeholder:
                    (context, url) => const CircularProgressIndicator(),
                errorWidget:
                    (context, url, error) => const Icon(Icons.account_balance),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bank.name!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              if (bank.officialName != null)
                Text(
                  bank.officialName!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.info_outline, color: Colors.deepPurple),
          onPressed: () {
            _showBankDetails(context, bank);
          },
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.deepPurple),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int? amount) {
    if (amount == null) return '';

    final numberStr = amount.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < numberStr.length; i++) {
      if ((numberStr.length - i) % 3 == 0 && i != 0) {
        buffer.write(' ');
      }
      buffer.write(numberStr[i]);
    }

    return buffer.toString();
  }

  void _showBankContacts(BuildContext context, BankModel bank) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ContactBottomSheet(bank: bank),
        );
      },
    );
  }

  void _showBankDetails(BuildContext context, BankModel bank) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: BankDetailsBottomSheet(bank: bank),
        );
      },
    );
  }

  Future<void> _launchWebsite(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  void _showFilterDialog() {
    // Implement filter dialog
  }
}

class ContactBottomSheet extends StatelessWidget {
  final BankModel bank;

  const ContactBottomSheet({Key? key, required this.bank}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.deepPurple, width: 3),
              ),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: bank.image!,
                    placeholder:
                        (context, url) => const CircularProgressIndicator(),
                    errorWidget:
                        (context, url, error) =>
                            const Icon(Icons.account_balance, size: 40),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              bank.name!,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Aloqa uchun:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 12),
          ...bank.supportPhoneNumbers!.map<Widget>((phone) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.phone, size: 20, color: Colors.deepPurple),
                    const SizedBox(width: 12),
                    Expanded(child: Text(phone)),
                    IconButton(
                      icon: const Icon(Icons.copy, color: Colors.grey),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: phone));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Telefon raqam nusxalandi'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.phone_forwarded,
                        color: Colors.deepPurple,
                      ),
                      onPressed: () {
                        launch('tel:$phone');
                      },
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 12),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: const Icon(Icons.email, color: Colors.deepPurple),
              title: Text(bank.email!),
              onTap: () {
                launch('mailto:${bank.email}');
              },
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: const Icon(Icons.language, color: Colors.deepPurple),
              title: Text(bank.website!),
              onTap: () {
                launch(bank.website!);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class BankDetailsBottomSheet extends StatelessWidget {
  final BankModel bank;

  const BankDetailsBottomSheet({Key? key, required this.bank})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.deepPurple, width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: bank.image!,
                          placeholder:
                              (context, url) =>
                                  const CircularProgressIndicator(),
                          errorWidget:
                              (context, url, error) =>
                                  const Icon(Icons.account_balance, size: 50),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    bank.name!,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                if (bank.officialName != null)
                  Center(
                    child: Text(
                      bank.officialName!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Exchange rates if available
                if (bank.exchangeRates != null &&
                    bank.exchangeRates!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Valyuta kurslari:',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Table(
                            border: TableBorder.symmetric(
                              inside: const BorderSide(color: Colors.grey),
                            ),
                            children: [
                              TableRow(
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple.withOpacity(0.1),
                                ),
                                children: [
                                  _buildTableHeader('Valyuta'),
                                  _buildTableHeader('Sotib olish'),
                                  _buildTableHeader('Sotish'),
                                ],
                              ),
                              ...bank.exchangeRates!.map((rate) {
                                return TableRow(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                  ),
                                  children: [
                                    _buildTableCell(rate.currency ?? ''),
                                    _buildTableCell(
                                      rate.toBuy?.toStringAsFixed(2) ?? '',
                                    ),
                                    _buildTableCell(
                                      rate.toSell?.toStringAsFixed(2) ?? '',
                                    ),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),

                // Contact information
                Text(
                  'Aloqa ma\'lumotlari:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 12),
                ...bank.supportPhoneNumbers!.map((phone) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            size: 20,
                            color: Colors.deepPurple,
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(phone)),
                          IconButton(
                            icon: const Icon(
                              Icons.phone_forwarded,
                              color: Colors.deepPurple,
                            ),
                            onPressed: () {
                              launch('tel:$phone');
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.email, color: Colors.deepPurple),
                    title: Text(bank.email!),
                    onTap: () {
                      launch('mailto:${bank.email}');
                    },
                  ),
                ),
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.language,
                      color: Colors.deepPurple,
                    ),
                    title: Text(bank.website!),
                    onTap: () {
                      launch(bank.website!);
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Action buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      launch(bank.website!);
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.open_in_browser),
                        SizedBox(width: 8),
                        Text('Rasmiy vebsaytga o\'tish'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.deepPurple,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
