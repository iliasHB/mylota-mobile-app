
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  if(Platform.isAndroid || Platform.isIOS){
    var notification = await Permission.notification.status;
    if(notification.isDenied){
      await Permission.notification.request();
    }
  }
}