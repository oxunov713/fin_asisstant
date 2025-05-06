import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../service/api_service.dart';
import '../service/text_to_speech_service.dart';

// Models
class FinancialGoal {
  final String id;
  final String title;
  final double targetAmount;
  double currentAmount;
  final DateTime deadline;

  FinancialGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
  });

  void addContribution(double amount, DateTime date) {
    currentAmount += amount;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'deadline': deadline.toIso8601String(),
  };

  factory FinancialGoal.fromJson(Map<String, dynamic> json) => FinancialGoal(
    id: json['id'],
    title: json['title'],
    targetAmount: json['targetAmount'].toDouble(),
    currentAmount: json['currentAmount'].toDouble(),
    deadline: DateTime.parse(json['deadline']),
  );
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

  factory CategoryStat.fromJson(Map<String, dynamic> json) => CategoryStat(
    id: json['id'],
    name: json['name'],
    totalAmount: json['totalAmount'].toDouble(),
    averagePercentage: json['averagePercentage'].toDouble(),
  );
}

// Services

// Main Page
class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextToSpeechService _tts;

  @override
  void initState() {
    super.initState();
    _tts = TextToSpeechService();

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Dashboard'),
        actions: [
          IconButton(
            icon: Icon(_tts.isEnabled ? Icons.volume_up : Icons.volume_off),
            onPressed: () {
              setState(() {
                _tts.toggleTTS(!_tts.isEnabled);
              });
              _tts.speak(
                _tts.isEnabled
                    ? "Ovozli rejim yoqildi"
                    : "Ovozli rejim o'chirildi",
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.category)),
            Tab(icon: Icon(Icons.flag)),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [ExpensesTab(), GoalsTab()],
      ),
    );
  }
}

// Expenses Tab
class ExpensesTab extends StatefulWidget {
  const ExpensesTab({super.key});

  @override
  State<ExpensesTab> createState() => _ExpensesTabState();
}

