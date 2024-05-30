import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'waiter_shift_page.dart'; // Import the new page

class ShiftPage extends StatefulWidget {
  const ShiftPage({Key? key}) : super(key: key);

  @override
  _ShiftPageState createState() => _ShiftPageState();
}

class _ShiftPageState extends State<ShiftPage> {
  String selectedWaiter = '';
  List<DateTime> startTimes = List.generate(7, (index) => DateTime.now());
  List<DateTime> endTimes = List.generate(7, (index) => DateTime.now());

  final List<String> waiters = ['Waiter 1', 'Waiter 2', 'Waiter 3', 'Waiter 4'];
  final List<String> daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  Map<String, Map<String, DateTime>> getShiftTimes() {
    Map<String, Map<String, DateTime>> shiftTimes = {};
    for (int i = 0; i < daysOfWeek.length; i++) {
      shiftTimes[daysOfWeek[i]] = {
        'start': startTimes[i],
        'end': endTimes[i],
      };
    }
    return shiftTimes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shift Management'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Waiter:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: selectedWaiter.isEmpty ? null : selectedWaiter,
              hint: const Text('Select Waiter'),
              onChanged: (String? newValue) {
                setState(() {
                  selectedWaiter = newValue!;
                });
              },
              items: waiters.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            for (int i = 0; i < daysOfWeek.length; i++) ...[
              Text(
                'Select Time for ${daysOfWeek[i]}:',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Start:'),
                        TimePickerSpinner(
                          is24HourMode: true,
                          normalTextStyle: const TextStyle(fontSize: 14, color: Colors.black54),
                          highlightedTextStyle: const TextStyle(fontSize: 14, color: Colors.black),
                          spacing: 20,
                          itemHeight: 30,
                          isForce2Digits: true,
                          minutesInterval: 15,
                          onTimeChange: (time) {
                            setState(() {
                              startTimes[i] = time;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text('End:'),
                        TimePickerSpinner(
                          is24HourMode: true,
                          normalTextStyle: const TextStyle(fontSize: 14, color: Colors.black54),
                          highlightedTextStyle: const TextStyle(fontSize: 14, color: Colors.black),
                          spacing: 20,
                          itemHeight: 30,
                          isForce2Digits: true,
                          minutesInterval: 15,
                          onTimeChange: (time) {
                            setState(() {
                              endTimes[i] = time;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle the logic to save the shift information
                  print('Waiter: $selectedWaiter');
                  for (int i = 0; i < daysOfWeek.length; i++) {
                    print('${daysOfWeek[i]} Start Time: ${startTimes[i]}');
                    print('${daysOfWeek[i]} End Time: ${endTimes[i]}');
                  }
                },
                child: const Text('Save Shift'),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the WaiterShiftPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WaiterShiftPage(
                        waiterName: selectedWaiter,
                        shiftTimes: getShiftTimes(),
                      ),
                    ),
                  );
                },
                child: const Text('View Shifts'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
