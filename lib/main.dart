import 'package:flutter/material.dart';
import 'dart:math'; // for max function
import 'package:http/http.dart' as http;
import 'package:my_content/login_screen.dart';
import 'package:my_content/verify_screen.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

// self lib
import 'package:my_content/link_preview.dart';
import 'package:my_content/post_comment.dart';
import 'package:my_content/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.light(),
      home: const MyHomePage(title: 'THRIM'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String STAGE = "verify";
  String verificationCode = "";
  String phoneNumber = "";

  void changeStage(_stage, _verificationCode) {
    setState(() {
      STAGE = _stage;
    });
    if (_stage == "verify") {
      setState(() {
        verificationCode = _verificationCode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return STAGE == "register"
        ? LoginScreen(changeStage: changeStage)
        : STAGE == "verify"
            ? VerifyLogin(
                changeStage: changeStage,
                verificationCode: verificationCode,
                phoneNumber: phoneNumber)
            : const MyStatelessWidget();
  }
}

class MyStatelessWidget extends StatefulWidget {
  const MyStatelessWidget({Key? key}) : super(key: key);

  @override
  _ContainerCardWidgetState createState() => _ContainerCardWidgetState();
}

class _ContainerCardWidgetState extends State<MyStatelessWidget> {
  List<Album> listView = [];

  Future<Null> fetchAlbum() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.1.36:5000/post/ac8654'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        listView = [];
        setState(() {
          jsonData['data'].forEach((json) {
            listView.add(Album.fromJson(json));
          });
        });
      } else {
        throw Exception('Failed to load album');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAlbum();
  }

  void isLike(int newLike, String postId, int oldLike) {
    var jsonData = jsonEncode({
      'newLike': newLike,
      'oldLike': oldLike,
      'userId': 'ac8654',
      'postId': postId
    });
    http.put(Uri.parse('http://192.168.1.36:5000/post/is-like'),
        body: jsonData,
        headers: {"Content-Type": "application/json"}).then((res) {
      if (jsonDecode(res.body)['status'] == 'success') {
        fetchAlbum();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(children: [
          Text("THRIM",
              style: const TextStyle(
                  color: Color.fromARGB(255, 204, 0, 61),
                  fontWeight: FontWeight.w900)),
          const Spacer(),
          Container(
              margin: const EdgeInsets.only(right: 10),
              padding:
                  const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  // border: Border.all(
                  //     color: Color.fromARGB(255, 180, 0, 54), width: 0),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset:
                          const Offset(1.5, 1.5), // changes position of shadow
                    ),
                  ]),
              child: const Text("246",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 14))),
          FlatButton(
              minWidth: 24,
              onPressed: () => {},
              child: const Icon(Icons.notifications, color: Colors.black))
        ]),
        elevation: 0,
      ),
      body: Center(
          child: Padding(
              padding: const EdgeInsets.all(5),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return SingleChildScrollView(
                      child: ConstrainedBox(
                          constraints: BoxConstraints.tightFor(
                              height: max(500, constraints.maxHeight)),
                          child: Scrollbar(
                              child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  // child: new CardWidget(listView: listView),
                                  child: ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: listView.length,
                                      itemBuilder: (context, i) {
                                        return CardWidget(
                                            listView: listView[i],
                                            isLike: isLike);
                                      })))));
                },
              ))),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        tooltip: 'Increment',
        backgroundColor: const Color.fromARGB(255, 5, 41, 82),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Album {
  final String id, name, avatar, text, image;
  final int like, comment;
  final users;

  const Album(
      {required this.id,
      required this.name,
      required this.avatar,
      required this.text,
      required this.image,
      required this.like,
      required this.comment,
      required this.users});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['_id'],
      name: json['name'],
      avatar: json['avatar'],
      text: json['text'],
      image: json['image'],
      like: json['like'],
      comment: json['comment'],
      users: json['users'],
    );
  }
}

class CardWidget extends StatefulWidget {
  const CardWidget({Key? key, required this.listView, required this.isLike})
      : super(key: key);
  final Album listView;
  final void Function(int, String, int) isLike;

