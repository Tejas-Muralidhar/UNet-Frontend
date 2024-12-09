import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import './ngo_profile.dart';
import './ngo_donations.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<dynamic> ngos = [];
  List<dynamic> displayedNgos = [];
  bool isLoading = true;
  bool isFetchingMore = false;
  bool hasMore = true; // To track if more data is available
  int currentPage = 1; // Track the current page
  final int pageSize = 25; // Number of NGOs per page
  TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchNgoData();
    _scrollController.addListener(_onScroll);
  }

  Future<void> fetchNgoData() async {
    if (isFetchingMore || !hasMore) return;

    setState(() {
      isFetchingMore = true;
    });

    final String apiUrl = 'http://10.0.2.2:8000/api/ngos/recommend-ngos/';
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User is not logged in")),
        );
        setState(() {
          isFetchingMore = false;
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> ngoData = jsonDecode(response.body);

        // Calculate pagination based on 25 NGOs per page
        int startIndex = (currentPage - 1) * pageSize;
        int endIndex = startIndex + pageSize;

        List<dynamic> newPageData = ngoData.sublist(
          startIndex,
          endIndex > ngoData.length ? ngoData.length : endIndex,
        );

        setState(() {
          ngos.addAll(newPageData); // Append the new page
          displayedNgos = ngos;
          currentPage++;
          hasMore = endIndex < ngoData.length; // Check if more NGOs are available
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch NGO data")),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred")),
      );
    } finally {
      setState(() {
        isFetchingMore = false;
        isLoading = false;
      });
    }
  }

  Future<void> searchNgo(String query) async {
    if (query.isEmpty) {
      setState(() {
        displayedNgos = ngos;
      });
      return;
    }

    final String apiUrl =
        'http://10.0.2.2:8000/api/ngos/recommend-ngos/?ngo_name=$query';
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User is not logged in")),
        );
        return;
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> recommendations = jsonDecode(response.body);
        if (recommendations.isNotEmpty) {
          setState(() {
            displayedNgos = recommendations;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("NGO not found")),
          );
          setState(() {
            displayedNgos = ngos;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch recommendations")),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred during search")),
      );
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent &&
        hasMore &&
        !isFetchingMore) {
      fetchNgoData();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NGO Recommendations'),
        backgroundColor: Colors.teal[500],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search for Recommendation...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onSubmitted: (value) => searchNgo(value),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                controller: _scrollController,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: displayedNgos.length,
                itemBuilder: (context, index) {
                  final ngo = displayedNgos[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              NgoProfilePage(ngoId: ngo['id']),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.teal[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          ngo['name'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[800],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
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
