import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:calendar_app/src/features/calendar/data/models/event.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {

  final Color themeColor = const Color.fromARGB(255, 79, 174, 82);

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  final Map<DateTime, List<Event>> _events = {
    DateTime(2026, 3, 10): [
      Event(
        title: "Event 1",
        description: "Test",
        time: TimeOfDay(hour: 10, minute: 0),
      ),
      Event(
        title: "Event 2",
        description: "Meeting",
        time: TimeOfDay(hour: 12, minute: 30),
      ),
    ],
    DateTime(2026, 3, 15): [
      Event(
        title: "Event 3",
        description: "Study",
        time: TimeOfDay(hour: 9, minute: 0),
      ),
    ],
  };

  List<Event> _getEventsForDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return _events[normalized] ?? [];
  }

  void _addEvent(Event event) {
    final day = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
    );

    if (_events[day] == null) {
      _events[day] = [];
    }

    _events[day]!.add(event);

    setState(() {});
  }

  void _deleteEvent(Event event) {
    final day = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
    );

    setState(() {
      _events[day]!.remove(event);

      if (_events[day]!.isEmpty) {
        _events.remove(day);
      }
    });
  }

  void _editEvent(Event oldEvent, Event updatedEvent) {
    final day = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
    );

    final index = _events[day]!.indexOf(oldEvent);

    setState(() {
      _events[day]![index] = updatedEvent;
    });
  }

  void _showAddEventDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Event"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),

            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "Description"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );

                if (time != null) {
                  selectedTime = time;
                }
              },
              child: const Text("Select Time"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            onPressed: () {
              if (titleController.text.isEmpty) return;

              final event = Event(
                title: titleController.text,
                description: descController.text,
                time: selectedTime,
              );

              _addEvent(event);

              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Event event) {
    final titleController = TextEditingController(text: event.title);
    final descController = TextEditingController(text: event.description);
    TimeOfDay selectedTime = event.time;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Event"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),

            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "Description"),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );

                if (time != null) {
                  selectedTime = time;
                }
              },
              child: const Text("Change Time"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            onPressed: () {
              final updated = Event(
                title: titleController.text,
                description: descController.text,
                time: selectedTime,
              );

              _editEvent(event, updated);

              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final events = _getEventsForDay(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Calendar Planner",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: themeColor,
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: themeColor,
        onPressed: _showAddEventDialog,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Event", style: TextStyle(color: Colors.white)),
        tooltip: "Add Event",
      ),

      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.utc(2030),
            focusedDay: _focusedDay,

            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

            eventLoader: (day) => _getEventsForDay(day),

            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),

            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: themeColor,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: themeColor.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
            ),

            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),

          const SizedBox(height: 10),

          Text(
            DateFormat.yMMMMd().format(_selectedDay),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: events.isEmpty
                ? const Center(child: Text("No events"))
                : ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.event),

                          title: Text(event.title),

                          subtitle: Text(
                            "${event.description}\n${event.time.format(context)}",
                          ),

                          isThreeLine: true,

                          onTap: () => _showEditDialog(event),

                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            // onPressed: () => _deleteEvent(event),
                            onPressed: () => showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Delete Event"),
                                content: const Text(
                                  "Are you sure you want to delete this event?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Cancel"),
                                  ),

                                  ElevatedButton(
                                    onPressed: () {
                                      _deleteEvent(event);
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Delete"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
