import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(RazorpayPaymentApp());
}

class RazorpayPaymentApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
    );
  }
}

class RazorpayPaymentPage extends StatefulWidget {

  final int ngoId;

  const RazorpayPaymentPage({Key? key, required this.ngoId}) : super(key: key);


  @override
  _RazorpayPaymentPageState createState() => _RazorpayPaymentPageState();
}

showTranscriptDialog(BuildContext context, Map<String, dynamic> result) {
  Map<String, dynamic> transcript = result['details']['transcript'];

  // Concatenate all transcript parts into one string
  String transcriptMessage = '';

  if (transcript.containsKey('Process Initiation') &&
      transcript['Process Initiation'] != null) {
    transcriptMessage += 'Process Initiation:\n';
    transcriptMessage +=
    'Transaction ID: ${transcript['Process Initiation']['Transaction ID']}\n';
    transcriptMessage +=
    'Time: ${transcript['Process Initiation']['time']}\n\n';
  }

  if (transcript.containsKey('Checking User Verification') &&
      transcript['Checking User Verification'] != null) {
    transcriptMessage += 'Checking User Verification:\n';
    transcriptMessage +=
    'Card Number: ${transcript['Checking User Verification']['card_number']}\n';
    transcriptMessage +=
    'Amount: ${transcript['Checking User Verification']['amount']}\n';
    transcriptMessage +=
    'Name: ${transcript['Checking User Verification']['name']}\n';
    transcriptMessage +=
    'Time: ${transcript['Checking User Verification']['time']}\n\n';
  }

  if (transcript.containsKey('Bank Response for User Verification') &&
      transcript['Bank Response for User Verification'] != null) {
    transcriptMessage += 'Bank Response for User Verification:\n';
    transcriptMessage +=
    'Message: ${transcript['Bank Response for User Verification']['message']}\n\n';
  }

  if (transcript.containsKey('Checking NGO Verification') &&
      transcript['Checking NGO Verification'] != null) {
    transcriptMessage += 'Checking NGO Verification:\n';
    transcriptMessage +=
    'Account Number: ${transcript['Checking NGO Verification']['account_number']}\n';
    transcriptMessage +=
    'Time: ${transcript['Checking NGO Verification']['time']}\n\n';
  }

  if (transcript.containsKey('Bank Response for NGO Verification') &&
      transcript['Bank Response for NGO Verification'] != null) {
    transcriptMessage += 'Bank Response for NGO Verification:\n';
    transcriptMessage +=
    'Message: ${transcript['Bank Response for NGO Verification']['message']}\n\n';
  }

  if (transcript.containsKey('Making Money Transfer') &&
      transcript['Making Money Transfer'] != null) {
    transcriptMessage += 'Making Money Transfer:\n';
    transcriptMessage +=
    'Time: ${transcript['Making Money Transfer']['time']}\n\n';
  }

  if (transcript.containsKey('Bank Response for Money Transfer') &&
      transcript['Bank Response for Money Transfer'] != null) {
    transcriptMessage += 'Bank Response for Money Transfer:\n';
    transcriptMessage +=
    'Message: ${transcript['Bank Response for Money Transfer']['message']}\n';
    transcriptMessage +=
    'User Balance: ${transcript['Bank Response for Money Transfer']['user_balance']}\n';
  }

  transcriptMessage += 'End of Transcript';

  // Show all the concatenated transcript data in one dialog box
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Transaction Transcript'),
        content: SingleChildScrollView(
          child: Text(
            transcriptMessage,
            style: TextStyle(fontSize: 14), // You can adjust the font size
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}




class _RazorpayPaymentPageState extends State<RazorpayPaymentPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isChecked = false;

  // Controllers for the form inputs
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  Future<void> submitPayment(BuildContext context) async {
    final url = 'http://10.0.2.2:8000/api/payments/pay/'; // Replace with your actual IP
    print('Sending POST request to: $url');
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User is not logged in")),
        );
        return;
      }

      print(prefs.getString('email'));

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': _fullNameController.text,
          'card_number': _cardNumberController.text,
          'cvv': _cvvController.text,
          'expiry_date': _expiryDateController.text,
          'amount': _amountController.text,
          'ngo_id': widget.ngoId,
          'user_email': prefs.getString('email'),
        }),
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      print(widget.ngoId);

      final result = jsonDecode(response.body);
      print(result);
      showTranscriptDialog(context, result);
      print('Hi');
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[100], // Soft mint color background
      appBar: AppBar(
        backgroundColor: Colors.teal[500], // Green color for AppBar
        title: Text('Payment', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.teal[50],
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Full Name Field
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextFormField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        labelStyle: TextStyle(color: Colors.black87),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.teal[100]!, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                  ),
                  // Card Number Field
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextFormField(
                      controller: _cardNumberController,
                      decoration: InputDecoration(
                        labelText: 'Card Number',
                        labelStyle: TextStyle(color: Colors.black87),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.teal[100]!, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty || value.length != 16) {
                          return 'Please enter a valid 16-digit card number';
                        }
                        return null;
                      },
                    ),
                  ),
                  // CVV Field
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        labelStyle: TextStyle(color: Colors.black87),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.teal[100]!, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty || value.length != 3) {
                          return 'Please enter a valid 3-digit CVV';
                        }
                        return null;
                      },
                    ),
                  ),
                  // Expiry Date Field
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextFormField(
                      controller: _expiryDateController,
                      decoration: InputDecoration(
                        labelText: 'Expiry Date (MM/YY)',
                        labelStyle: TextStyle(color: Colors.black87),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.teal[100]!, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty || value.length != 5) {
                          return 'Please enter a valid expiry date (MM/YY)';
                        }
                        return null;
                      },
                    ),
                  ),
                  //Amount donated
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: 'Amount Donated',
                        labelStyle: TextStyle(color: Colors.black87),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.teal[100]!, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a valid amount you want to donate!';
                        }
                        return null;
                      },
                    ),
                  ),
                  // Confirmation Checkbox
                  Row(
                    children: <Widget>[
                      Checkbox(
                        value: _isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            _isChecked = value!;
                          });
                        },
                      ),
                      Expanded(
                        child: Text(
                          'I confirm the payment details are correct',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  // Donate Button
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[500], // Green button color
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          if (!_isChecked) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Please confirm the payment details')),
                            );
                          } else {
                            // Trigger the submitPayment function
                            submitPayment(context);
                          }
                        }
                      },
                      child: Text(
                        'Donate',
                        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
}
