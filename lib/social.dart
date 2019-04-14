import 'package:flutter/material.dart';
import 'themecolors.dart';
import 'auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profilepage.dart';
import 'package:flushbar/flushbar.dart';

/// SOCIAL
/// Data Structure
/// collection('users')
///   document(user.uid)
///     displayName: String
///     email: String
///     photoUrl: String
///     nickname: String (default: nickname = displayName)
///     bio: String (default: 'no bio set.')
///     friends: List<String> of friend uid(s)
///     requested: List<String> of uid(s) who have sent a friend request to the user
///     sentRequests: List<String> of uid(s) whom the user has sent a friend request

// AppBar for our Social screen
AppBar socialAppBar(BuildContext context) {
  return AppBar(
    title: Text("Social"),
    actions: <Widget>[
      IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            showSearch(
              context: context,
              delegate: SocialSearchDelegate(),
            );
            print("Searching friend!");
          }),
      PopupMenuButton(
          onSelected: (value) {
            switch (value) {
              case 0:
                switchAccounts().then((user) {
                  Flushbar(
                    message: 'Successfully switched accounts as ${user.displayName}!',
                    icon: Icon(Icons.check, color: Colors.white,),
                    duration: Duration(seconds: 3),
                  ).show(context);
                });
                break;
              default:
                throw (Exception("invalid value!"));
            }
          },
          itemBuilder: (context) => <PopupMenuEntry>[
                const PopupMenuItem(
                  value: 0,
                  child: Text('Switch accounts'),
                )
              ]),
    ],
  );
}

FloatingActionButton socialFloatingActionButton(BuildContext context) {
  return FloatingActionButton(
    child: Icon(Icons.person_add),
    elevation: 2.0,
    onPressed: () {
      showFriendList(context);
    },
  );
}

class SocialSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      query.isNotEmpty
          ? IconButton(
              tooltip: 'Clear',
              icon: Icon(Icons.clear),
              onPressed: () {
                query = '';
                showSuggestions(context);
              },
            )
          : Container(),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'back',
      icon: BackButtonIcon(),
      color: Colors.grey[700],
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(
      color: backgroundColor,
        child: (query.contains('@') &&
                query.contains('.')) //check whether it's an email
            ? StreamBuilder(
                stream: Firestore.instance
                    .collection('users')
                    .where('email', isEqualTo: query.trim())
                    .snapshots(),
                builder: (context, snapshot) {
                  return (snapshot.hasData)
                      ? ListView.builder(
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, n) {
                            return (user.email !=
                                    snapshot.data.documents[n]['email'])
                                ? SocialCard(
                                    photoUrl: snapshot.data.documents[n]
                                        ['photoUrl'],
                                    nickname: snapshot.data.documents[n]
                                        ['nickname'],
                                    email: snapshot.data.documents[n]['email'],
                                    uid: snapshot.data.documents[n].documentID)
                                : Container();
                          },
                        )
                      : CircularProgressIndicator();
                },
              )
            : StreamBuilder(
                stream: Firestore.instance
                    .collection('users')
                    .where('nickname', isEqualTo: query.trim())
                    .snapshots(),
                builder: (context, snapshot) {
                  return (snapshot.hasData)
                      ? ListView.builder(
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, n) {
                            return (user.email !=
                                    snapshot.data.documents[n]['email'])
                                ? SocialCard(
                                    photoUrl: snapshot.data.documents[n]
                                        ['photoUrl'],
                                    nickname: snapshot.data.documents[n]
                                        ['nickname'],
                                    email: snapshot.data.documents[n]['email'],
                                    uid: snapshot.data.documents[n].documentID,
                                  )
                                : Container();
                          },
                        )
                      : CircularProgressIndicator();
                },
              ));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: backgroundColor,
      child: Column(
        children: <Widget>[
          Text('Search for a person using his name or email!'),
          Text('Search for an email for greater accuracy..'),
        ],
      ),
    );
  }
}

