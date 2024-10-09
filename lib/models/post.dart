import 'package:bgm/models/attachments.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String id;
  String textContent;
  String byName;
  String byID;
  List<String> likesCount;
  List<Attachment> attachments;
  String createdAt;

  Post({
    required this.id,
    required this.byName,
    required this.byID,
    required this.textContent,
    required this.likesCount,
    required this.attachments,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    var _attachments = <Attachment>[];
    json['attachments'].forEach((v) {
      _attachments.add(Attachment.fromJson(v));
    });
    var _likesCount = <String>[];
    json['likes'].forEach((v) {
      _likesCount.add(v);
    });
    return Post(
      id: json['id'],
      byName: json['byName'],
      byID: json['byID'],
      textContent: json['textContent'],
      likesCount: _likesCount,
      attachments: _attachments,
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['byName'] = byName;
    data['byID'] = byID;
    data['textContent'] = textContent;
    data['likesCount'] = likesCount.map((v) => v).toList();
    data['attachments'] = attachments.map((v) => v.toJson()).toList();
    data['createdAt'] = createdAt;

    return data;
  }
}
