

import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:hello_way_client/models/reservation.dart';
import 'package:hello_way_client/models/space.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../res/strings.dart';
import '../../utils/secure_storage.dart';
import '../../widgets/button.dart';
import '../../widgets/input_form.dart';
import '../Widgets/app_bar.dart';
import '../res/app_colors.dart';
import '../services/network_service.dart';
import '../view_models/reservations_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class AddReservation extends StatefulWidget {
  final Space space;
  const AddReservation({Key? key, required this.space}) : super(key: key);

  @override
  State<AddReservation> createState() => _AddReservationState();
}

class _AddReservationState extends State<AddReservation> {
  late ReservationsViewModel _reservationsViewModel;
  final SecureStorage secureStorage = SecureStorage();
  final GlobalKey<FormState> _addNewReservationFormKey = GlobalKey<FormState>();
  Color suffixColorDate = Colors.grey;
  Color suffixColorStartTime = Colors.grey;
  Color suffixColorEndTime = Colors.grey;
  int nbOfGuests = 1;
  DateTime? _selectedDate;
  late final TextEditingController _eventTitleController,
      _dateController,
      _startTimeController,
      _endTimeController,
      _descriptionController;

  @override
  void initState() {

    _reservationsViewModel=ReservationsViewModel(context);
    _eventTitleController = TextEditingController();
    _dateController = TextEditingController();
    _startTimeController= TextEditingController();
    _endTimeController= TextEditingController();
    _descriptionController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _eventTitleController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void incrementNbOfGuests() {
    setState(() {
      nbOfGuests++;
    });
  }

  void decrementNbOfGuests() {
    if (nbOfGuests > 1) {
      setState(() {
        nbOfGuests--;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), firstDate:DateTime.now(),
      lastDate: DateTime(5000),
      // No firstDate or lastDate specified
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        DateFormat formatter = DateFormat('yyyy-MM-dd');
        String formatted = formatter.format(_selectedDate!);
        print(formatted);
        _dateController.text = formatted;
      });
    }
  }

  Future<TimeOfDay?> _selectTime(BuildContext context) async {
    TimeOfDay? selectedDateTime;
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      selectedDateTime=pickedTime;

    }




