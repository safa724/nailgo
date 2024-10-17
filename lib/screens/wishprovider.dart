import 'package:flutter/material.dart';
import 'package:nailgonew/data_model/product_mini_response.dart';

class WishlistProvider extends ChangeNotifier {
  List<Product> _wishlist = [];

  List<Product> get wishlist => _wishlist;

  void addToWishlist(Product product) {
    _wishlist.add(product);
    notifyListeners();
  }

  void removeFromWishlist(Product product) {
    _wishlist.remove(product);
    notifyListeners();
  }
}
