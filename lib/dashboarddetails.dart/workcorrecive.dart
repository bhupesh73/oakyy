import 'package:flutter/material.dart';
import 'package:loginuicolors/model/model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WorkCorrectiveDetailsPage extends StatefulWidget {
  @override
  _WorkCorrectiveDetailsPageState createState() =>
      _WorkCorrectiveDetailsPageState();
}

class _WorkCorrectiveDetailsPageState extends State<WorkCorrectiveDetailsPage> {
  late Future<List<RecentWorkordersCorrective>> _workordersFuture;

  @override
  void initState() {
    super.initState();
    _workordersFuture = fetchWorkorders();
  }

  Future<List<RecentWorkordersCorrective>> fetchWorkorders() async {
    final response =
        await http.get(Uri.parse('https://www.homs.com.np/api/dashboard/5'));
    if (response.statusCode == 200) {
      try {
        var jsonData = jsonDecode(response.body);
        var workers = Workers.fromJson(jsonData);
        return workers.dashboardDetails.recentWorkordersCorrective;
      } catch (e) {
        print('Error parsing JSON: $e');
        throw Exception('Error parsing JSON: $e');
      }
    } else {
      throw Exception(
          'Failed to load data with status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RecentWorkordersCorrective>>(
      future: _workordersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No Workorders Found'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var workorder = snapshot.data![index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  margin: const EdgeInsets.all(8.0),
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              WorkCorrectiveDetailPage(workorder: workorder),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            workorder.woName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            workorder.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}

class WorkCorrectiveDetailPage extends StatelessWidget {
  final RecentWorkordersCorrective workorder;

  const WorkCorrectiveDetailPage({Key? key, required this.workorder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Workorder ID: ${workorder.id}'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Description'),
              Tab(text: 'Instruction'),
              Tab(text: 'Safety Measures'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Safety Measures: ${workorder.description}'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instruction:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('Description: ${workorder.instructions}'),
                ],
              ),
            ),
            Text(
              'Safety Measures: ${workorder.safetyMeasures}',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