    return selectedDateTime;
  }


  String? validateStartTime(String? value) {
    DateTime currentTime = DateTime.now();


    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.inputRequiredError;
    } else {
      TimeOfDay startTime = stringToTimeOfDay(value);
      if(_dateController.text.trim().toString().isNotEmpty){
      DateTime startDate = DateTime.parse(_dateController.text.trim().toString());
      DateTime startDateTime = DateTime(startDate.year, startDate.month, startDate.day, startTime.hour, startTime.minute);

      if (startDateTime.isAfter(currentTime)) {
        return null; // Start date and time are valid
      }
      else {
      if (startTime.hour > currentTime.hour || (startTime.hour == currentTime.hour && startTime.minute > currentTime.minute)) {
        return null; // Start time is valid
      } else {
        return AppLocalizations.of(context)!.startTimeRequirment; // Start time is invalid
      }
      }}
    }
  }

  TimeOfDay stringToTimeOfDay(String timeString) {
    List<String> parts = timeString.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }


  String? _validateEndTime(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.inputRequiredError;
    } else {
      TimeOfDay startTime = stringToTimeOfDay(_startTimeController.text.trim());
      TimeOfDay endTime = stringToTimeOfDay(value);

      if (endTime.hour < startTime.hour ||
          (endTime.hour == startTime.hour && endTime.minute <= startTime.minute)) {
        return AppLocalizations.of(context)!.endTimeRequirment;
      }

      return null; // End time is valid
    }
  }

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar:  Toolbar(
          title: AppLocalizations.of(context)!.add
          ,
        ),
        body: networkStatus == NetworkStatus.Online
            ? Column(
          children: [
            Expanded(
              child: Form(
                key: _addNewReservationFormKey,
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.all(20.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.eventTitle,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          InputForm(
                            hint: AppLocalizations.of(context)!.eventHint,
                            controller: _eventTitleController,
                            validator: MultiValidator([
                              RequiredValidator(errorText: AppLocalizations.of(context)!.inputRequiredError),
                            ]),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.numGuestsTitle,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      decrementNbOfGuests();
                                    },
                                    child: Container(
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        border: Border.all(
                                          color: nbOfGuests > 1
                                              ? orange
                                              : gray, // Replace with your desired border color
                                          width:
                                              1.0, // Replace with your desired border width
                                        ),
                                        color: Colors.white,
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.remove,
                                          color: nbOfGuests > 1 ? orange : gray,
                                          size: 20.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    child: Text(
                                      nbOfGuests.toString(),
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      incrementNbOfGuests();
                                    },
                                    child: Container(
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        border: Border.all(
                                          color:
                                              orange, // Replace with your desired border color
                                          width:
                                              1.0, // Replace with your desired border width
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.add,
                                          color: orange,
                                          size: 20.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            AppLocalizations.of(context)!.reserveFor,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Focus(
                            onFocusChange: (hasFocus) {
                              setState(() {
                                (hasFocus)
                                    ? suffixColorDate = orange
                                    : suffixColorDate = Colors.grey;
                              });
                            },
                            child: TextFormField(
                                 validator:MultiValidator([
                                   RequiredValidator(errorText:  AppLocalizations.of(context)!.inputRequiredError),
                                 ]),
                                controller: _dateController,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 16),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: orange,
                                      )),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: orange,
                                      )),
                                  hintText: AppLocalizations.of(context)!.bookingDate,
                                  suffixIcon: Icon(
                                    Icons.calendar_today,
                                    color: suffixColorDate,
                                  ),
                                ),
                                readOnly:
                                    true, // when true user cannot edit text
                                onTap: () async {
                                  _selectDate(context);
                                  //when click we have to show the datepicker
                                }),
                          ),


                          const SizedBox(height: 10,),
                          Row(
                            children: [
                              Expanded(
                                child: Focus(
                                  onFocusChange: (hasFocus) {
                                    setState(() {
                                      (hasFocus)
                                          ? suffixColorStartTime = orange
                                          : suffixColorStartTime = Colors.grey;
                                    });
                                  },
                                  child: TextFormField(
                                      validator:validateStartTime,
                                      controller: _startTimeController,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 16),
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                              color: orange,
                                            )),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                              color: orange,
                                            )),
                                        hintText: AppLocalizations.of(context)!.startTime,
                                        suffixIcon: Icon(
                                          Icons.access_time_outlined,
                                          color:suffixColorStartTime,
                                        ),
                                      ),
                                      readOnly:
                                      true, // when true user cannot edit text
                                      onTap: () async {
                                        _selectTime(context).then((time) {
                                          _startTimeController.text=time!.format(context);
                                        }).catchError((error) {
                                          print(error);
                                        });
                                        //when click we have to show the datepicker
                                      }),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Focus(
                                  onFocusChange: (hasFocus) {
                                    setState(() {
                                      (hasFocus)
                                          ? suffixColorEndTime = orange
                                          : suffixColorEndTime = Colors.grey;
                                    });
                                  },
                                  child: TextFormField(
                                     validator:_validateEndTime,
                                      controller: _endTimeController,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 16),
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                              color: orange,
                                            )),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                              color: orange,
                                            )),
                                        hintText: AppLocalizations.of(context)!.endTime,
                                        suffixIcon: Icon(
                                          Icons.access_time_rounded,
                                          color: suffixColorEndTime,
                                        ),
                                      ),
                                      readOnly:
                                      true, // when true user cannot edit text
                                      onTap: () async {
                                        _selectTime(context).then((time) {
                                          _endTimeController.text=time!.format(context);
                                        }).catchError((error) {
                                          print(error);
                                        });
                                        //when click we have to show the datepicker
                                      }),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          InputForm(
                            maxLines: 5,
                            hint: AppLocalizations.of(context)!.description,
                            controller: _descriptionController,
                            validator: MultiValidator([
                              RequiredValidator(errorText:  AppLocalizations.of(context)!.inputRequiredError),
                            ]),
                          ),
                        ]),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Button(
                  text: AppLocalizations.of(context)!.validateReservation,
                  onPressed: () async {
                    if (_addNewReservationFormKey.currentState!.validate()) {
                      _addNewReservationFormKey.currentState!.save();


                      DateTime currentDate = DateTime.now();
                      print(currentDate);

                      Reservation reservation = Reservation(
                          status: "NOT_YET",
                          eventTitle: _eventTitleController.text.trim(),
                          numberOfGuests: nbOfGuests,
                          bookingDate: currentDate,
                          startDate: DateTime.parse("${_dateController.text.trim()} ${_startTimeController.text.trim()}"),
                         endDate:DateTime.parse("${_dateController.text.trim()} ${_endTimeController.text.trim()}") ,
                         description: _descriptionController.text);

                      _reservationsViewModel.addReservation(reservation,widget.space.id).then((user) {


                        Navigator.of(context).pop();
                      }).catchError((error) {
                        print(error);
                      });

                    }
                  },
                ),
              ),
            )
          ],
        ):Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.network_check,
                  size: 150,
                  color: gray,
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context)!.noInternet,
                  style: const TextStyle(fontSize: 22, color: gray),
                  textAlign: TextAlign.center,
                ),
                Text(
                  AppLocalizations.of(context)!.checkYourInternet,
                  style: const TextStyle(fontSize: 22, color: gray),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10,),
                MaterialButton(
                  color: orange,
                  height: 40,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  onPressed:(){
                    setState(() {

                    });
                  },


                  child: Text(
                    AppLocalizations.of(context)!.retry,
                    style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),

                )
              ],
            ),
          ),
        ));
  }
}
