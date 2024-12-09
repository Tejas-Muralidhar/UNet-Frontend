import 'package:flutter/material.dart';

void main() {
  runApp(DonationDetailsApp());
}

class DonationDetailsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

    );
  }
}

class DonationDetailsPage extends StatelessWidget {
  final int ngoId;
  final String ngoEmail;

  const DonationDetailsPage({
    Key? key,
    required this.ngoId,
    required this.ngoEmail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB2E2DD), // Light teal color
      appBar: AppBar(
        backgroundColor: Color(0xFF68B0AB), // Darker teal
        title: Text('Donate'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "What would you like to donate?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: Text("Books"),
                  leading: Icon(Icons.book, color: Color(0xFF68B0AB)),
                ),
                ListTile(
                  title: Text("Food"),
                  leading: Icon(Icons.fastfood, color: Color(0xFF68B0AB)),
                ),
                ListTile(
                  title: Text("Furniture"),
                  leading: Icon(Icons.chair, color: Color(0xFF68B0AB)),
                ),
                ListTile(
                  title: Text("Appliances"),
                  leading: Icon(Icons.kitchen, color: Color(0xFF68B0AB)),
                ),
                ListTile(
                  title: Text("Clothes"),
                  leading: Icon(Icons.shopping_bag, color: Color(0xFF68B0AB)),
                ),
                ListTile(
                  title: Text("Others (Describe in detail)"),
                  leading: Icon(Icons.more_horiz, color: Color(0xFF68B0AB)),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              "Description:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Explain in detail about the goods and their condition...",
              ),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF68B0AB), // Updated to backgroundColor
                ),
                child: Text("DONATE"),
              ),
            )
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
          currentIndex: 0, // Default on Profile
          selectedItemColor: Colors.teal,
          onTap: (int index) {
            // Handle navigation based on index
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
