/* (23/4/'19) IMPORTANT: BELOW CONTAINS PROTOTYPING CODES THAT HAVE YET TO BE
PROPERLY IMPLEMENTED, PLEASE DO NOT MODIFY! -T
 */

import 'package:flutter/material.dart';

/* TO-DO:
* - Create a screen for timetable list
* - Implement gesture control to switch from a selected date on calendar
*   in timetable.dart to timetable list
* - Create an 'add event' pop up widget for people to add event
* - Use the empty gesture control of 'Add event' button to call the pop up
*   widget
* */


/* Building layout for timetable list, 100% workable, design not final,
 * coded to be customisable for all children */

class Test1 extends StatelessWidget {

  /* The _card function is to generate individual card widgets for the list
  * view without overcrowding the ListView with repetitive code*/
  Widget _card(context,label){
    return new Container(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment:MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(label),
          Container(
            height: 30,
            width: 2,
            color: Colors.grey[400],
          ),
          RaisedButton(
            onPressed: (){},
            child: const Text('+ Add Event'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        children: [
          _card(context, '0000-0100'),
          _card(context, '0100-0200'),
          _card(context, '0200-0300'),
          _card(context, '0300-0400'),
          _card(context, '0400-0500'),
          _card(context, '0500-0600'),
          _card(context, '0600-0700'),
          _card(context, '0700-0800'),
          _card(context, '0800-0900'),
          _card(context, '0900-1000'),
          _card(context, '1000-1100'),
          _card(context, '1100-1200'),
          _card(context, '1200-1300'),
          _card(context, '1300-1400'),
          _card(context, '1400-1500'),
          _card(context, '1500-1600'),
          _card(context, '1600-1700'),
          _card(context, '1700-1800'),
          _card(context, '1800-1900'),
          _card(context, '1900-2000'),
          _card(context, '2000-2100'),
          _card(context, '2100-2200'),
          _card(context, '2200-2300'),
          _card(context, '2300-0000'),
        ],
      ),
    );
  }
}