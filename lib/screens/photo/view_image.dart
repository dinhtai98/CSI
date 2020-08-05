import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_helloworld/utils/provider.dart';
import 'package:photo_view/photo_view.dart';

class ViewImage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    //Data data = InheritedProvider.of()
    // TODO: implement createState
    return new ViewImageState();
  }
}
class ViewImageState extends State<ViewImage> {
  @override
  Widget build(BuildContext context) {
    String url = InheritedProvider.of<String>(context);
    // TODO: implement build
    return Scaffold(
      appBar: new AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
      ),
      body: Container(
          color: Colors.black,
          child: PhotoView(
            imageProvider:new CachedNetworkImageProvider(
                url,
                errorListener: () => new Image.network("http://27.71.233.181:99/Images/icon_avatar.png")),
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 2,
          )
      ),
    );
  }

}