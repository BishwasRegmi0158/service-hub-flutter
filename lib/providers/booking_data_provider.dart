// BookingDataProvider
// Central place holding: the professionals list (now API-fetched PLUS
// provider-created listings from Hive), the wishlist, the cart, and —
// new — booking status management (approve/reject/cancel).

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/professional.dart';
import '../models/booking_model.dart';
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
  Box get _professionalsBox => Hive.box('professionals');
  Box get _bookingsBox => Hive.box('bookings');

  // ---------- Fetching ----------

  Future<void> fetchProfessionals() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final apiPros = await _apiService.getProfessionals(count: 40);

      // Real signed-up providers, once admin-approved, show up in the
      // catalog right alongside the RandomUser.me-seeded demo entries.
      final localPros = _professionalsBox.values
          .map((m) => Professional.fromMap(m))
          .where((p) => p.isApproved)
          .toList();

      _professionals = [...apiPros, ...localPros];
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

  // ---------- Provider's own listing ----------

  Professional? professionalForOwner(String userId) {
    final match = _professionalsBox.values
        .map((m) => Professional.fromMap(m))
        .where((p) => p.ownerUserId == userId);
    return match.isEmpty ? null : match.first;
  }

  Future<void> updateProfessional(Professional professional) async {
    await _professionalsBox.put(professional.id, professional.toMap());
    notifyListeners();
  }

  // ---------- Bookings ----------
  // (Booking creation still happens directly in booking_form_screen.dart,
  // unchanged — these are the new read/update helpers for the provider
  // and admin sides.)

  List<BookingModel> get allBookings =>
      _bookingsBox.values.map((m) => BookingModel.fromMap(m)).toList();

  List<BookingModel> bookingsForProfessional(String professionalId) {
    final list = allBookings.where((b) => b.professionalId == professionalId).toList();
    list.sort((a, b) => a.status == 'pending' ? -1 : (b.status == 'pending' ? 1 : 0));
    return list;
  }

  List<BookingModel> bookingsForUser(String? userId) =>
      allBookings.where((b) => b.userId == userId).toList();

  dynamic _keyForBookingId(String bookingId) {
    for (final key in _bookingsBox.keys) {
      final map = _bookingsBox.get(key);
      if (map != null && map['id'] == bookingId) return key;
    }
    return null;
  }

  // status: 'approved' | 'rejected' | 'cancelled' | 'completed'
  Future<void> updateBookingStatus(String bookingId, String status) async {
    final key = _keyForBookingId(bookingId);
    if (key == null) return;

    final booking = BookingModel.fromMap(_bookingsBox.get(key));
    await _bookingsBox.put(key, booking.copyWith(status: status).toMap());
    notifyListeners();
  }
}
