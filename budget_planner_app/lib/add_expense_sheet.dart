import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:budget_planner_app/app_colors.dart';

class AddExpenseSheet extends StatefulWidget {
  // Kaydet butonuna basıldığında bu fonksiyon çağrılacak ve
  // kategori ile tutarı ana ekrana gönderecek.
  final Function(String category, double amount) onSave;

  const AddExpenseSheet({super.key, required this.onSave});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _categoryController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _submit() {
    // Formdaki validasyonları kontrol et.
    if (_formKey.currentState!.validate()) {
      final category = _categoryController.text;
      final amount = double.parse(_amountController.text);

      // Ana ekrandaki onSave fonksiyonunu çağır.
      widget.onSave(category, amount);

      // Paneli kapat.
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        // Klavye açıldığında panelin yukarı itilmesi için.
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min, // İçerik kadar yer kapla.
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Add New Expense', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _categoryController,
                decoration: inputDecoration.copyWith(labelText: 'Category'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a category' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: inputDecoration.copyWith(labelText: 'Amount', prefixText: '\$ '),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Add Expense'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}