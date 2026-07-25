// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Expense _$ExpenseFromJson(Map<String, dynamic> json) => _Expense(
  id: json['_id'] as String,
  title: json['title'] as String,
  amount: (json['amount'] as num).toDouble(),
  currency: json['currency'] as String? ?? 'INR',
  category: json['category'] as String? ?? 'Other',
  date: DateTime.parse(json['date'] as String),
);

Map<String, dynamic> _$ExpenseToJson(_Expense instance) => <String, dynamic>{
  '_id': instance.id,
  'title': instance.title,
  'amount': instance.amount,
  'currency': instance.currency,
  'category': instance.category,
  'date': instance.date.toIso8601String(),
};
