import 'package:demoapp/services/api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  //signup
  Future<bool> signup(String name, String mobile, String email, String password) async {
    try {
      await _apiService.signup(name, mobile, email, password);
      return true;
    } catch (e) {
      print("Signup error: $e");
      return false;
    }
  }

  //login
  Future<bool> login(String email, String password) async {
    try {
      await _apiService.login(email, password);
      return true;
    } catch (e) {
      print("Signinerror: $e");
      return false;
    }
  }
  //logout
 Future<void> logout() async {
    await _apiService.logout();
  }
  //get profile
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      return await _apiService.getProfile();
    } catch (e) {
      return null;
    }
  }
  Future<bool>isLoggedIn()async{
    return await _apiService.isLoggedIn();
  }
}
