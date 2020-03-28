import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:intl/intl.dart';

enum InfoStatus { loading, connectionError, success }

class Post {
  String title, downloadUrl, hashtags, taskId, thumbnail, url;

  int timeStamp;
  bool fullTitle = false;
  bool isVideo;
  Owner owner;
  String buttonTextt;
  InfoStatus infoStatus;
  bool isGoingToCancel = false;
  DownloadCallbackModel downloadCallbackModel;
  bool downloadIsLocked = false;
  bool isClicked = false;
  Post({
    this.url,
    this.isVideo,
    this.infoStatus,
    this.title,
    this.downloadUrl,
    this.timeStamp,
    this.owner,
    this.hashtags,
    this.thumbnail,
  });

  String get date => DateFormat('d/m/y - hh:mm ')
      .format(DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000));
  String get firstPart => title.substring(0, (title.length - 1) ~/ 2);
  String get getTitle {
    if (title.length <= 40) {
      return title;
    } else {
      return fullTitle ? title : firstPart;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'downloadUrl': downloadUrl,
      'date': timeStamp,
      'hashtags': hashtags,
      'owner': owner.toJson(),
      'thumbnail': thumbnail
    };
  }

  String get buttonText {
    var downloadStatus = downloadCallbackModel?.status;
    if (downloadStatus == DownloadTaskStatus.complete) {
      return 'اكتمل التحميل افتح الآن';
    } else if (downloadStatus == null && !downloadIsLocked) {
      return 'ابدأ التحميل';
    } else if (downloadStatus == DownloadTaskStatus.canceled) {
      return 'تم الغاء التحميل اعده مره اخري';
    } else if (downloadStatus == DownloadTaskStatus.running) {
      return 'بدأ التحميل انتظر';
    } else {
      return 'فشل التحميل اعده مره اخري';
    }
  }
}

class Owner {
  String profilePic, userName, profilePicHd;

  Owner({
    this.profilePic,
    this.profilePicHd,
    this.userName,
  });

  Map<String, dynamic> toJson() {
    return {
      'profilePic': profilePic,
      'userName': userName,
    };
  }
}

class DownloadCallbackModel {
  int progress;
  DownloadTaskStatus status;
  String taskId;
  DownloadCallbackModel(this.progress, this.status, this.taskId);
}
