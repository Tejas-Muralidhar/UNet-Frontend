import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DonationsPage(),
    );
  }
}

class DonationsPage extends StatefulWidget {
  @override
  _DonationsPageState createState() => _DonationsPageState();
}

class _DonationsPageState extends State<DonationsPage> {
  List<dynamic> donations = []; // List to hold donation data
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    fetchDonations(); // Fetch donations on page load
  }

  Future<void> fetchDonations() async {
    try {
      // Get the user email from shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? email = prefs.getString('email');
      String? token = prefs.getString('access_token');

      if (email == null) {
        throw Exception("User email not found in shared preferences");
      }

      // Make the API call
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/api/donations/user_donations/"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization' : 'Bearer $token',
        },
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        // Decode the JSON response and set donations
        final data = json.decode(response.body);
        setState(() {
          donations = data['donations']; // Assuming the response contains a 'donations' array
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch donations");
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff64ffda),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Your Contributions'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : donations.isEmpty
          ? const Center(
        child: Text(
          'No donations found.',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: donations.length,
          itemBuilder: (context, index) {
            final donation = donations[index];
            return DonationCard(
              organization: donation['ngo_name'] ?? 'N/A',
              donation: donation['amount'] ?? 'N/A',
              date: donation['date'] ?? 'N/A',
            );
          },
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
        currentIndex: 1, // Default tab selected
        selectedItemColor: Colors.teal,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/main');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/network');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
    );
  }
}

// Widget for individual donation card
class DonationCard extends StatelessWidget {
  final String organization;
  final String donation;
  final String date;

  DonationCard({
    required this.organization,
    required this.donation,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(
              Icons.group,
              size: 50,
              color: Colors.teal,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  organization,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Donated $donation',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'on $date',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],

        ),

      ),

    );
  }
}