class Social extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: auth.onAuthStateChanged,
        builder: (context, userSnapshot) {
          if (userSnapshot.hasData) {
            return Container(
              color: backgroundColor,
              child: Column(
                children: <Widget>[
                  StreamBuilder(
                      stream: Firestore.instance
                          .collection('users')
                          .document(userSnapshot.data.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        return (snapshot.hasData)
                            ? Row(
                                children: <Widget>[
                                  Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CircleImage(
                                        photoUrl: snapshot.data['photoUrl'],
                                        size: 70,
                                      )),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          snapshot.data['nickname'],
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          snapshot.data['bio'],
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Container();
                      }),
                  Divider(),
                  FriendRequests(),
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: <Widget>[
                        Text(
                          "Meetups",
                          style: TextStyle(
                            fontSize: 24.0,
                          ),
                        ),
                        Center(
                          child: GestureDetector(
                            child: Text("No meetups yet. Schedule one?"),
                            onTap: () {
                              print("Scheduling meetup!");
                            }, //TODO: Meetup scheduler
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }
}

class FriendRequests extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:
          Firestore.instance.collection('users').document(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List requested = snapshot.data[
              'requested']; //Array of uids of the people who requested for friend.
          if (requested != null) if (requested.isNotEmpty) {
            return Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      'Friend Requests',
                      style: TextStyle(fontSize: 14.0),
                    ),
                  ),
                  Flexible(
                    child: ListView.builder(
                        itemCount: requested.length,
                        itemBuilder: (context, index) {
                          return StreamBuilder(
                            stream: Firestore.instance
                                .collection('users')
                                .document(requested[index])
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final String nickname =
                                    snapshot.data['nickname'];
                                final String photoUrl =
                                    snapshot.data['photoUrl'];
                                final String email = snapshot.data['email'];
                                return FriendRequestCard(
                                  nickname: nickname,
                                  photoUrl: photoUrl,
                                  targetuid: requested[index],
                                  email: email,
                                );
                              } else
                                return Container();
                            },
                          );
                        }),
                  ),
                ],
              ),
            );
          } else
            return Container();
          else
            return Container();
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}

class FriendRequestCard extends StatelessWidget {
  final String nickname;
  final String photoUrl;
  final String targetuid;
  final String email;

  FriendRequestCard(
      {@required this.nickname,
      @required this.photoUrl,
      @required this.targetuid,
      @required this.email});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleImage(
                photoUrl: photoUrl,
                size: 50.0,
              ),
            ),
            Text(
              nickname,
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RaisedButton(
              color: Colors.brown[600],
              child: Text("VIEW"),
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ProfilePage(
                        photoUrl: photoUrl,
                        nickname: nickname,
                        uid: targetuid,
                        email: email,
                      ),
                ));
              }),
        )
      ],
    );
  }
}

class SocialCard extends StatelessWidget {
  final String photoUrl;
  final String nickname;
  final String email;
  final String uid;

  SocialCard({
    @required this.photoUrl,
    @required this.nickname,
    @required this.email,
    @required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ProfilePage(
                photoUrl: photoUrl,
                nickname: nickname,
                uid: uid,
                email: email,
              ),
        ));
      },
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: CircleImage(
              photoUrl: photoUrl,
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(0.5),
                  child: Text(
                    nickname,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.clip,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(0.5),
                  child: Text(
                    email,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[700],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CircleImage extends StatelessWidget {
  final String photoUrl;
  final double size;

  CircleImage({@required this.photoUrl, this.size: 60});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: NetworkImage(photoUrl),
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}

class Friend {
  final String photoUrl;
  final String nickname;
  Friend({@required this.photoUrl, @required this.nickname});
}

void showFriendList(BuildContext context) {
  showModalBottomSheet(context: context, builder: (context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.yellow[50],
        borderRadius: BorderRadius.only(
          topRight: const Radius.circular(10.0),
          topLeft: const Radius.circular(10.0),
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            height: 20.0,
            child: Center(
              child: Container(
                width: 40.0,
                height: 6.0,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.all(
                      Radius.circular(3.0)
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
                stream: Firestore.instance.collection('users').document(user.uid).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return FriendGridList(snapshot: snapshot,);
                  } else return Center(
                  child: CircularProgressIndicator(),
                  );
                }
            ),
          ),
        ],
      ),
    );
  });
}

class FriendGridList extends StatefulWidget {

  final AsyncSnapshot snapshot;

  const FriendGridList({Key key, @required this.snapshot}) : super(key: key);

  @override
  _FriendGridListState createState() => _FriendGridListState();
}

class _FriendGridListState extends State<FriendGridList> {

  String friendId;
  List<Friend> friends = [];

  @override
  void initState() {
    super.initState();
    for (int i=0; i<widget.snapshot.data['friends'].length; i++) {
      friendId = widget.snapshot.data['friends'][i];
      Firestore.instance.collection('users').document(friendId).get().then((document) {
        String nickname = document.data['nickname'];
        String photoUrl = document.data['photoUrl'];
        Friend friend = new Friend(nickname: nickname, photoUrl: photoUrl);
        print('nickname: ${friend.nickname}');
        print('photoUrl: ${friend.photoUrl}');
        friends.add(friend);
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (friends.length > 1) {
      friends.sort((a, b) => a.nickname.compareTo(b.nickname));
      return GridView.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 100.0,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: friends.length,
          itemBuilder: (context, n) {
            return Material(
              child: InkWell(
                onTap: () => print('Friend ${friends[n].nickname} tapped!'), //TODO: Add friends to meetup
                child: FriendCard(
                  nickname: friends[n].nickname,
                  photoUrl: friends[n].photoUrl,
                ),
              ),
            );
          }
      );
    } else return Center(child: CircularProgressIndicator(),);
  }
}

class FriendCard extends StatelessWidget {
  final String photoUrl;
  final String nickname;
  FriendCard({this.photoUrl, this.nickname});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CircleImage(photoUrl: photoUrl),
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Text(
            nickname,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
