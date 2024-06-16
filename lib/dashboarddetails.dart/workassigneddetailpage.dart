// work_assigned_details_page.dart
import 'package:flutter/material.dart';
import 'package:loginuicolors/model/model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WorkAssignedDetailsPage extends StatefulWidget {
  @override
  _WorkAssignedDetailsPageState createState() => _WorkAssignedDetailsPageState();
}

class _WorkAssignedDetailsPageState extends State<WorkAssignedDetailsPage> {
  late Future<List<RecentWorkordersPreventive>> _workordersFuture;

  @override
  void initState() {
    super.initState();
    _workordersFuture = fetchWorkorders();
  }

  Future<List<RecentWorkordersPreventive>> fetchWorkorders() async {
    final response = await http.get(Uri.parse('https://www.homs.com.np/api/dashboard/5'));
    if (response.statusCode == 200) {
      try {
        var jsonData = jsonDecode(response.body);
        var workers = Workers.fromJson(jsonData);
        return workers.dashboardDetails.recentWorkordersPreventive;
      } catch (e) {
        print('Error parsing JSON: $e');
        throw Exception('Error parsing JSON: $e');
      }
    } else {
      throw Exception('Failed to load data with status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Work Assigned Details'),
      ),
      body: FutureBuilder<List<RecentWorkordersPreventive>>(
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
                    child: ListTile(
                      title: Text('Workorder ID: ${workorder.id}'),
                      subtitle: Text('Status: ${workorder.status}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WorkAssignedDetailPage(workorder: workorder),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class WorkAssignedDetailPage extends StatelessWidget {
  final RecentWorkordersPreventive workorder;

  const WorkAssignedDetailPage({Key? key, required this.workorder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workorder ID: ${workorder.id}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: workorder.id == null
            ? Center(child: Text('Not Found'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: ${workorder.id}'),
                  Text('Template ID: ${workorder.woTemplateId}'),
                  Text('Scheduled Start Date: ${workorder.scheduledStartDate}'),
                  Text('Status: ${workorder.status}'),
                  Text('Created At: ${workorder.createdAt}'),
                  Text('Updated At: ${workorder.updatedAt}'),
                  // Add more fields as necessary
                ],
              ),
      ),
    );
  }
}
