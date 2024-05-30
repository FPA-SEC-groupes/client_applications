import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../res/app_colors.dart';
import '../../response/product_with_quantity.dart';
import '../models/command.dart';
import '../services/network_service.dart';
import '../shimmer/item_product_menu_shimmer.dart';
import '../view_models/commands_view_model.dart';
import '../widgets/item_product_command.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class CommandDetails extends StatefulWidget {
  final Command command;
  final double sum;
  const CommandDetails(
      {super.key, required this.command, required this.sum});

  @override
  State<CommandDetails> createState() => _CommandDetailsState();
}

class _CommandDetailsState extends State<CommandDetails> {
  late final CommandsViewModel _commandsViewModel;
  final GlobalKey<ScaffoldMessengerState> _detailsCommandScaffoldKey =
  GlobalKey<ScaffoldMessengerState>();
  Future<List<ProductWithQuantities>> _getProductsByCommandId() async {
    List<ProductWithQuantities> products = await _commandsViewModel
        .getProductsByCommandId(widget.command.idCommand);
    return products;
  }

  @override
  void initState() {
    _commandsViewModel = CommandsViewModel(context);
    _getProductsByCommandId();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    NetworkStatus networkStatus = Provider.of<NetworkStatus>(context);
    return ScaffoldMessenger(
        key: _detailsCommandScaffoldKey,
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: orange,
        title: Text(
          "${AppLocalizations.of(context)!.order} N°${widget.command.idCommand}",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body:networkStatus == NetworkStatus.Online
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${AppLocalizations.of(context)!.order}  N°${widget.command.idCommand}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if(widget.command.status=="CONFIRMED"|| widget.command.status == "PAYED")
                    Text(
                      "${AppLocalizations.of(context)!.total}: ${widget.sum}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: widget.command.status ==
                                "NOT_YET"
                            ? Colors.orangeAccent
                            : widget.command.status ==
                                    "REFUSED"
                                ? Colors.red
                                : Colors.green,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        widget.command.status == "NOT_YET"
                            ? AppLocalizations.of(context)!.pendingStatus
                            : widget.command.status ==
                                    "REFUSED"
                                ? AppLocalizations.of(context)!.refusedStatus
                                : widget.command.status ==
                                        "CONFIRMED"
                                    ? AppLocalizations.of(context)!.confirmedStatus
                                    : AppLocalizations.of(context)!.paidStatus,
                        style: const TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          Container(
            color: lightGray,
            height: 10,
          ),
          Expanded(
            child: FutureBuilder(
                future: _getProductsByCommandId(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListView.separated(
                      itemCount: 5,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return const ItemProductCommandShimmer();
                      },
                    );
                  } else if (snapshot.hasError) {
                    return  Center(
                      child: Text(AppLocalizations.of(context)!.errorRetrievingData),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center();
                  } else {
                    final products = snapshot.data!;
                    return ListView.separated(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        ProductWithQuantities productWithQuantities =
                            products[index];

                        return ItemProductCommand(
                          productWithQuantities: productWithQuantities,
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Container(
                          color: lightGray,
                          height: 10,
                        );
                      },
                    );
                  }
                }),
          ),


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
      ),
    ));
  }
}
