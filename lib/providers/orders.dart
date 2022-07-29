import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import './cart.dart';
import 'dart:convert';
import './product.dart';

const BASE_URL =
    'https://udemy-flutter-shop-app-b15d2-default-rtdb.europe-west1.firebasedatabase.app';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  Object toJSON() {
    return {
      'amount': amount,
      'products': products.map((p) => p.toJSON()).toList(),
      'dateTime': dateTime.toIso8601String(),
    };
  }

  OrderItem.fromJSON(this.id, Map<String, dynamic> data)
      : amount = data['amount'] as double,
        products = (data['products'] as List<dynamic>)
            .map((p) => CartItem.fromJSON(p))
            .toList(),
        dateTime = DateTime.parse(data['dateTime']);

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });

  OrderItem copyWith({
    String? id,
    double? amount,
    List<CartItem>? products,
    DateTime? dateTime,
  }) {
    return OrderItem(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      products: products ?? this.products,
      dateTime: dateTime ?? this.dateTime,
    );
  }
}

class Orders with ChangeNotifier {
  final String? authToken;
  final String? userId;
  List<OrderItem> _orders = [];

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final orderItem = OrderItem(
      id: '',
      amount: total,
      products: cartProducts,
      dateTime: DateTime.now(),
    );

    final url = Uri.parse('$BASE_URL/order/$userId.json?auth=$authToken');

    final res = await http.post(url, body: json.encode(orderItem.toJSON()));

    final data = json.decode(res.body);
    final newOrder = orderItem.copyWith(id: data['name']);
    _orders.insert(0, newOrder);
    notifyListeners();
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse('$BASE_URL/order/$userId.json?auth=$authToken');

    final res = await http.get(url);
    final data = json.decode(res.body);
    if (data != null) {
      _orders = (data as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, OrderItem.fromJSON(key, value)))
          .values
          .toList()
          .reversed
          .toList();
    }

    notifyListeners();
  }
}
