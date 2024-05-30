import 'package:flutter/material.dart';
import 'package:hello_way_client/models/notifcation.dart' as notication;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../res/app_colors.dart';
import '../models/theme_provider.dart';

class ItemNotification extends StatefulWidget {
  final notication.Notification notification;
  final void Function()? onDelete;
  const ItemNotification({
    super.key,
    required this.notification,
    this.onDelete,
  });

  @override
  State<ItemNotification> createState() => _ItemNotificationState();
}

class _ItemNotificationState extends State<ItemNotification> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    DateTime now = DateTime.now();
    DateTime dateAutre = widget.notification.date;
    Duration difference = now.difference(dateAutre);

    return Container(
      padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 10),
      color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.notification.title,
                style: TextStyle(
                  fontSize: 18,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              InkWell(
                onTap: widget.onDelete,
                child: const Center(
                  child: Icon(
                    Icons.close,
                    color: gray,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Text(
              widget.notification.message,
              style: TextStyle(
                fontSize: 16,
                color: themeProvider.isDarkMode ? Colors.white70 : Colors.black,
              ),
            ),
          ),
          Text(
            difference.inSeconds < 60
                ? AppLocalizations.of(context)!
                .seconds
                .replaceAll('%s', difference.inSeconds.toString())
                : difference.inMinutes > 1 && difference.inMinutes < 60
                ? AppLocalizations.of(context)!
                .minutes
                .replaceAll('%m', difference.inMinutes.toString())
                : difference.inMinutes > 60 && difference.inHours < 24
                ? AppLocalizations.of(context)!
                .hours
                .replaceAll('%h', difference.inHours.toString())
                : "${widget.notification.date.year}-${widget.notification.date.month}-${widget.notification.date.day} ${widget.notification.date.hour}:${widget.notification.date.minute}",
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white60 : gray,
            ),
          ),
        ],
      ),
    );
  }
}
