import 'package:facebook_app_events/facebook_app_events.dart';

// move to new_development folder
class FacebookEventHelper {
  static final FacebookAppEvents _fbEvent = FacebookAppEvents();

  /// Simple event
  static logSimpleEvent(String eventName) {
    _fbEvent.logEvent(name: eventName);
  }

  /// Event with parameters
  static logEvent(String eventName, Map<String, dynamic> params) {
    _fbEvent.logEvent(name: eventName, parameters: params);
  }

  /// Purchase event
  static logPurchase(double amount, String currency) {
    _fbEvent.logPurchase(amount: amount, currency: currency);
  }

  /// Advertiser event
  static logSetAdvertiser(bool value) {
    _fbEvent.setAdvertiserTracking(enabled: value);
  }

  /// Add To Cart event
  static logAddToCart(String id, String type, double price, String currency) {
    _fbEvent.logAddToCart(
      id: id,
      type: type, //'product'
      price: price,
      currency: currency,
    );
  }

  /// Set User event
  static logSetUser(String email, String name, String dob, String city, String country) {
    _fbEvent.setUserData(
      email: email,
      firstName: name,
      dateOfBirth: dob,
      city: city,
      country: country,
    );
  }
}

/*
Use
FacebookEventHelper.logPurchase(499, "INR");
FacebookEventHelper.logEvent("Add_To_Cart", {
  "product_id": "P123",
  "price": 150,
});
ElevatedButton(
  onPressed: () {
    FacebookEventHelper.logSimpleEvent("Login_Button_Clicked");
  },
  child: Text("Login"),
),
FacebookEventHelper.logSimpleEvent("HomeScreen_Opened");

*/