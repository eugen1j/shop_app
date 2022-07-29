import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const BASE_URL =
    'https://udemy-flutter-shop-app-b15d2-default-rtdb.europe-west1.firebasedatabase.app';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJSON() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
    };
  }

  Product.fromJSON(this.id, this.isFavorite, Map<String, dynamic> data)
      : title = data['title'] as String,
        description = data['description'] as String,
        price = data['price'] as double,
        imageUrl = data['imageUrl'] as String;

  Product copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? imageUrl,
    bool? isFavorite,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Future<void> toggleFavorite(String? authToken, String? userId) async {
    isFavorite = !isFavorite;
    notifyListeners();
    final url = Uri.parse('$BASE_URL/userFavourites/$userId/$id.json?auth=$authToken');

    try {
      final res = await http.put(url, body: json.encode(isFavorite));
      if (res.statusCode >= 400) {
        throw new HttpException('An error has occured!', uri: url);
      }
    } catch (error) {
      isFavorite = !isFavorite;
      notifyListeners();
      throw error;
    }
  }
}
