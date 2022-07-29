import 'package:flutter/material.dart';
import './product.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

const BASE_URL =
    'https://udemy-flutter-shop-app-b15d2-default-rtdb.europe-west1.firebasedatabase.app';

class Products with ChangeNotifier {
  final String? authToken;
  final String? userId;
  List<Product> _items = [];

  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    return [..._items];
  }

  Future<void> fetchAndSetProducts({bool filterByUser = false}) async {
    final filterString = filterByUser ? 'orderBy="userId"&equalTo="$userId"' : '';
    final url = Uri.parse('$BASE_URL/product.json?auth=$authToken&$filterString');

    final res = await http.get(url);
    final data = json.decode(res.body);

    if (data != null) {
      final favoriteUrl =
          Uri.parse('$BASE_URL/userFavourites/$userId.json?auth=$authToken');
      final favoriteResponse = await http.get(favoriteUrl);
      final favoriteData = jsonDecode(favoriteResponse.body) ?? {};

      _items = (data as Map<String, dynamic>)
          .map(
            (key, value) => MapEntry(
              key,
              Product.fromJSON(
                key,
                favoriteData[key] ?? false,
                value,
              ),
            ),
          )
          .values
          .toList();
    }

    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse('$BASE_URL/product.json?auth=$authToken');

    try {
      final responseData = product.toJSON();
      responseData["userId"] = userId;

      final res = await http.post(url, body: json.encode(responseData));

      final data = json.decode(res.body);
      final newProduct = product.copyWith(id: data['name']);
      _items.insert(0, newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Product? findById(String id) {
    return _items.firstWhere((p) => p.id == id);
  }

  List<Product> get favoriteItems {
    return _items.where((p) => p.isFavorite).toList();
  }

  Future<void> editProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((item) => item.id == id);

    if (prodIndex >= 0) {
      final url = Uri.parse('$BASE_URL/product/$id.json?auth=$authToken');
      await http.patch(url, body: json.encode(newProduct.toJSON()));

      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {}
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse('$BASE_URL/product/$id.json?auth=$authToken');
    final existingProductIdx = _items.indexWhere((item) => item.id == id);
    final existingProduct = _items[existingProductIdx];
    _items.removeAt(existingProductIdx);
    notifyListeners();

    try {
      final res = await http.delete(url);
      if (res.statusCode >= 400) {
        throw HttpException('Could not delete product');
      }
    } catch (error) {
      _items.insert(existingProductIdx, existingProduct);
      notifyListeners();
      throw error;
    }
  }
}
