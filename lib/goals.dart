import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth.dart';
import 'goalcreationpage.dart';
import 'goalpage.dart';
import 'package:flushbar/flushbar.dart';

/// GOALS
/// Data Structure
/// collection('goals')
///   document(user.uid)
///     collection('userGoals')
///       totalDuration: Duration.toString TODO: implement calculation of totalDuration.
///       document(goal_id)
///         name: String
///         desc: String
///         timeSpent: Duration.toString
///         colorValue: Color.value
///         collection('events') TODO: implement adding events and calculating the duration.
///           document(event_id)
///             startTime: Timestamp
///             endTime: Timestamp

enum Layout {
  list,
  grid,
}

Layout currentLayout = Layout.list;

AppBar goalsAppBar(BuildContext context) {
  return AppBar(
    title: Text('Goals'),
    actions: <Widget>[
      IconButton(
        icon: (currentLayout == Layout.list)
            ? Icon(
                Icons.apps,
              )
            : Icon(
                Icons.list,
              ),
        onPressed: () =>
            print('Change layout'), //TODO: Change layout with stateful widget.
      ),
      IconButton(
        icon: Icon(Icons.settings),
        onPressed: () => print('Open settings'), //TODO: Goals settings: like whether to lock up the screen etc.? or shld we just lock the screen anyway
      )
    ],
  );
}

FloatingActionButton goalsFloatingActionButton(BuildContext context) {
  return FloatingActionButton(
    child: Icon(Icons.library_add),
    elevation: 2.0,
    onPressed: () {
      showDialog(
        context: context,
        builder: (context) {
          return GoalCreationPage();
        },
      );
    },
  );
}

class Goals extends StatefulWidget {
  @override
  _GoalsState createState() => _GoalsState();
}

class _GoalsState extends State<Goals> {
  @override
  Widget build(BuildContext context) {
    final BuildContext overallContext = context;
    return StreamBuilder(
        stream: Firestore.instance
            .collection('goals')
            .document(user.uid)
            .collection('userGoals')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List goalList = [];
            goalList = snapshot.data.documents
                .map((doc) {
                  return new Goal(
                      id: doc.documentID,
                      title: doc['title'],
                      color: Color(doc['colorValue']),
                      timeSpent: parseDuration(doc['timeSpent']),
                      selectedPuddingIndex: doc['selectedPuddingIndex'],
                    );
                })
                .toList();
            if (goalList.length != 0) {
              switch (currentLayout) {
                case Layout.list:
                  return ListView.builder(
                      itemCount: goalList.length,
                      itemBuilder: (context, i) {
                        final Goal currentGoal = goalList[i];
                        return Dismissible(
                          key: Key(currentGoal.id),
                          child: GoalsCard(
                            goal: currentGoal,
                          ),
                          direction: DismissDirection.endToStart,
                          background:  Container(
                            alignment: AlignmentDirectional.centerEnd,
                            color: Colors.green,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                              child: Icon(Icons.archive,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            bool confirmed;
                            await showDialog(
                                context: context,
                              builder: (context) {
                                  return AlertDialog(
                                    actions: <Widget>[
                                      FlatButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          confirmed = true;
                                        },
                                        child: Text('Yes'),
                                      ),
                                      FlatButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          confirmed = false;
                                        },
                                        child: Text('No'),
                                      ),
                                    ],
                                  );
                              }
                            );
                          },
                          onDismissed: (direction) {
                            archiveGoal(currentGoal).whenComplete(() {
                              setState(() {});
                              Flushbar(
                                message: 'Goal archived!',
                                mainButton: FlatButton(
                                  child: Text('Undo'),
                                  onPressed: () => unarchiveGoal(currentGoal).whenComplete(() {
                                    setState(() {});
                                  }),
                                ),
                                duration: Duration(seconds: 3),
                              ).show(overallContext);
                            });
                          },
                        );
                      }); //TODO: Implement ListView goals
                case Layout.grid:
                  return GridView.builder(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200.0),
                      itemBuilder: (context, i) {
                        return GoalsCard(
                          goal: goalList[i],
                        );
                      }); //TODO: Implement GridView goals
              }
            } else
              return Center(
                child: Text('No goals. Add new goal?'),
              );
          } else
            return Center(
              child: CircularProgressIndicator(),
            );
        });
  }
}

class Goal {
  String id;
  String title;
  Color color;
  Duration timeSpent;
  int selectedPuddingIndex;

  Goal(
      {this.id, @required this.title,
      @required this.timeSpent,
      @required this.color,
      this.selectedPuddingIndex: 0});
}

class GoalsCard extends StatelessWidget {
  final Goal goal;

  GoalsCard({@required this.goal});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, new MaterialPageRoute(builder: (context) => GoalPage(goal: goal))),
      child: Card(
        child: Container(
          height: 100.0,
          color: goal.color,
          child: ListTile(
            leading: Icon(Icons.library_music),
            title: Text(goal.title),
            subtitle: Text('Time spent: ${goal.timeSpent}, Selected Index: ${goal.selectedPuddingIndex}'),
          ),
        ),
      ),
    );
  }
}

Duration parseDuration(String s) {
  int hours = 0;
  int minutes = 0;
  int micros;
  List<String> parts = s.split(':');
  if (parts.length > 2) {
    hours = int.parse(parts[parts.length - 3]);
  }
  if (parts.length > 1) {
    minutes = int.parse(parts[parts.length - 2]);
  }
  micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
  return Duration(hours: hours, minutes: minutes, microseconds: micros);
}

Future<Goal> addGoalToDestination({@required Goal goal, @required String destination}) async {
  if (!['userGoals', 'archive'].contains(destination))
    throw Exception("Incorrect destination stated! Only 'userGoals' and 'archive' are allowed.");
  Goal addedGoal;
  await Firestore.instance
      .collection('goals')
      .document(user.uid)
      .collection(destination)
      .add({
    'title': goal.title,
    'colorValue': goal.color.value,
    'timeSpent': goal.timeSpent.toString(),
    'selectedPuddingIndex': goal.selectedPuddingIndex,
  }).then((doc) {
    goal.id = doc.documentID;
    addedGoal = goal;
  });
  return addedGoal;
}


Future<Goal> archiveGoal(Goal goal) async {
  Goal archivedGoal;
  await Firestore.instance.collection('goals').document(user.uid).collection('userGoals').document(goal.id).delete().whenComplete(() {
    addGoalToDestination(goal: goal, destination: 'archive').then((goal) => archivedGoal = goal);
  });
  return archivedGoal;
}

Future<Goal> unarchiveGoal(Goal goal) async {
  Goal unarchivedGoal;
  await Firestore.instance.collection('goals').document(user.uid).collection('archive').document(goal.id).delete().whenComplete(() {
    addGoalToDestination(goal: goal, destination: 'userGoals').then((goal) => unarchivedGoal = goal);
  });
  return unarchivedGoal;
}