import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import './razorpay.dart'; // Razorpay payment page
import './ngo_donations.dart'; // Donation details page

class NgoProfilePage extends StatefulWidget {
  final int ngoId;

  const NgoProfilePage({Key? key, required this.ngoId}) : super(key: key);

  @override
  _NgoProfilePageState createState() => _NgoProfilePageState();
}

class _NgoProfilePageState extends State<NgoProfilePage> {
  Map<String, dynamic>? ngoDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNgoDetails();
  }

  Future<void> fetchNgoDetails() async {
    final String apiUrl =
        'http://10.0.2.2:8000/api/ngos/ngo-detail/${widget.ngoId}/';
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token == null) {
        showSnackBar("User is not logged in");
        setState(() => isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          ngoDetails = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        showSnackBar("Failed to fetch NGO details: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      showSnackBar("An error occurred: $e");
      setState(() => isLoading = false);
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void showDonationDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Select Donation Type'),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
        ListTile(
        title: const Text('Resources'),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DonationDetailsPage(
                ngoId: widget.ngoId,
                ngoEmail: ngoDetails?['email']??'N/A',
              ),
            ),
          );
        },
      ),
    ListTile(
    title: const Text('Money'),
    onTap: () {
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RazorpayPaymentPage(
          ngoId: widget.ngoId,
        ),
      ),
    );
    },
    ),
            ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
        },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff64ffda),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text("NGO Profile"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ngoDetails == null
          ? const Center(child: Text("No details available"))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildNgoHeader(),
            const SizedBox(height: 20),
            buildNgoDetails(),
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
        currentIndex: 0, // Default tab selected
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

  Widget buildNgoHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
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
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              ngoDetails?['name'] ?? 'NGO Name',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNgoDetails() {
    final completedProjects = parseProjects(ngoDetails?['completed_project']);
    final ongoingProjects = parseProjects(ngoDetails?['ongoing_project']);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildDetailRow("Purpose", ngoDetails?['purpose']),
          buildDetailRow("Contact Person", ngoDetails?['contact_person']),
          buildDetailRow("Mobile Number", ngoDetails?['mobile_number']),
          buildDetailRow("Email", ngoDetails?['email']),
          buildDetailRow("Address", ngoDetails?['address']),
          const SizedBox(height: 20),
          const Text(
            "Projects",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              //decoration: TextDecoration.underline,
              color: Colors.teal,
            ),
          ),
          const Divider(thickness: 1),
          buildProjectSubsection("Completed Projects", completedProjects),
          const SizedBox(height: 10),
          buildProjectSubsection("Ongoing Projects", ongoingProjects),
          const SizedBox(height: 20),
          buildActionButtons(),
        ],
      ),
    );
  }

  Widget buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          onPressed: showDonationDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Donate', style: TextStyle(fontSize: 16)),
        ),
        ElevatedButton(
          onPressed: () {
            // Add Volunteer functionality here
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Volunteer', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget buildProjectSubsection(String title, List<dynamic> projects) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 5),
        projects.isEmpty
            ? const Text(
          "No data available",
          style: TextStyle(color: Colors.grey),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: projects.map((project) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                "- $project",
                style: const TextStyle(fontSize: 16),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  List<String> parseProjects(dynamic projects) {
    if (projects == null) return [];
    if (projects is String) {
      return projects.split(',').map((project) => project.trim()).toList();
    }
    if (projects is List) {
      return projects.map((project) => project.toString()).toList();
    }
    return [];
  }

  Widget buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          text: "$label: ",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          children: [
            TextSpan(
              text: value ?? 'N/A',
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
