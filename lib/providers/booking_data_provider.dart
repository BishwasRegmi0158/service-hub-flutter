// BookingDataProvider
// Central place holding: the fetched professionals list, the wishlist
// (saved favorite professionals), and the cart (professionals queued up
// to book together, e.g. booking a painter AND an electrician for the
// same day).

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/professional.dart';
import '../models/trade.dart';
import '../services/api_service.dart';

class BookingDataProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Professional> _professionals = [];
  final List<Professional> _wishlist = [];
  final List<Professional> _cart = [];

  bool isLoading = false;
  String? errorMessage;

  List<Professional> get professionals => _professionals;
  List<Trade> get trades => Trades.all;
  List<Professional> get wishlist => _wishlist;
  List<Professional> get cart => _cart;

  double get cartTotal => _cart.fold(0.0, (sum, p) => sum + p.pricePerHour);

  Box get _wishlistBox => Hive.box('wishlist');

  // ---------- Fetching ----------

  Future<void> fetchProfessionals() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _professionals = await _apiService.getProfessionals(count: 40);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<Professional> byTrade(int tradeId) {
    return _professionals.where((p) => p.trade.id == tradeId).toList();
  }

  // ---------- Wishlist ----------

  bool isInWishlist(String id) => _wishlist.any((p) => p.id == id);

  void toggleWishlist(Professional professional) {
    if (isInWishlist(professional.id)) {
      _wishlist.removeWhere((p) => p.id == professional.id);
    } else {
      _wishlist.add(professional);
    }
    _wishlistBox.put('ids', _wishlist.map((p) => p.id).toList());
    notifyListeners();
  }

  // Restores wishlist after app restart by matching saved ids against the
  // freshly-fetched professionals list. Call after fetchProfessionals().
  void restoreWishlistFromStorage() {
    final savedIds = List<String>.from(_wishlistBox.get('ids', defaultValue: []));
    if (savedIds.isEmpty) return;

    _wishlist.clear();
    for (final id in savedIds) {
      final match = _professionals.where((p) => p.id == id);
      if (match.isNotEmpty) _wishlist.add(match.first);
    }
    notifyListeners();
  }

  // ---------- Cart ----------

  bool isInCart(String id) => _cart.any((p) => p.id == id);

  void addToCart(Professional professional) {
    if (!isInCart(professional.id)) {
      _cart.add(professional);
      notifyListeners();
    }
  }

  void removeFromCart(String id) {
    _cart.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
}
