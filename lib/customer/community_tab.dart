import 'dart:convert';
import 'dart:io';
import 'package:bgm/services/api_routes.dart';
import 'package:http/http.dart' as http;
import 'package:bgm/constants/constants.dart';
import 'package:bgm/customer/photo_screen.dart';
import 'package:bgm/customer/video_screen.dart';
import 'package:bgm/models/attachments.dart';
import 'package:bgm/models/post.dart';
import 'package:bgm/services/shopping_experience.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class CommunityPage extends StatefulWidget {
  bool isAdmin;

  CommunityPage({this.isAdmin = false});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  TextEditingController _postContentController = TextEditingController();
  List<String> postImages = [];
  List<String> postVideos = [];

  List<Post> posts = [];

  bool isPosting = false;
  String email = "";

  @override
  void initState() {
    super.initState();
    getPosts();
  }

  getPosts() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      email = preferences.getString("email")!;
      posts = [];
    });
    var response = await http.get(
      Uri.parse(
        APIRoutes.getAllPosts,
      ),
    );
    var jsonResponse = jsonDecode(response.body);
    print(jsonResponse['status']);
    print(jsonResponse['posts']);
    if (jsonResponse['status'] == 200) {
      var _posts = <Post>[];
      jsonResponse['posts'].forEach((v) {
        _posts.add(Post.fromJson(v));
        print(v);
      });
      setState(() {
        posts = _posts;
      });
    }
  }

  postIt(BuildContext context) async {
    setState(() {
      isPosting = true;
    });
    String postID = "";
    List<String> imageURLs = [];
    List<String> videoURLs = [];
    List<Attachment> attachments = [];

    if (postImages.length > 0) {
      imageURLs = await Future.wait(
        postImages.map(
          (_image) => uploadFile(
            File(
              _image,
            ),
          ),
        ),
      );
    }
    if (postVideos.length > 0) {
      videoURLs = await Future.wait(
        postVideos.map(
          (videos) => uploadFile(
            File(
              videos,
            ),
          ),
        ),
      );
    }

    imageURLs.forEach((element) {
      attachments.add(
        Attachment(
          postID: postID,
          contentURL: element,
          type: "image",
        ),
      );
    });
    videoURLs.forEach((element) {
      attachments.add(
        Attachment(
          postID: postID,
          contentURL: element,
          type: "video",
        ),
      );
    });

    // UPLOAD POST
    var response = await http.post(
      Uri.parse(
        APIRoutes.createPost,
      ),
      body: {
        "textContent": _postContentController.text,
        "byName": Provider.of<ShoppingExperience>(context, listen: false)
            .customerName
            .value,
        "byID": Provider.of<ShoppingExperience>(context, listen: false)
            .customerEmail
            .value,
        "createdAT": DateTime.now().toString(),
      },
    );

    var jsonResponse = jsonDecode(response.body);
    print(jsonResponse);

    if (jsonResponse['status'] == 200) {
      print("adding attachments");
      String newPostID = jsonResponse['postId'].toString();
      String extraMSG = "";
      if (attachments.length > 0) {
        extraMSG = " Please wait while we upload your attachments.";
      } else {
        getPosts();
        setState(() {
          isPosting = false;
          _postContentController.text = "";
          postImages = [];
          postVideos = [];
        });
      }
      Fluttertoast.showToast(msg: "Post created successfully.$extraMSG");
      if (attachments.length > 0) {
        print("STARTING ATTACHMENTS UPLOAD");
        await Future.wait(
          attachments.map(
            (attachment) async {
              var response = await http.post(
                Uri.parse(
                  APIRoutes.createAttachment,
                ),
                body: {
                  "postID": newPostID,
                  "contentURL": attachment.contentURL,
                  "type": attachment.type,
                },
              );
              var jsonResponse = jsonDecode(response.body);
              print(jsonResponse);
            },
          ),
        );
        getPosts();
        setState(() {
          isPosting = false;
          _postContentController.text = "";
          postImages = [];
          postVideos = [];
        });
      }
    } else {
      Fluttertoast.showToast(msg: "Couldn't create post.");
      setState(() {
        isPosting = false;
      });
    }
  }

  getPostMedia() async {
    List<XFile> mediaObjects =
        await ImagePicker().pickMultipleMedia(imageQuality: 80);
    mediaObjects.forEach((element) {
      String type = lookupMimeType(element.path)!;
      print(element.path + " : " + type);
      if (type.split("/").first == "image") {
        setState(() {
          postImages.add(element.path);
        });
      } else {
        setState(() {
          postVideos.add(element.path);
        });
      }
    });
  }

  Future<String> uploadFile(File file) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
        APIRoutes.uploadFile,
      ),
    );

    request.files.add(await http.MultipartFile.fromPath(
      'file',
      file.path,
      filename: basename(file.path),
    ));

    var response = await request.send();

    if (response.statusCode == 200) {
      var jsonResponse =
          await jsonDecode(await response.stream.bytesToString());
      return jsonResponse["downloadURL"];
    }
    return "no_file";
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
                // image: DecorationImage(
                //   image: AssetImage('assets/bg.png'),
                //   fit: BoxFit.cover,
                // ),
                color: AppConst.primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 75,
                  color: AppConst.primaryColor,
                  child: Align(
                    alignment: Alignment.center,
                    child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                "assets/back_ic.png",
                              ),
                            ),
                          ),
                          Text(
                            '${Provider.of<ShoppingExperience>(context, listen: true).customerName.value}',
                            style: GoogleFonts.dmSans(
                              color: AppConst.secondaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                isPosting
                    ? Container(
                        color: AppConst.primaryColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Center(
                              child: CircularProgressIndicator(
                                color: AppConst.accentColor,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                "Uploading media to server... This may take a while depending on the size of this post.",
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      )
                    : Container(
                        color: AppConst.primaryColor,
                        child: Wrap(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: _postContentController,
                                onChanged: (value) {
                                  setState(() {});
                                },
                                validator: (value) {
                                  if (value!.length < 50) {
                                    return "Please enter at least 50 characters.";
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText:
                                      "Share something with the community.",
                                  labelStyle: GoogleFonts.dmSans(
                                    color: AppConst.secondaryColor,
                                  ),
                                  hintStyle: GoogleFonts.dmSans(
                                    color: AppConst.secondaryColor,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: AppConst.secondaryColor,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: AppConst.secondaryColor,
                                    ),
                                  ),
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      getPostMedia();
                                    },
                                    child: Icon(
                                      Icons.attach_file,
                                      color: AppConst.secondaryColor,
                                    ),
                                  ),
                                ),
                                maxLines: 2,
                                maxLength: 1000,
                              ),
                            ),
                            if ((postImages.length + postVideos.length) > 0)
                              GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return ListView(
                                        children: postImages.map((image) {
                                          return ListTile(
                                            title: Text(image.split("/").last),
                                            trailing: IconButton(
                                              icon: Icon(Icons.delete),
                                              onPressed: () {
                                                setState(() {
                                                  postImages.remove(image);
                                                });
                                                Navigator.pop(context);
                                              },
                                            ),
                                          );
                                        }).toList()
                                          ..addAll(postVideos.map((video) {
                                            return ListTile(
                                              title:
                                                  Text(video.split("/").last),
                                              trailing: IconButton(
                                                icon: Icon(Icons.delete),
                                                onPressed: () {
                                                  setState(() {
                                                    postVideos.remove(video);
                                                  });
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            );
                                          }).toList()),
                                      );
                                    },
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        "${(postImages.length + postVideos.length).toString()} Attachment(s)",
                                        style: TextStyle(
                                          color: AppConst.secondaryColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Icon(
                                        Icons.edit,
                                        size: 15,
                                        color: AppConst.secondaryColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            SizedBox(
                              height: 5,
                            ),
                            if (((postImages.length + postVideos.length) > 0) ||
                                _postContentController.text != "")
                              GestureDetector(
                                onTap: () {
                                  postIt(context);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      10,
                                    ),
                                    color: AppConst.accentColor,
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14.0,
                                      ),
                                      child: Text(
                                        "Post",
                                        style: TextStyle(
                                          color: AppConst.secondaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                Expanded(
                  child: ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      return PostCard(
                        isLiked: posts[index].likesCount.contains(email),
                        isAdmin: false,
                        post: posts[index],
                        onLike: () async {
                          if (posts[index].likesCount.contains(email)) {
                            var response = await http.post(
                              Uri.parse(
                                APIRoutes.unlikePost,
                              ),
                              body: {
                                "postID": posts[index].id,
                                "email": email,
                              },
                            );
                            var jsonResponse = jsonDecode(response.body);
                            print(jsonResponse);
                            if (jsonResponse['status'] == 200) {
                              setState(() {
                                posts[index].likesCount.remove(email);
                              });
                            }
                          } else {
                            var response = await http.post(
                              Uri.parse(
                                APIRoutes.likePost,
                              ),
                              body: {
                                "postID": posts[index].id,
                                "email": email,
                              },
                            );
                            var jsonResponse = jsonDecode(response.body);
                            print(jsonResponse);
                            if (jsonResponse['status'] == 200) {
                              setState(() {
                                posts[index].likesCount.add(email);
                              });
                            }
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final Post post;
  bool isLiked;
  bool isAdmin;
  final VoidCallback onLike;

  PostCard({
    required this.post,
    required this.onLike,
    required this.isLiked,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              title: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        100,
                      ),
                      gradient: LinearGradient(
                        colors: [
                          AppConst.primaryColor,
                          AppConst.accentColor,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15.0,
                        vertical: 12,
                      ),
                      child: Text(
                        post.byName.split(" ").map((e) => e[0]).join(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    post.byName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isAdmin) Spacer(),
                  if (isAdmin)
                    GestureDetector(
                      onTap: () {
                        FirebaseFirestore.instance
                            .collection("posts")
                            .doc(post.id)
                            .delete();
                      },
                      child: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    )
                ],
              ),
              subtitle: post.textContent != ""
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post.textContent),
                        ],
                      ),
                    )
                  : null,
            ),
            if (post.attachments.length > 0)
              Container(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: post.attachments.length,
                  itemBuilder: (context, index) {
                    VideoPlayerController? controller;
                    if (post.attachments[index].type == "video") {
                      controller = VideoPlayerController.networkUrl(
                        Uri.parse(
                          post.attachments[index].contentURL,
                        ),
                      );

                      controller.initialize();
                      controller.pause();
                    }
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: post.attachments[index].type == "video"
                              ? GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => VideoScreen(
                                          url: post
                                              .attachments[index].contentURL,
                                        ),
                                      ),
                                    );
                                  },
                                  child: SizedBox(
                                    height: 200,
                                    width: post.attachments.length > 1
                                        ? 200
                                        : MediaQuery.of(context).size.width,
                                    child: Stack(
                                      children: [
                                        Hero(
                                          tag: "video",
                                          child: VideoPlayer(
                                            controller!,
                                          ),
                                        ),
                                        Positioned(
                                          top: 10,
                                          left: 10,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              gradient: LinearGradient(
                                                colors: [
                                                  AppConst.primaryColor,
                                                  AppConst.accentColor,
                                                ],
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Icon(
                                                Icons.play_arrow,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PhotoScreen(
                                          url: post
                                              .attachments[index].contentURL,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Hero(
                                    tag: "photo",
                                    child: Center(
                                      child: CachedNetworkImage(
                                        height: 200,
                                        width: post.attachments.length > 1
                                            ? 200
                                            : 300,
                                        fit: BoxFit.cover,
                                        imageUrl:
                                            post.attachments[index].contentURL,
                                        progressIndicatorBuilder:
                                            (context, url, downloadProgress) =>
                                                LinearProgressIndicator(
                                          value: downloadProgress.progress,
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Icon(
                                          Icons.play_circle_fill,
                                          color: AppConst.secondaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: onLike,
                    child: Icon(
                      isLiked
                          ? CupertinoIcons.hand_thumbsup_fill
                          : CupertinoIcons.hand_thumbsup,
                      color: AppConst.primaryColor,
                    ),
                  ),
                  Text(
                      '${post.likesCount.length} Likes | ${post.attachments.length.toString()} Attachment(s)'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
