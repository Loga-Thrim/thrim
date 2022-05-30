import 'package:flutter/material.dart';
import 'package:my_content/helper/fetch_preview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkPreview extends StatefulWidget {
  const LinkPreview({Key? key, required this.url_preview}) : super(key: key);
  final String url_preview;

  @override
  _LinkPreviewState createState() => _LinkPreviewState();
}

class _LinkPreviewState extends State<LinkPreview> {
  var data;

  @override
  Widget build(BuildContext context) {
    return _buildPreviewWidget();
  }

  _buildPreviewWidget() {
    FetchPreview().fetch(widget.url_preview).then((res) {
      setState(() {
        data = res;
      });
    });

    if (data == null) {
      return Container();
    }
    return Container(
        color: Color.fromARGB(31, 224, 224, 224),
        margin: const EdgeInsets.only(top: 10),
        child: GestureDetector(
          onTap: () async {
            await launchUrl(Uri.parse(widget.url_preview));
          },
          child: Column(
            children: <Widget>[
              (data['image'] != '' && Uri.parse(data['image']).isAbsolute)
                  ? Image.network(
                      data['image'],
                      width: MediaQuery.of(context).size.width,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : Container(),
              Container(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      data['title'],
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      data['description'],
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Row(
                      children: <Widget>[
                        (data['favIcon'] != '' &&
                                Uri.parse(data['favIcon']).isAbsolute)
                            ? data['favIcon'].split('.').last == 'svg'
                                ? SvgPicture.network(
                                    data['favIcon'],
                                    height: 12,
                                    width: 12,
                                  )
                                : Image.network(
                                    data['favIcon'],
                                    height: 12,
                                    width: 12,
                                  )
                            : Container(),
                        // Text(data['favIcon']),
                        SizedBox(
                          width: 4,
                        ),
                        Text(widget.url_preview,
                            style: TextStyle(color: Colors.grey, fontSize: 12))
                      ],
                    )
                  ],
                ),
              )),
            ],
          ),
        ));
  }
}
