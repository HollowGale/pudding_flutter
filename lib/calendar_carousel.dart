import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';

import 'package:flutter/material.dart';

class Calendar extends StatefulWidget {
  Calendar({Key key,}) : super(key: key);

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  static String noEventText = "No event here";
  String calendarText = noEventText;
  DateTime _currentDate = DateTime.now();
  EventList<Event> _markedDateMap = new EventList<Event>(events: {
    new DateTime(2019, 1, 24): [
      new Event(
        date: new DateTime(2019, 1, 24),
        title: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, '
            'sed eiusmod tempor incidunt ut labore et dolore magna aliqua.'
            ' \n\nUt enim ad minim veniam,'
            ' quis nostrud exercitation ullamco laboris nisi ut aliquid ex ea commodi consequat.'
            ' \n\nQuis aute iure reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. '
            'Excepteur sint obcaecat cupiditat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
        icon: _eventIcon,
      )
    ]
  });

  @override
  void initState() {
    _markedDateMap.add(
        new DateTime(2019, 1, 25),
        new Event(
          date: new DateTime(2019, 1, 25),
          title: 'Event 5',
          icon: _eventIcon,
        ));

    _markedDateMap.add(
        new DateTime(2019, 1, 10),
        new Event(
          date: new DateTime(2019, 1, 10),
          title: 'Event 4',
          icon: _eventIcon,
        ));

    _markedDateMap.addAll(new DateTime(2019, 1, 11), [
      new Event(
        date: new DateTime(2019, 1, 11),
        title: 'Event 1',
        icon: _eventIcon,
      ),
      new Event(
        date: new DateTime(2019, 1, 11),
        title: 'Event 2',
        icon: _eventIcon,
      ),
      new Event(
        date: new DateTime(2019, 1, 11),
        title: 'Event 3',
        icon: _eventIcon,
      ),
    ]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: <Widget>[
          Container(
            margin : EdgeInsets.symmetric(horizontal: 14.0),
            child: CalendarCarousel<Event>(
              onDayPressed: (DateTime date, List<Event> dates) {
                this.setState(() => _currentDate = date);
              },
              weekdayTextStyle: TextStyle(
                fontFamily: 'Product Sans',
                fontSize: 18,
              ),
              markedDateMoreCustomTextStyle: TextStyle(
                fontFamily: 'Product Sans',
                fontSize: 18,
              ),
              weekendTextStyle: TextStyle(
                color: Colors.red,
                fontFamily: 'Product Sans',
                fontSize: 18,
              ),
              daysTextStyle: TextStyle(
                fontFamily: 'Product Sans',
                fontSize: 18,
              ),
              nextDaysTextStyle: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Product Sans'
              ),
              prevDaysTextStyle: TextStyle(
                fontFamily: 'Product Sans',
                fontSize: 16,
              ),
              thisMonthDayBorderColor: Colors.grey,
              headerTextStyle: TextStyle(
                fontFamily: 'Product Sans',
                color: Colors.brown,
                fontSize: 25,
              ),
              inactiveDaysTextStyle: TextStyle(
                fontFamily: 'Product Sans',
                fontSize: 18,
              ),
              inactiveWeekendTextStyle: TextStyle(
                fontFamily: 'Product Sans',
                fontSize: 18,
              ),
//      weekDays: null, /// for pass null when you do not want to render weekDays
//      headerText: Container( /// Example for rendering custom header
//        child: Text('Custom Header'),
//      ),
//      markedDates: _markedDate,
              weekFormat: false,
              markedDatesMap: _markedDateMap,
              height: 420.0,
              selectedDateTime: _currentDate,
              daysHaveCircularBorder: null,

              /// null for not rendering any border, true for circular border, false for rectangular border
            ),
          ),
          SingleChildScrollView(
              child :Card(
                  margin: EdgeInsets.fromLTRB(14.0, 10.0, 14.0, 10.0),
                  color: Colors.orange[100],
                  child: Container(


                      child: Padding(
                          padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                          child: Center(
                              child: Text(
                                calendarText,
                                style: TextStyle(
                                  fontFamily: 'Product Sans',
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              )))))),
        ]);
  }


  void refresh(DateTime date) {
    print('selected date ' +
        date.day.toString() +
        date.month.toString() +
        date.year.toString() +
        ' ' +
        date.toString());
    if (_markedDateMap
        .getEvents(new DateTime(date.year, date.month, date.day))
        .isNotEmpty) {
      calendarText = _markedDateMap
          .getEvents(new DateTime(date.year, date.month, date.day))[0]
          .title;
    } else {
      calendarText = noEventText;
    }
  }
}


Widget _eventIcon = new Container(
  margin : EdgeInsets.symmetric(horizontal: 16.0),
  decoration: new BoxDecoration(
      color: Colors.amber[300],
      borderRadius: BorderRadius.all(Radius.circular(1000)),
      border: Border.all(color: Colors.blue, width: 2.0)),
  child: new Icon(
    Icons.person,
    color: Colors.amber,
  ),
);