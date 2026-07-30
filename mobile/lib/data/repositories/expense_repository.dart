import '../../models/expense.dart';
import '../app_exception.dart';
import '../api_client.dart';

class ExpenseRepository {
  ExpenseRepository(this._client);

  final ApiClient _client;

  String _base(String userId, String tripId) => '/trips/$tripId/expenses';

  Future<Expense> addExpense({
    required String userId,
    required String tripId,
    required String title,
    required double amount,
    String currency = 'INR',
    String category = 'Other',
    DateTime? date,
  }) async {
    final response = await _client.post(_base(userId, tripId), data: {
      'title': title,
      'amount': amount,
      'currency': currency,
      'category': category,
      'date': (date ?? DateTime.now()).toIso8601String(),
    });
    if (response['success'] == false) {
      throw AppException(response['message'] as String? ?? 'Error adding expense');
    }
    return Expense.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> updateExpense({
    required String userId,
    required String tripId,
    required String expenseId,
    required String title,
    required double amount,
    String currency = 'INR',
    String category = 'Other',
  }) async {
    final response = await _client.put('${_base(userId, tripId)}/$expenseId', data: {
      'title': title,
      'amount': amount,
      'currency': currency,
      'category': category,
    });
    if (response['success'] == false) {
      throw AppException(response['message'] as String? ?? 'Error updating expense');
    }
  }

  Future<void> deleteExpense({
    required String userId,
    required String tripId,
    required String expenseId,
  }) async {
    final response = await _client.delete('${_base(userId, tripId)}/$expenseId');
    if (response['success'] == false) {
      throw AppException(response['message'] as String? ?? 'Error deleting expense');
    }
  }
}
