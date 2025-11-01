class Urls {
  static const String _baseUrl = 'http://206.162.244.140:8033';
  static const String baseUrl = '';
  static const String socketUrl = '';
  static const String login = '$_baseUrl/auth/login';
  static const String authSignUp = '$_baseUrl/auth/signup';
  static const String authForgetSendOtp = '$_baseUrl/auth/forget/send-otp';
  static const String authFVerifyOtp = '$_baseUrl/auth/forget/verify-otp';
  static const String authValidate = '$_baseUrl/auth/validate';
  static const String logout = '$_baseUrl/auth/logout';
  static const String forgotPass = '$_baseUrl/auth/forgot-password';
  static const String pickUpLocation = '$_baseUrl/carTransports/ride-plan';
  static const String carTransportsMyRidePlans = '$_baseUrl/carTransports/my-ride-plans';
  static const String carTransportsMyRidesPending = '$_baseUrl/carTransports/my-rides-pending';
  static const String carTransportsCreate = '$_baseUrl/carTransports/create';
  static const String paymentsCreateCard = '$_baseUrl/payments/create-card';
  static const String paymentsSavedCards = '$_baseUrl/payments/saved-cards';
  static const String paymentsCardPayment = '$_baseUrl/payments/card-payment';
  static const String reviewsCreate = '$_baseUrl/reviews/create';
  static  String carTransportsSingle(String id) => '$_baseUrl/carTransports/single/$id';
  static  String usersDeleteAccount(String id) => '$_baseUrl/users/delete-account/$id';
  static  String riderRideCancel(String id) => '$_baseUrl/carTransports/$id/cancel';
  static  String carTransportsCompleted(String id) => '$_baseUrl/carTransports/$id/completed';

  static String getCalendar(String date, String locationUuid) =>
      '$_baseUrl/calendar?date=$date&pickup_location_uuid=$locationUuid';

  static const String googleApiKey = "AIzaSyC7AoMhe2ZP3iHflCVr6a3VeL0ju0bzYVE";


}



