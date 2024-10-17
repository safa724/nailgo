import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nailgonew/screens/wishprovider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WishlistScreen extends StatefulWidget {
  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  Future<List<Product>> fetchWishlistItems() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String accessToken = prefs.getString('accessToken') ?? '';

      final response = await http.get(
        Uri.parse('http://nailgo.ae/api/v2/wishlists'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('Raw response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        return data.map((item) => Product.fromJson(item['product'])).toList();
      } else {
        throw Exception('Failed to load wishlist items');
      }
    } catch (e) {
      print('Error fetching wishlist items: $e');
      throw Exception('Failed to load wishlist items');
    }
  }

  Future<void> _toggleWishlist(
      BuildContext context, int productId, bool isAddedToWishlist) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('userId') ?? '';
      String accessToken = prefs.getString('accessToken') ?? '';

      final url = Uri.http(
          'nailgo.ae',
          isAddedToWishlist
              ? '/api/v2/wishlists-remove-product'
              : '/api/v2/wishlists-add-product',
          {
            'product_id': productId.toString(),
            'user_id': userId,
          });

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        print(
            'Product ${isAddedToWishlist ? 'removed from' : 'added to'} wishlist');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isAddedToWishlist
                ? 'Failed to remove product from wishlist'
                : 'Failed to add product to wishlist'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('wish'.tr()),
      ),
      body: FutureBuilder<List<Product>>(
        future: fetchWishlistItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
              color: Color.fromARGB(255, 185, 92, 4),
              strokeWidth: 1,
            ));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final List<Product> wishlistItems = snapshot.data!;
            return Consumer<WishlistProvider>(
              builder: (context, wishlistProvider, _) {
                return ListView.builder(
                  itemCount: wishlistItems.length,
                  itemBuilder: (context, index) {
                    final product = wishlistItems[index];
                    return Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: InkWell(
                        onTap: () {},
                        child: Container(
                          height: 100,
                          width: 360,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: ListTile(
                              leading: Image.network(
                                product.thumbnailImage,
                              ),
                              title: Text(product.name),
                              subtitle: Text(
                                'AED ${product.basePrice.replaceAll('Rs', '')}',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 185, 92, 4)),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () async {
                                  final removedProductId =
                                      wishlistItems[index].id;

                                  await _toggleWishlist(
                                      context, removedProductId, true);

                                  setState(() {
                                    wishlistItems.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

class Product {
  final int id;
  final String name;
  final String thumbnailImage;
  final String basePrice;
  final int rating;

  Product({
    required this.id,
    required this.name,
    required this.thumbnailImage,
    required this.basePrice,
    required this.rating,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      thumbnailImage: json['thumbnail_image'],
      basePrice: json['base_price'],
      rating: json['rating'],
    );
  }
}
