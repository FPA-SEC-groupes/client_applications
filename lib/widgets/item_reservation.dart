import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hello_way_client/models/command.dart';
import 'package:hello_way_client/models/reservation.dart';
import 'package:hello_way_client/res/app_colors.dart';
import 'package:hello_way_client/view_models/commands_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../models/theme_provider.dart';

class ItemReservation extends StatefulWidget {
  final Reservation reservation;

  const ItemReservation({
    super.key,
    required this.reservation,
  });

  @override
  State<ItemReservation> createState() => _ItemReservationState();
}

class _ItemReservationState extends State<ItemReservation> {
  late CommandsViewModel _listCommandsViewModel;

  @override
  void initState() {
    _listCommandsViewModel = CommandsViewModel(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      padding: const EdgeInsets.all(10),
      color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Reservation  N°${widget.reservation.idReservation} ",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: themeProvider.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: widget.reservation.status == "NOT_YET"
                    ? Colors.orangeAccent
                    : widget.reservation.status == "CONFIRMED"
                    ? Colors.green
                    : Colors.red,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                widget.reservation.status == "NOT_YET"
                    ? "En Attente"
                    : widget.reservation.status == "REFUSED"
                    ? "Refusée"
                    : widget.reservation.status == "CONFIRMED"
                    ? "Confirmée"
                    : "Annulée",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style.copyWith(
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
            children: <TextSpan>[
              TextSpan(
                text: widget.reservation.eventTitle.substring(0, 1).toUpperCase() +
                    widget.reservation.eventTitle.substring(1),
                style: const TextStyle(fontSize: 16),
              ),
              TextSpan(
                text: " (${widget.reservation.numberOfGuests} personnes)",
                style: const TextStyle(fontSize: 16, color: gray),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Text(
          widget.reservation.startDate.toString(),
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white70 : gray,
          ),
        ),
      ]),
    );
  }
}
