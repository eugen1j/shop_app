import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    required this.id,
    required this.title,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'title': title,
      'quantity': quantity,
      'price': price,
    };
  }

  CartItem.fromJSON(Map<String, dynamic> data)
      : id = data['id'] as String,
        title = data['title'] as String,
        price = data['price'] as double,
        quantity = data['quantity'] as int;
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.values.fold(0, (acc, item) => acc + item.quantity);
  }

  double get totalAmount {
    return _items.values
        .fold(0, (acc, item) => acc + item.price * item.quantity);
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    final qty = _items[productId]?.quantity;

    if (qty == null) {
      return;
    } else if (qty > 1) {
      _items.update(
        productId,
        (c) => CartItem(
          id: c.id,
          title: c.title,
          quantity: c.quantity - 1,
          price: c.price,
        ),
      );
    } else {
      // 1 or 0
      _items.remove(productId);
    }
    notifyListeners();
  }

  void addItem(String productId, double price, String title) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (value) => CartItem(
          id: value.id,
          title: value.title,
          quantity: value.quantity + 1,
          price: value.price,
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: DateTime.now().toString(),
          title: title,
          quantity: 1,
          price: price,
        ),
      );
    }

    notifyListeners();
  }
}
