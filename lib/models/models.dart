class ExchangeRate {
  final String? currency;
  final double? toBuy;
  final double? toSell;

  ExchangeRate({this.currency, this.toBuy, this.toSell});

  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    return ExchangeRate(
      currency: json['currency'],
      toBuy: (json['toBuy'] as num?)?.toDouble(),
      toSell: (json['toSell'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'currency': currency, 'toBuy': toBuy, 'toSell': toSell};
  }
}

class BankModel {
  final int? id;
  final String? name;
  final String? image;
  final String? officialName;
  final String? email;
  final List<String>? supportPhoneNumbers;
  final String? website;
  final List<ExchangeRate>? exchangeRates;

  BankModel({
    this.id,
    this.name,
    this.image,
    this.officialName,
    this.email,
    this.supportPhoneNumbers,
    this.website,
    this.exchangeRates,
  });

  factory BankModel.fromJson(Map<String, dynamic> json) {
    return BankModel(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      officialName: json['officialName'],
      email: json['email'],
      supportPhoneNumbers:
          json['supportPhoneNumbers'] != null
              ? List<String>.from(json['supportPhoneNumbers'])
              : null,
      website: json['website'],
      exchangeRates:
          json['exchangeRates'] != null
              ? (json['exchangeRates'] as List)
                  .map((e) => ExchangeRate.fromJson(e))
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'officialName': officialName,
      'email': email,
      'supportPhoneNumbers': supportPhoneNumbers,
      'website': website,
      'exchangeRates': exchangeRates?.map((e) => e.toJson()).toList(),
    };
  }
}

class LoanTerm {
  final int? startTimeInMonths;
  final int? endTimeInMonths;

  LoanTerm({this.startTimeInMonths, this.endTimeInMonths});

  factory LoanTerm.fromJson(Map<String, dynamic> json) {
    return LoanTerm(
      startTimeInMonths: json['startTimeInMonths'],
      endTimeInMonths: json['endTimeInMonths'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTimeInMonths': startTimeInMonths,
      'endTimeInMonths': endTimeInMonths,
    };
  }
}

class LoanSum {
  final int? minAmount;
  final int? maxAmount;

  LoanSum({this.minAmount, this.maxAmount});

  factory LoanSum.fromJson(Map<String, dynamic> json) {
    return LoanSum(minAmount: json['minAmount'], maxAmount: json['maxAmount']);
  }

  Map<String, dynamic> toJson() {
    return {'minAmount': minAmount, 'maxAmount': maxAmount};
  }
}

class InterestRate {
  final double? minRate;
  final double? maxRate;
  final String? interestPaymentTerms;

  InterestRate({this.minRate, this.maxRate, this.interestPaymentTerms});

  factory InterestRate.fromJson(Map<String, dynamic> json) {
    return InterestRate(
      minRate: json['minRate'],
      maxRate: json['maxRate'],
      interestPaymentTerms: json['interestPaymentTerms'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'minRate': minRate,
      'maxRate': maxRate,
      'interestPaymentTerms': interestPaymentTerms,
    };
  }
}

class AutoLoan {
  final int? id;
  final String? loanName;
  final String? type;
  final BankModel? bank;
  final List<String>? applicationMethod;
  final String? currency;
  final LoanTerm? loanTerm;
  final LoanSum? loanSum;
  final InterestRate? interestRate;
  final bool? hasDownPayment;
  final String? collateral;
  final List<String>? requiredDocs;

  AutoLoan({
    this.id,
    this.loanName,
    this.type,
    this.bank,
    this.applicationMethod,
    this.currency,
    this.loanTerm,
    this.loanSum,
    this.interestRate,
    this.hasDownPayment,
    this.collateral,
    this.requiredDocs,
  });

  factory AutoLoan.fromJson(Map<String, dynamic> json) {
    return AutoLoan(
      id: json['id'],
      loanName: json['loanName'],
      type: json['type'],
      bank: json['bank'] != null ? BankModel.fromJson(json['bank']) : null,
      applicationMethod:
          json['applicationMethod'] != null
              ? List<String>.from(json['applicationMethod'])
              : null,
      currency: json['currency'],
      loanTerm:
          json['loanTerm'] != null ? LoanTerm.fromJson(json['loanTerm']) : null,
      loanSum:
          json['loanSum'] != null ? LoanSum.fromJson(json['loanSum']) : null,
      interestRate:
          json['interestRate'] != null
              ? InterestRate.fromJson(json['interestRate'])
              : null,
      hasDownPayment: json['hasDownPayment'],
      collateral: json['collateral'],
      requiredDocs:
          json['requiredDocs'] != null
              ? List<String>.from(json['requiredDocs'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'loanName': loanName,
      'type': type,
      'bank': bank?.toJson(),
      'applicationMethod': applicationMethod,
      'currency': currency,
      'loanTerm': loanTerm?.toJson(),
      'loanSum': loanSum?.toJson(),
      'interestRate': interestRate?.toJson(),
      'hasDownPayment': hasDownPayment,
      'collateral': collateral,
      'requiredDocs': requiredDocs,
    };
  }
}

class CategoryStat {
  final int id;
  final String name;
  final double totalAmount;
  final double averagePercentage;

  CategoryStat({
    required this.id,
    required this.name,
    required this.totalAmount,
    required this.averagePercentage,
  });

  factory CategoryStat.fromJson(Map<String, dynamic> json) {
    return CategoryStat(
      id: json['id'] as int,
      name: json['name'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      averagePercentage: (json['averagePercentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'totalAmount': totalAmount,
      'averagePercentage': averagePercentage,
    };
  }
}

class FinancialGoal {
  final String id;
  final String title;
  double targetAmount;
  double currentAmount;
  final DateTime deadline;
  List<Contribution> contributions; // O'zgartirildi - final olib tashlandi

  FinancialGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    List<Contribution>? contributions, // Optional qilindi
  }) : contributions = contributions ?? []; // Default bo'sh ro'yxat

  void addContribution(double amount, DateTime date) {
    contributions = List.from(contributions)
      ..add(Contribution(amount: amount, date: date));
    currentAmount += amount;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'deadline': deadline.toIso8601String(),
    'contributions': contributions.map((c) => c.toJson()).toList(),
  };

  factory FinancialGoal.fromJson(Map<String, dynamic> json) => FinancialGoal(
    id: json['id'],
    title: json['title'],
    targetAmount: json['targetAmount'],
    currentAmount: json['currentAmount'],
    deadline: DateTime.parse(json['deadline']),
    contributions:
        (json['contributions'] as List?)
            ?.map((c) => Contribution.fromJson(c))
            .toList() ??
        [], // Null safe qilindi
  );
}

class Contribution {
  final double amount;
  final DateTime date;

  Contribution({required this.amount, required this.date});

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'date': date.toIso8601String(),
  };

  factory Contribution.fromJson(Map<String, dynamic> json) =>
      Contribution(amount: json['amount'], date: DateTime.parse(json['date']));
}

class Expense {
  final String? type;
  final double amount;
  final String? categoryName;
  final String? receiverCardNumber;
  final String? receiverName;
  final String? receiverPhoneNumber;

  Expense({
    this.type,
    required this.amount,
    this.categoryName,
    this.receiverCardNumber,
    this.receiverName,
    this.receiverPhoneNumber,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      type: json['type'],
      amount: json['amount'],
      categoryName: json['categoryName'],
      receiverCardNumber: json['receiverCardNumber'],
      receiverName: json['receiverName'],
      receiverPhoneNumber: json['receiverPhoneNumber'],
    );
  }
}

class CardModel {
  final int id;
  final String cardType;
  final String cardNumber;
  final List<Expense> expenses;

  CardModel({
    required this.id,
    required this.cardType,
    required this.cardNumber,
    required this.expenses,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'],
      cardType: json['cardType'],
      cardNumber: json['cardNumber'],
      expenses:
          (json['expenses'] as List)
              .map((expense) => Expense.fromJson(expense))
              .toList(),
    );
  }
}

class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final List<CardModel> cards;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.cards,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      cards:
          (json['cards'] as List)
              .map((card) => CardModel.fromJson(card))
              .toList(),
    );
  }
}
