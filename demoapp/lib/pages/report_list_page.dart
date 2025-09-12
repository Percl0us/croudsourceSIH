// lib/pages/my_reports_page.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'report_detail_page.dart';

class MyReportsPage extends StatefulWidget {
  const MyReportsPage({super.key});

  @override
  State<MyReportsPage> createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  List<dynamic> _reports = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    setState(() => _loading = true);

    try {
      final token = await _storage.read(key: "jwt");
      final resp = await _dio.get(
        "https://croudsourcesih.onrender.com/api/reports",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      setState(() => _reports = resp.data ?? []);
    } catch (e) {
      debugPrint("Error fetching reports: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case "Submitted":
        return Colors.grey;
      case "Acknowledged":
        return Colors.blue;
      case "Assigned":
        return Colors.orange;
      case "Resolved":
        return Colors.green;
      case "Rejected":
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Reports")),
      body: RefreshIndicator(
        onRefresh: _fetchReports,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _reports.length,
                itemBuilder: (context, index) {
                  final r = _reports[index];
                  final status = r["status"] ?? "Unknown";

                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReportDetailPage(report: r),
                          ),
                        );
                      },
                      leading: r["image_url"] != null
                          ? Image.network(r["image_url"], width: 60, fit: BoxFit.cover)
                          : const Icon(Icons.image, size: 40),
                      title: Text(r["text"] ?? "No description"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Category: ${r["category"] ?? "-"}"),
                          Text("Priority: ${r["priority"] ?? "-"}"),
                          const SizedBox(height: 4),
                          Chip(
                            label: Text(
                              status,
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: _statusColor(status),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
