import 'package:flutter/material.dart';

class WaiterShiftPage extends StatelessWidget {
  final String waiterName;
  final Map<String, Map<String, DateTime>> shiftTimes;

  WaiterShiftPage({required this.waiterName, required this.shiftTimes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$waiterName\'s Shifts'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var day in shiftTimes.keys) ...[
              Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text(
                            'Start: ${shiftTimes[day]!['start']?.hour}:${shiftTimes[day]!['start']?.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time_outlined, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text(
                            'End: ${shiftTimes[day]!['end']?.hour}:${shiftTimes[day]!['end']?.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
