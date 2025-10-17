import 'package:flutter/material.dart';
import 'package:budget_planner_app/add_expense_sheet.dart';
import 'package:budget_planner_app/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

// Harcama verisini modellemek için basit bir class.
class Expense {
  final String category;
  final double amount;
  final DateTime date;

  Expense({required this.category, required this.amount, required this.date});
}

class HomeScreen extends StatefulWidget {
  final double salary;
  final int payday;
  final int frequencyDays;

  const HomeScreen({super.key, required this.salary, required this.payday, required this.frequencyDays});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late double _remainingSalary;
  final List<Expense> _expenses = [];
  late AnimationController _balanceController;
  late Animation<double> _balanceAnimation;

  @override
  void initState() {
    super.initState();
    _remainingSalary = widget.salary;
    _balanceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _balanceAnimation = Tween<double>(begin: 0, end: _remainingSalary).animate(
      CurvedAnimation(parent: _balanceController, curve: Curves.easeOutCubic),
    );
    _balanceController.forward();
  }

  @override
  void dispose() {
    _balanceController.dispose();
    super.dispose();
  }

  void _openAddExpenseSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return AddExpenseSheet(onSave: _addExpense);
      },
    );
  }

  void _addExpense(String category, double amount) {
    final newExpense = Expense(
      category: category,
      amount: amount,
      date: DateTime.now(),
    );
    setState(() {
      _expenses.add(newExpense);
      final oldBalance = _remainingSalary;
      _remainingSalary -= amount;
      
      // Animate balance change
      _balanceAnimation = Tween<double>(
        begin: oldBalance,
        end: _remainingSalary,
      ).animate(CurvedAnimation(parent: _balanceController, curve: Curves.easeOutCubic));
      _balanceController.reset();
      _balanceController.forward();
    });
  }

  void _deleteExpense(int index) {
    final expenseToRemove = _expenses[index];
    setState(() {
      _expenses.removeAt(index);
      final oldBalance = _remainingSalary;
      _remainingSalary += expenseToRemove.amount;
      
      // Animate balance change
      _balanceAnimation = Tween<double>(
        begin: oldBalance,
        end: _remainingSalary,
      ).animate(CurvedAnimation(parent: _balanceController, curve: Curves.easeOutCubic));
      _balanceController.reset();
      _balanceController.forward();
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Expense deleted'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: AppColors.textPrimary,
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.accentYellow,
          onPressed: () {
            setState(() {
              _expenses.insert(index, expenseToRemove);
              final oldBalance = _remainingSalary;
              _remainingSalary -= expenseToRemove.amount;
              
              _balanceAnimation = Tween<double>(
                begin: oldBalance,
                end: _remainingSalary,
              ).animate(CurvedAnimation(parent: _balanceController, curve: Curves.easeOutCubic));
              _balanceController.reset();
              _balanceController.forward();
            });
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Calculate days until payday
  int _getDaysUntilPayday() {
    final now = DateTime.now();
    var nextPayday = DateTime(now.year, now.month, widget.payday);
    if (nextPayday.isBefore(now) || nextPayday.day < now.day) {
      nextPayday = DateTime(now.year, now.month + 1, widget.payday);
    }
    return nextPayday.difference(now).inDays + 1;
  }

  // Get appropriate icon for category
  IconData _getCategoryIcon(String category) {
    final lowerCategory = category.toLowerCase();
    if (lowerCategory.contains('food') || lowerCategory.contains('restaurant')) {
      return Icons.restaurant_rounded;
    } else if (lowerCategory.contains('transport') || lowerCategory.contains('car')) {
      return Icons.directions_car_rounded;
    } else if (lowerCategory.contains('shopping') || lowerCategory.contains('cloth')) {
      return Icons.shopping_bag_rounded;
    } else if (lowerCategory.contains('health') || lowerCategory.contains('medical')) {
      return Icons.medical_services_rounded;
    } else if (lowerCategory.contains('entertainment') || lowerCategory.contains('movie')) {
      return Icons.movie_rounded;
    } else if (lowerCategory.contains('bill') || lowerCategory.contains('utility')) {
      return Icons.receipt_long_rounded;
    } else {
      return Icons.shopping_cart_rounded;
    }
  }

  // Get appropriate color for category
  Color _getCategoryColor(String category) {
    final lowerCategory = category.toLowerCase();
    if (lowerCategory.contains('food') || lowerCategory.contains('restaurant')) {
      return Colors.orange;
    } else if (lowerCategory.contains('transport') || lowerCategory.contains('car')) {
      return Colors.blue;
    } else if (lowerCategory.contains('shopping') || lowerCategory.contains('cloth')) {
      return Colors.purple;
    } else if (lowerCategory.contains('health') || lowerCategory.contains('medical')) {
      return Colors.red;
    } else if (lowerCategory.contains('entertainment') || lowerCategory.contains('movie')) {
      return Colors.pink;
    } else if (lowerCategory.contains('bill') || lowerCategory.contains('utility')) {
      return Colors.teal;
    } else {
      return AppColors.accentRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double dailyLimit = _remainingSalary > 0 ? _remainingSalary / widget.frequencyDays : 0;
    final int daysUntilPayday = _getDaysUntilPayday();
    final double totalSpent = widget.salary - _remainingSalary;
    final double spentPercentage = widget.salary > 0 ? (totalSpent / widget.salary) : 0;
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            stretch: true,
            expandedHeight: 280.0,
            backgroundColor: AppColors.primary,
            automaticallyImplyLeading: false,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              centerTitle: false,
              title: const Text(
                'Dashboard',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              background: Container(
                padding: const EdgeInsets.only(bottom: 70, left: 24, right: 24),
                decoration: BoxDecoration(gradient: AppColors.primaryGradient),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Available Balance',
                          style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, color: Colors.white, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                '$daysUntilPayday days',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.3, end: 0),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AnimatedBuilder(
                      animation: _balanceAnimation,
                      builder: (context, child) {
                        return Text(
                          currencyFormat.format(_balanceAnimation.value),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -1,
                          ),
                        );
                      },
                    ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.3, end: 0),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: spentPercentage.clamp(0.0, 1.0),
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          spentPercentage > 0.8 ? Colors.red : AppColors.accentYellow,
                        ),
                        minHeight: 8,
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 400.ms).scaleX(begin: 0, end: 1),
                    const SizedBox(height: 8),
                    Text(
                      '${(spentPercentage * 100).toStringAsFixed(1)}% of salary spent',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 500.ms),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      title: 'Daily Limit',
                      value: currencyFormat.format(dailyLimit),
                      icon: Icons.local_fire_department_rounded,
                      color: AppColors.accentYellow,
                      gradient: LinearGradient(
                        colors: [AppColors.accentYellow.withOpacity(0.1), AppColors.accentYellow.withOpacity(0.05)],
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideX(begin: -0.2, end: 0),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      title: 'Total Spent',
                      value: currencyFormat.format(totalSpent),
                      icon: Icons.trending_up_rounded,
                      color: AppColors.expense,
                      gradient: LinearGradient(
                        colors: [AppColors.expense.withOpacity(0.1), AppColors.expense.withOpacity(0.05)],
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideX(begin: 0.2, end: 0),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                children: [
                  Text(
                    'Recent Expenses',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_expenses.length}',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 500.ms),
          ),
          _buildExpensesList(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddExpenseSheet,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 8,
        icon: const Icon(Icons.add_rounded, size: 28),
        label: const Text('Add Expense', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ).animate(onPlay: (controller) => controller.repeat())
       .shimmer(delay: 3000.ms, duration: 2000.ms, color: Colors.white.withOpacity(0.3))
       .then(delay: 1000.ms),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesList() {
    if (_expenses.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 60.0),
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  size: 80,
                  color: AppColors.textSecondary.withOpacity(0.3),
                ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
                const SizedBox(height: 16),
                const Text(
                  'No expenses yet',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
                const SizedBox(height: 8),
                const Text(
                  'Tap the button below to add your first expense',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 600.ms, delay: 300.ms),
              ],
            ),
          ),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final expense = _expenses[_expenses.length - 1 - index]; // Reverse order
            final reverseIndex = _expenses.length - 1 - index;
            return Dismissible(
              key: ValueKey(expense),
              onDismissed: (direction) {
                _deleteExpense(reverseIndex);
              },
              direction: DismissDirection.endToStart,
              background: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.expense,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24.0),
                child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(8),
                      blurRadius: 15,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(expense.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _getCategoryIcon(expense.category),
                      color: _getCategoryColor(expense.category),
                      size: 24,
                    ),
                  ),
                  title: Text(
                    expense.category,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat('MMM dd, yyyy').format(expense.date),
                      style: TextStyle(
                        color: AppColors.textSecondary.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  trailing: Text(
                    '-${NumberFormat.currency(locale: 'en_US', symbol: '\$').format(expense.amount)}',
                    style: const TextStyle(
                      color: AppColors.expense,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: (index * 50).ms).slideX(begin: 0.2, end: 0);
          },
          childCount: _expenses.length,
        ),
      ),
    );
  }
}