  @override
  _CardWidgetState createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  void _modalComments(context) {
    showModalBottomSheet(
        isScrollControlled: true,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        context: context,
        builder: (BuildContext bc) {
          return Post_Comment();
        });
  }

  @override
  Widget build(BuildContext context) {
    final int oldLike = widget.listView.users.length > 0
        ? widget.listView.users[0]['isLike']
        : 0;
    final List listText = widget.listView.text.split(' ');
    String url_preview = "";
    for (final text in listText) {
      if (Uri.parse(text).isAbsolute) {
        url_preview = text;
        break;
      }
    }

    return SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Card(
            color: Colors.white,
            margin: const EdgeInsets.all(5),
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  Row(children: [
                    widget.listView.avatar != ''
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: Image.asset(widget.listView.avatar,
                                width: 35, height: 35, fit: BoxFit.cover))
                        : Container(),
                    Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: Text(widget.listView.name,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w800)))
                  ]),
                  Column(
                    children: [
                      Container(
                          alignment: Alignment.topLeft,
                          margin: const EdgeInsets.only(top: 10),
                          // child: Text(widget.listView.text),
                          child: Wrap(
                              children: listText.map((e) {
                            final _url = Uri.parse(e);
                            bool _validURL = _url.isAbsolute;
                            return _validURL
                                ? GestureDetector(
                                    child: Text(e,
                                        style: TextStyle(
                                            decoration:
                                                TextDecoration.underline,
                                            color: Colors.blue)),
                                    onTap: () async {
                                      await launchUrl(_url);
                                    },
                                  )
                                : Text('$e ');
                          }).toList())),
                      widget.listView.image != ''
                          ? Container(
                              margin: const EdgeInsets.only(top: 10),
                              child: Image.asset(widget.listView.image))
                          : url_preview != ''
                              ? LinkPreview(url_preview: url_preview)
                              : Container()
                    ],
                  ),
                  Container(
                      alignment: Alignment.centerLeft,
                      margin: const EdgeInsets.only(top: 15),
                      child: Row(
                        children: [
                          FlatButton(
                            color: Colors.white,
                            padding: const EdgeInsets.all(10),
                            minWidth: 24,
                            onPressed: () =>
                                widget.isLike(1, widget.listView.id, oldLike),
                            child: oldLike != 1
                                ? const Icon(Icons.thumb_up_off_alt,
                                    color: Color.fromARGB(255, 114, 114, 114),
                                    size: 24)
                                : const Icon(Icons.thumb_up_alt,
                                    color: Color.fromARGB(255, 114, 114, 114),
                                    size: 24),
                          ),
                          Container(
                              margin: const EdgeInsets.only(left: 5),
                              child: Text(widget.listView.like.toString())),
                          // Text((sLike).toString())),
                          Container(
                              margin: const EdgeInsets.only(left: 5),
                              child: FlatButton(
                                color: Colors.white,
                                padding: const EdgeInsets.all(10),
                                minWidth: 24,
                                onPressed: () => widget.isLike(
                                    -1, widget.listView.id, oldLike),
                                child: oldLike != -1
                                    ? const Icon(Icons.thumb_down_off_alt,
                                        color:
                                            Color.fromARGB(255, 114, 114, 114),
                                        size: 24)
                                    : const Icon(Icons.thumb_down_alt,
                                        color:
                                            Color.fromARGB(255, 114, 114, 114),
                                        size: 24),
                              )),
                          Container(
                            margin: const EdgeInsets.only(left: 10),
                            child: FlatButton(
                                color: Colors.white,
                                padding: const EdgeInsets.all(10),
                                minWidth: 24,
                                onPressed: () => _modalComments(context),
                                child: const Icon(Icons.chat_bubble_outline,
                                    color: Color.fromARGB(255, 126, 126, 126),
                                    size: 22)),
                          ),
                          Container(
                              margin: const EdgeInsets.only(left: 5),
                              child: Text(widget.listView.comment.toString())),
                        ],
                      ))
                ],
              ),
            )));
  }
}
