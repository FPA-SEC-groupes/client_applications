import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RatingAlertDialog extends StatefulWidget {

  final String spaceTitle;
  final void Function(double)  onRatingUpdate;
  final double initialRating;
  final void Function()? submit;
  const RatingAlertDialog({Key? key, required this.spaceTitle, required this.onRatingUpdate, required this.initialRating, this.submit,}) : super(key: key);
  @override
  _RatingAlertDialogState createState() => _RatingAlertDialogState();
}

class _RatingAlertDialogState extends State<RatingAlertDialog> {

   double _rating =0;

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      title: Text('Rate ${widget.spaceTitle}'),
      content: RatingBar.builder(
        initialRating: widget.initialRating,
        minRating: 0,
        direction: Axis.horizontal,
        allowHalfRating: true,
        itemCount: 5,
        itemSize: 40,
        itemPadding: EdgeInsets.symmetric(horizontal: 3.0),
        itemBuilder: (context, _) => Icon(
          Icons.star,
          color: Colors.amber,
        ),
        onRatingUpdate: widget.onRatingUpdate
      ),
      actions: <Widget>[
        TextButton(
          child: Text('CANCEL'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("OK"),
          onPressed:widget.submit
        ),
      ],
    );
  }
}