class _ExpensesTabState extends State<ExpensesTab> {
  final TextToSpeechService _tts = TextToSpeechService();
  late Future<List<CategoryStat>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _tts.init();
    _categoriesFuture =await ApiService().getCategory();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Color _getColorForCategory(int id) {
    const colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.cyan,
    ];
    return colors[id % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<CategoryStat>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            _tts.speak("Xarajatlar ma'lumotlari yuklanmoqda");
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            _tts.speak("Xatolik yuz berdi. Iltimos, keyinroq urinib ko'ring");
            return Center(child: Text('Xatolik: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            _tts.speak("Xarajatlar toifalari topilmadi");
            return const Center(child: Text('Ma\'lumot topilmadi'));
          }

          final data = snapshot.data!;
          _tts.speak("Sizda ${data.length} ta xarajatlar toifalari mavjud");

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SizedBox(
                height: 220,
                child: GestureDetector(
                  onTap:
                      () => _tts.speak(
                        "Xarajatlar taqsimoti diagrammasi. ${data.length} ta toifa",
                      ),
                  child: PieChart(
                    PieChartData(
                      sections:
                          data.map((e) {
                            return PieChartSectionData(
                              color: _getColorForCategory(e.id),
                              value: e.totalAmount,
                              title:
                                  '${e.name}\n${e.totalAmount.toStringAsFixed(0)}',
                              showTitle: true,
                              titleStyle: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              radius: 60,
                            );
                          }).toList(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final item = data[index];
                  return GestureDetector(
                    onTap:
                        () => _tts.speak(
                          "${item.name} toifasi. "
                          "Jami xarajat ${item.totalAmount.toStringAsFixed(0)} so'm. "
                          "O'rtacha ${item.averagePercentage.toStringAsFixed(1)} foiz",
                        ),
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getColorForCategory(item.id),
                          radius: 10,
                        ),
                        title: Text(item.name),
                        trailing: Text(
                          '${item.totalAmount.toStringAsFixed(0)} so\'m',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'O\'rtacha ${item.averagePercentage.toStringAsFixed(1)}%',
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

// Goals Tab
class GoalsTab extends StatefulWidget {
  const GoalsTab({super.key});

  @override
  State<GoalsTab> createState() => _GoalsTabState();
}

class _GoalsTabState extends State<GoalsTab> {
  final List<FinancialGoal> _goals = [];
  final TextToSpeechService _tts = TextToSpeechService();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetController = TextEditingController();
  final _currentController = TextEditingController();
  DateTime? _selectedDate;
  String? _editingGoalId;

  @override
  void initState() {
    super.initState();
    _tts.init();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? goalsJson = prefs.getString('goals');
      if (goalsJson != null) {
        final List<dynamic> jsonList = jsonDecode(goalsJson);
        setState(() {
          _goals.clear();
          _goals.addAll(
            jsonList.map((e) => FinancialGoal.fromJson(e)).toList(),
          );
        });
        _tts.speak("${_goals.length} ta maqsad yuklandi");
      }
    } catch (e) {
      debugPrint('Error loading goals: $e');
    }
  }

  Future<void> _saveGoalsToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _goals.map((g) => g.toJson()).toList();
      await prefs.setString('goals', jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving goals: $e');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () => _tts.speak("Mening Maqsadlarim"),
              child: Text(
                'Mening Maqsadlarim',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ),
          ),
          Expanded(
            child:
                _goals.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.flag_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap:
                                () => _tts.speak(
                                  "Hozircha maqsadlar mavjud emas. Yangi maqsad qo'shish uchun tugmani bosing",
                                ),
                            child: Text(
                              'Hozircha maqsadlar mavjud emas',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              _tts.speak("Yangi maqsad qo'shish");
                              _showAddGoalDialog();
                            },
                            child: const Text('Yangi maqsad qo\'shish'),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: _goals.length,
                      itemBuilder: (context, index) {
                        final goal = _goals[index];
                        final progress = goal.currentAmount / goal.targetAmount;
                        final daysRemaining =
                            goal.deadline.difference(DateTime.now()).inDays;

                        return GestureDetector(
                          onTap: () {
                            _tts.speak(
                              "${goal.title}. "
                              "Joriy jamg'arma ${_formatMoney(goal.currentAmount)}. "
                              "Maqsad ${_formatMoney(goal.targetAmount)}. "
                              "Progress ${(progress * 100).toStringAsFixed(1)} foiz. "
                              "$daysRemaining kun qoldi",
                            );
                            _showAddAmountDialog(goal);
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        goal.title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Chip(
                                        label: Text(
                                          '$daysRemaining kun qoldi',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        backgroundColor:
                                            daysRemaining < 7
                                                ? Colors.red.shade100
                                                : daysRemaining < 30
                                                ? Colors.orange.shade100
                                                : Colors.green.shade100,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 10,
                                    backgroundColor: Colors.grey.shade200,
                                    color:
                                        progress >= 1
                                            ? Colors.green
                                            : Colors.blue,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatMoney(goal.currentAmount),
                                        style: TextStyle(
                                          color:
                                              progress >= 1
                                                  ? Colors.green
                                                  : Colors.blue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        _formatMoney(goal.targetAmount),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      '${(progress * 100).toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        color:
                                            progress >= 1
                                                ? Colors.green
                                                : Colors.blue,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _tts.speak("Yangi maqsad qo'shish");
          _showAddGoalDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddGoalDialog() {
    _clearForm();
    _tts.speak(
      _editingGoalId == null ? "Yangi maqsad qo'shish" : "Maqsadni tahrirlash",
    );
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              _editingGoalId == null ? 'Yangi maqsad' : 'Maqsadni tahrirlash',
            ),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Maqsad nomi',
                        border: OutlineInputBorder(),
                      ),
                      onTap: () => _tts.speak("Maqsad nomini kiriting"),
                      validator:
                          (value) =>
                              value?.isEmpty ?? true ? 'Nomini kiriting' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _targetController,
                      decoration: const InputDecoration(
                        labelText: 'Maqsad miqdori',
                        border: OutlineInputBorder(),
                        suffixText: 'so\'m',
                      ),
                      keyboardType: TextInputType.number,
                      onTap: () => _tts.speak("Maqsad miqdorini kiriting"),
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Miqdorni kiriting';
                        if (double.tryParse(value!) == null)
                          return 'Raqam kiriting';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _currentController,
                      decoration: const InputDecoration(
                        labelText: 'Joriy jamg\'arma',
                        border: OutlineInputBorder(),
                        suffixText: 'so\'m',
                      ),
                      keyboardType: TextInputType.number,
                      onTap:
                          () =>
                              _tts.speak("Joriy jamg'arma miqdorini kiriting"),
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Miqdorni kiriting';
                        if (double.tryParse(value!) == null)
                          return 'Raqam kiriting';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                        _selectedDate == null
                            ? 'Muddatni tanlang'
                            : 'Muddat: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                      ),
                      trailing: const Icon(Icons.arrow_drop_down),
                      onTap: () async {
                        _tts.speak("Maqsad muddatini tanlang");
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(
                            const Duration(days: 30),
                          ),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365 * 5),
                          ),
                        );
                        if (date != null) {
                          setState(() {
                            _selectedDate = date;
                          });
                          _tts.speak(
                            "Tanlangan muddat ${DateFormat('yyyy-MM-dd').format(date)}",
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _tts.speak("Bekor qilish");
                  Navigator.pop(context);
                },
                child: const Text('Bekor qilish'),
              ),
              ElevatedButton(
                onPressed: _saveGoal,
                child: const Text('Saqlash'),
              ),
            ],
          ),
    );
  }

  void _showAddAmountDialog(FinancialGoal goal) {
    final amountController = TextEditingController();
    _tts.speak("${goal.title} maqsadi uchun pul qo'shish");

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Pul qo'shish"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Miqdor',
                    border: OutlineInputBorder(),
                    suffixText: 'so\'m',
                  ),
                  keyboardType: TextInputType.number,
                  onTap: () => _tts.speak("Qo'shish miqdorini kiriting"),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Miqdorni kiriting';
                    if (double.tryParse(value!) == null)
                      return 'Raqam kiriting';
                    return null;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _tts.speak("Bekor qilish");
                  Navigator.pop(context);
                },
                child: const Text('Bekor qilish'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (amountController.text.isNotEmpty) {
                    final amount = double.parse(amountController.text);
                    setState(() {
                      goal.addContribution(amount, DateTime.now());
                      _saveGoalsToPrefs();
                    });
                    _tts.speak("$amount so'm qo'shildi");
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$amount so\'m qo\'shildi')),
                    );
                  }
                },
                child: const Text("Qo'shish"),
              ),
            ],
          ),
    );
  }

  void _saveGoal() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedDate == null) {
        _tts.speak("Iltimos, muddatni tanlang");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Muddatni tanlang')));
        return;
      }

      final newGoal = FinancialGoal(
        id: _editingGoalId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        targetAmount: double.parse(_targetController.text),
        currentAmount: double.parse(_currentController.text),
        deadline: _selectedDate!,
      );

      setState(() {
        if (_editingGoalId != null) {
          final index = _goals.indexWhere((g) => g.id == _editingGoalId);
          _goals[index] = newGoal;
        } else {
          _goals.add(newGoal);
        }
      });
      _saveGoalsToPrefs();
      _tts.speak(
        _editingGoalId == null ? "Yangi maqsad qo'shildi" : "Maqsad yangilandi",
      );
      Navigator.pop(context);
    }
  }

  void _clearForm() {
    _editingGoalId = null;
    _titleController.clear();
    _targetController.clear();
    _currentController.clear();
    _selectedDate = null;
  }

  String _formatMoney(double amount) {
    return NumberFormat.currency(
      locale: 'uz_UZ',
      symbol: 'so\'m',
      decimalDigits: 0,
    ).format(amount);
  }
}
