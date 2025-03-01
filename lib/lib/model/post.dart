class Post {
  final int? id;
  final String? title;
  final String? content;
  final DateTime? datetime;
  final String? imgURL;
  final String? userId;

  Post(
      {
        required this.id,
        required this.title,
        required this.content,
        required this.datetime,
        required this.imgURL,
        required this.userId,
      });

}