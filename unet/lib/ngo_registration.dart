import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterNGO extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController purposeController = TextEditingController();
  final TextEditingController completedProjectController = TextEditingController();
  final TextEditingController ongoingProjectController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();

  Future<void> registerNGO(BuildContext context) async {
    const String url = 'http://10.0.2.2:8000/api/ngos/register/';

    final Map<String, dynamic> requestBody = {
      "name": nameController.text,
      "mobile_number": mobileNumberController.text,
      "email": emailController.text,
      "address": addressController.text,
      "contact_person": contactPersonController.text,
      "purpose": purposeController.text,
      "completed_project": completedProjectController.text.isNotEmpty
          ? completedProjectController.text
          : "No Completed Projects",
      "ongoing_project": ongoingProjectController.text.isNotEmpty
          ? ongoingProjectController.text
          : "Not Applicable",
      "account_number": accountNumberController.text.isNotEmpty
          ? accountNumberController.text
          : "0000000000000000",
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 201) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Registration Successful"),
              content: const Text(
                  "NGO has been added successfully! Resource donations and volunteer queries will be sent to your email."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${errorData['error'] ?? 'Registration failed'}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[500],
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              // Top Section for UNet logo and slogan
              Container(
                height: constraints.maxHeight * 0.25,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'UNet',
                      style: TextStyle(
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[900],
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      'Uniting NGOs, Empowering Networks, and Amplifying Social Change',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40.0),
                      topRight: Radius.circular(40.0),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ListView(
                          children: [
                            buildTextField("Name", nameController),
                            buildTextField("Mobile Number", mobileNumberController),
                            buildTextField("Email", emailController),
                            buildTextField("Address", addressController),
                            buildTextField("Contact Person", contactPersonController),
                            buildTextField("Purpose", purposeController),
                            buildTextField(
                                "Completed Projects (Optional)", completedProjectController),
                            buildTextField("Ongoing Projects (Optional)", ongoingProjectController),
                            buildTextField("Account Number", accountNumberController),
                            const SizedBox(height: 20.0), // Extra space between fields
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          const SizedBox(height: 20.0),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal[300],
                                padding: const EdgeInsets.all(15.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              onPressed: () => registerNGO(context),
                              child: const Text(
                                'Register NGO',
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                            child: const Text(
                              "Already a Registered NGO? Go to Login",
                              style: TextStyle(color: Colors.teal),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 16.0),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }
}
