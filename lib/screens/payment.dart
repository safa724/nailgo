import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nailgonew/screens/home.dart';
import 'package:nailgonew/screens/notsucces.dart';
import 'package:nailgonew/screens/succsus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String url;
  final String orderReference;
  final String accessToken;

  WebViewPage({
    required this.url,
    required this.orderReference,
    required this.accessToken,
  });

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewController _webViewController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
  }

  // Method to check payment status using API
  Future<Map<String, dynamic>> _checkPaymentStatus() async {
     SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessToken = prefs.getString('accessToken') ?? '';
   

    final url = Uri.parse('http://nailgo.ae/api/v2/checkpaymentstatus');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
    final body = jsonEncode({
      'payment_reference': widget.orderReference,
      'access_token': widget.accessToken,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      print(response.body);
      return jsonDecode(response.body); // Parse and return the response
    } else {
      throw Exception('Failed to check payment status');
    }
  }

  // Handle page loading events
  void _onPageStarted(String url) {
    print('Page started loading: $url');
  }

  void _onPageFinished(String url) {
    print('Page finished loading: $url');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigate to the Home Screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Home()),
        );
        return false; // Prevent default back behavior
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('Checkout with Iyzico'),
        ),
        body: Stack(
          children: [
            WebView(
              initialUrl: widget.url,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _webViewController = webViewController; // Assign the controller
                _webViewController.loadUrl(widget.url); // Load the URL
              },
              onPageStarted: _onPageStarted,
              onPageFinished: _onPageFinished,
              navigationDelegate: (NavigationRequest request) {
                if (request.url.contains('order/success')) {
                  setState(() {
                    _isLoading = true;
                  });
      
                  _checkPaymentStatus().then((response) {
                    setState(() {
                      _isLoading = false;
                    });
      
                    // Handle payment response
                    if (response['payment_status'] == "1") {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Success()),
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => NotSuccess()),
                      );
                    }
                  }).catchError((error) {
                    setState(() {
                      _isLoading = false;
                    });
                  });
      
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
            if (_isLoading) // Show loading indicator while checking payment
              Center(child: CircularProgressIndicator(color: Colors.black,strokeWidth: 2,)),
          ],
        ),
      ),
    );
  }
}
