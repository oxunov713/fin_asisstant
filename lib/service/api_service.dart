import 'package:dio/dio.dart';

import '../models/models.dart';

class ApiService {
  final Dio _dio = Dio();

  // Banklar ro'yxatini olish
  Future<List<BankModel>> fetchBanks() async {
    try {
      final response = await _dio.get('https://fin.maydongo.uz/api/bank/all');

      if (response.statusCode == 200) {
        // API dan kelgan har bir elementni Bank modeliga aylantiramiz
        final List bankDataList = response.data;
        return bankDataList.map((json) => BankModel.fromJson(json)).toList();
      } else {
        throw Exception("Xatolik yuz berdi: ${response.statusCode}");
      }
    } catch (e) {
      print('Error fetching banks: $e');
      throw Exception('Banklar ro\'yxatini olishda xatolik yuz berdi');
    }
  }

  Future<List<AutoLoan>> getLoans() async {
    try {
      final response = await _dio.get('https://fin.maydongo.uz/api/loan/all');

      if (response.statusCode == 200) {
        // API dan kelgan har bir elementni Bank modeliga aylantiramiz
        final List bankDataList = response.data;
        return bankDataList.map((json) => AutoLoan.fromJson(json)).toList();
      } else {
        throw Exception("Xatolik yuz berdi: ${response.statusCode}");
      }
    } catch (e) {
      print('Error fetching banks: $e');
      throw Exception('Banklar ro\'yxatini olishda xatolik yuz berdi');
    }
  }

  Future<List<AutoLoan>> getLoanByName(String name) async {
    try {
      final response = await _dio.get(
        'https://fin.maydongo.uz/api/loan/get?type=$name',
      );

      if (response.statusCode == 200) {
        final List bankDataList = response.data;
        return bankDataList.map((json) => AutoLoan.fromJson(json)).toList();
      } else {
        throw Exception("Xatolik yuz berdi: ${response.statusCode}");
      }
    } catch (e) {
      print('Error fetching banks: $e');
      throw Exception('Banklar ro\'yxatini olishda xatolik yuz berdi');
    }
  }

  Future<List<CategoryStat>> getCategory() async {
    try {
      final response = await _dio.get(
        'https://fin.maydongo.uz/api/expenses/categories/statistics/get',
      );

      if (response.statusCode == 200) {
        final List bankDataList = response.data;
        return bankDataList.map((json) => CategoryStat.fromJson(json)).toList();
      } else {
        throw Exception("Xatolik yuz berdi: ${response.statusCode}");
      }
    } catch (e) {
      print('Error fetching banks: $e');
      throw Exception('Banklar ro\'yxatini olishda xatolik yuz berdi');
    }
  }

  Future<UserModel?> getUser() async {
    try {
      final response = await _dio.get(
        'https://fin.maydongo.uz/api/user/1/get',
      ); // Masalan: /user endpoint
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Dio error: $e');
      return null;
    }
  }

  Future<UserModel?> paymentToContact(
    String name,
    String number,
    int amount,
  ) async {
    try {
      final response = await _dio.post(
        'https://fin.maydongo.uz/api/expenses/toContact',
        data: {"receiverName": name, "phoneNumber": number, "amount": amount},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
    } catch (e) {
      print('Dio error: $e');
      return null;
    }
  }
}
