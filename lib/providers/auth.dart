import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

const KEY = 'AIzaSyD9Uybwci53RVQmGSYRK_RlktWBuJH5eMI';
const BASE_URL = 'https://identitytoolkit.googleapis.com/v1';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  Timer? _authTimer;

  bool get isAuth {
    return _token != null;
  }

  String? get userId {
    return _userId;
  }

  String? get token {
    if (_expiryDate?.isAfter(DateTime.now()) ?? false) {
      return _token;
    }
    return null;
  }

  Future<void> logout() async {
    _authTimer?.cancel();
    _authTimer = null;
    _token = null;
    _userId = null;
    _expiryDate = null;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
  }

  void _autoLogout() {
    _authTimer?.cancel();

    final expiryInSeconds =
        _expiryDate?.difference(DateTime.now()).inSeconds ?? 0;
    _authTimer = Timer(Duration(seconds: expiryInSeconds), () => logout());
  }

  Future<void> _authenticate(
      String email, String password, String method) async {
    final url = Uri.parse('${BASE_URL}/accounts:${method}?key=${KEY}');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      final data = jsonDecode(response.body);
      if (data['error'] != null) {
        throw HttpException(data['error']['message'] ?? '');
      }
      _token = data['idToken'];
      _userId = data['localId'];
      _expiryDate = DateTime.now().add(
        Duration(seconds: int.parse(data['expiresIn'])),
      );
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = jsonEncode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate?.toIso8601String(),
      });
      await prefs.setString('userData', userData);

    } catch (error) {
      throw error;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.delayed(Duration(seconds: 1));

    try {
      final userDataStr = await prefs.getString('userData');
      final userData = jsonDecode(userDataStr!);

      final expiryDate = DateTime.parse(userData['expiryDate']);
      final userId = userData['userId'];
      final token = userData['token'];

      if (expiryDate.isBefore(DateTime.now()) || userId == null || token == null) {
        return false;
      }

      _userId = userId;
      _token = token;
      _expiryDate = expiryDate;
      notifyListeners();
      _autoLogout();

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> signup(String email, String password) async {
    return await _authenticate(email, password, 'signUp');
  }

  Future<void> signIn(String email, String password) async {
    return await _authenticate(email, password, 'signInWithPassword');
  }
}
