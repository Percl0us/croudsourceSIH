// lib/pages/report_detail_page.dart
import 'package:flutter/material.dart';

class ReportDetailPage extends StatelessWidget {
  final Map<String, dynamic> report;
  const ReportDetailPage({super.key, required this.report});

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
    final status = report["status"] ?? "Unknown";

    return Scaffold(
      appBar: AppBar(title: const Text("Report Details")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (report["image_url"] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(report["image_url"]),
              ),
            const SizedBox(height: 16),
            Text(
              report["text"] ?? "No description",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text("Status: ", style: TextStyle(fontSize: 16)),
                Chip(
                  label: Text(
                    status,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _statusColor(status),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text("Category: ${report["category"] ?? "-"}"),
            Text("Priority: ${report["priority"] ?? "-"}"),
            Text("Created At: ${report["createdAt"] ?? "-"}"),
            Text("Updated At: ${report["updatedAt"] ?? "-"}"),
          ],
        ),
      ),
    );
  }
}
