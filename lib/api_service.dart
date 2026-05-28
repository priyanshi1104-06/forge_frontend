import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'https://forge-backend-pi0q.onrender.com';
    }
    return 'https://forge-backend-pi0q.onrender.com';
  }

  // Signup
  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    ).timeout(const Duration(seconds: 30));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['detail'] ?? 'Signup failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
        'email': email,
        'password': password,
      }),
    ).timeout(const Duration(seconds: 30));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['access_token']);
        return {'success': true, 'token': data['access_token']};
      } else {
        return {'success': false, 'message': data['detail'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Save user info locally
  static Future<void> saveUserInfo(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('email', email);
  }

  // Get token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Check if logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  // Calibration
  static Future<bool> isCalibrated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('calibrated') ?? false;
  }

  static Future<void> setCalibrated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('calibrated', true);
  }

  // Get current user
  static Future<Map<String, dynamic>> getMe() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 30));
    if (response.statusCode == 200) {
      return {'success': true, 'data': jsonDecode(response.body)};
    } else {
      return {'success': false};
    }
  }

  // Get user profile
  static Future<Map<String, dynamic>> getProfile() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/users/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 30));
    if (response.statusCode == 200) {
      return {'success': true, 'data': jsonDecode(response.body)};
    } else {
      return {'success': false};
    }
  }

  // Update profile
  static Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> data) async {
    final token = await getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/users/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return {'success': true, 'data': jsonDecode(response.body)};
    } else {
      return {'success': false};
    }
  }
  // Create workout
static Future<Map<String, dynamic>> createWorkout({
  required String date,
  required String notes,
}) async {
  final token = await getToken();
  final response = await http.post(
    Uri.parse('$baseUrl/workouts/'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'date': date,
      'notes': notes,
    }),
  ).timeout(const Duration(seconds: 30));
  if (response.statusCode == 200) {
    return {'success': true, 'data': jsonDecode(response.body)};
  } else {
    return {'success': false};
  }
}

// Get workouts
static Future<Map<String, dynamic>> getWorkouts() async {
  final token = await getToken();
  final response = await http.get(
    Uri.parse('$baseUrl/workouts/'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    ).timeout(const Duration(seconds: 30));
  if (response.statusCode == 200) {
    return {'success': true, 'data': jsonDecode(response.body)};
  } else {
    return {'success': false};
  }
}

// Delete workout
static Future<bool> deleteWorkout(int sessionId) async {
  final token = await getToken();
  final response = await http.delete(
    Uri.parse('$baseUrl/workouts/$sessionId'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );
  return response.statusCode == 200;
}
static Future<Map<String, dynamic>> getAIRecommendation({
  required String goal,
  required bool includeDiet,
  required bool includeWorkout,
}) async {
  final token = await getToken();
  if (token == null) {
    return {
      'success': false,
      'message': 'Not logged in. Please sign in and try again.',
    };
  }

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/ai/recommend'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'goal': goal,
        'include_diet': includeDiet,
        'include_workout': includeWorkout,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {'success': true, 'data': data};
    }
    return {
      'success': false,
      'message': data['detail'] ?? data['message'] ?? 'AI request failed',
      'status': response.statusCode,
    };
  } catch (e) {
    return {'success': false, 'message': 'Network error: $e'};
  }
}
static Future<Map<String, dynamic>> getProgressSummary() async {
  final token = await getToken();
  final response = await http.get(
    Uri.parse('$baseUrl/progress/summary'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    ).timeout(const Duration(seconds: 30));
  if (response.statusCode == 200) {
    return {'success': true, 'data': jsonDecode(response.body)};
  } else {
    return {'success': false};
  }
}
}