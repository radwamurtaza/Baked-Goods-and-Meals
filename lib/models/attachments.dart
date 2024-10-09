class Attachment {
  String postID;
  String contentURL;
  String type;

  Attachment({
    required this.postID,
    required this.contentURL,
    required this.type,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      postID: json['postID'],
      contentURL: json['contentURL'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() => {
        'postID': postID,
        'contentURL': contentURL,
        'type': type,
      };
}
