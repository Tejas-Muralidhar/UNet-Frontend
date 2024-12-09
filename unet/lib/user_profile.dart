import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './main.dart'; // Ensure this contains the LoginPage class
import 'package:shared_preferences/shared_preferences.dart';


class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    final String apiUrl = 'http://10.0.2.2:8000/api/users/view-profile/'; // Replace with actual API URL
    try {
      // Get the stored JWT token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token'); // Retrieve the token
      print("JWT Access Token: $token");

      if (token == null) {
        // Handle the case when the token is not available
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User is not logged in")),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Make the API call with the token in the Authorization header
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token', // Add the JWT token here
        },
      );

      if (response.statusCode == 200) {
        // Decode and update the state with user details
        setState(() {
          userDetails = jsonDecode(response.body);
          isLoading = false;
        });
      }
      else {
        print("Error Response: ${response.body} and ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch user details: ${response.body}")),
        );
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // Handle exceptions
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred")),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> logoutUser() async {
    final String apiUrl = 'http://10.0.2.2:8000/api/users/logout/';
    try {
      // Retrieve the JWT tokens from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');
      String? refreshToken = prefs.getString('refresh_token');

      if (token == null || refreshToken == null) {
        // Handle the case when the token is not available
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User is not logged in")),
        );
        return;
      }

      // Make the API call with the access token in the Authorization header
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"refresh_token": refreshToken}), // Send the refresh token
      );

      if (response.statusCode == 200) {
        // Successfully logged out, remove the tokens
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
        await prefs.remove('email');

        // Navigate to the LoginPage after logging out
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Logged out successfully")),
        );
      } else {
        // Error occurred
        final errorResponse = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Logout failed: ${errorResponse['error']}")),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[100],
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.teal[500],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture and Info Section
            CircleAvatar(
              radius: 50.0,
              backgroundColor: Colors.teal[400],
              child: Icon(
                Icons.person,
                size: 50.0,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              "${userDetails?['name']}",
              style: TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
                color: Colors.teal[800],
              ),
            ),
            Text(
              "User ID: ${userDetails?['id']}",
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.teal[700],
              ),
            ),
            SizedBox(height: 30.0),

            // Email Section
            Container(
              padding: EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Email: ${userDetails?['email']}",
                    style: TextStyle(fontSize: 20.0),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    "Date Joined: ${userDetails?['date_joined']}",
                    style: TextStyle(fontSize: 20.0),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    "Last Login: ${userDetails?['last_login']}",
                    style: TextStyle(fontSize: 20.0),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    "Total Monetary Donations: ${userDetails?['donated_amount']}",
                    style: TextStyle(fontSize: 20.0),
                  ),
                ],
              ),
            ),

            Spacer(),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  padding: EdgeInsets.all(15.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: logoutUser,
                child: Text(
                  'LOGOUT',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.handshake),
            label: 'Network',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: 2,  // This indicates which tab is selected by default (0 is Home)
        selectedItemColor: Colors.teal,
        onTap: (index) {
          if (index == 0) {
            // 1. When Home is tapped, navigate to the Main Page (the current page)
            Navigator.pushReplacementNamed(context, '/main');
          }
          else if (index == 1) {
            // 2. Placeholder for Network Page (when Network is tapped)
            Navigator.pushReplacementNamed(context, '/network');  // Add this route to the MaterialApp's routes
          }
          else if (index == 2) {
            // 3. Placeholder for Profile Page (when Profile is tapped)
            Navigator.pushReplacementNamed(context, '/profile');  // Add this route to the MaterialApp's routes
          }
        },
      ),

    );
  }
}