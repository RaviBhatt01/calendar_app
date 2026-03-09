import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  Color themeColor = Colors.green;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  final TextEditingController _eventController = TextEditingController();

  final Map<DateTime, List<String>> _events = {
    DateTime(2026, 3, 10): ['Event 1', 'Event 2'],
    DateTime(2026, 3, 15): ['Event 3'],
  };

  List<String> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calendar App',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: themeColor,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          spacing: 20,
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              // lastDay: DateTime.now().add(const Duration(days: 30)),
              lastDay: DateTime.utc(2027, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              locale: 'en_US',
              rowHeight: 50,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: CalendarStyle(
                tableBorder: TableBorder.symmetric(
                  borderRadius: BorderRadius.circular(10),
                  outside: BorderSide(color: themeColor),
                ),
                isTodayHighlighted: true,
                todayDecoration: BoxDecoration(
                  color: themeColor,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: const Color.fromARGB(255, 157, 204, 107),
                  shape: BoxShape.circle,
                ),
              ),
              availableGestures: AvailableGestures.all,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              eventLoader: (day) {
                return _getEventsForDay(day);
              },
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                _selectedDay == null
                    ? "No Day Selected"
                    : "Selected: ${_selectedDay!.toLocal().toString().split(' ')[0]}",
                style: TextStyle(
                  color: themeColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (_selectedDay != null)
              Container(
                height: 300,
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        "Events for ${_selectedDay!.toLocal().toString().split(' ')[0]}",
                        style: TextStyle(
                          color: themeColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Builder(
                        builder: (context) {
                          final events = _getEventsForDay(
                            _selectedDay ?? _focusedDay,
                          );

                          if (events.isEmpty) {
                            return const Text(
                              "No events for this day",
                              style: TextStyle(fontSize: 16),
                            );
                          }

                          return Column(
                            children: events
                                .map(
                                  (event) => ListTile(
                                    leading: const Icon(Icons.event),
                                    title: Text(event),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text("Delete Event"),
                                            content: const Text(
                                                "Are you sure you want to delete this event?"),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text("Cancel"),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  setState(() {
                                                    events.remove(event);
                                                  });
                                                  Navigator.pop(context);
                                                },
                                                child: const Text("Delete"),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: themeColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Add Event"),
              content: TextField(
                controller: _eventController,
                decoration: const InputDecoration(hintText: "Enter event name"),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    final text = _eventController.text;
                    if (text.isNotEmpty && _selectedDay != null) {
                      final day = DateTime(
                        _selectedDay!.year,
                        _selectedDay!.month,
                        _selectedDay!.day,
                      );
                      if (_events[day] == null) {
                        _events[day] = [];
                      }
                      _events[day]!.add(text);

                      setState(() {});
                    }
                    _eventController.clear();
                    Navigator.pop(context);
                  },
                  child: const Text("Add"),
                ),
              ],
            ),
          );
        },
        label: Text("Add Event", style: TextStyle(color: Colors.white)),
        icon: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
