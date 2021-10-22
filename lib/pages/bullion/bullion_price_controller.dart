import 'dart:async';

import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sonaar_retailer/models/bullion_price_model.dart';

class BullionPriceController extends GetxController {
  String socketUrl = "mcxratesupdate:App\\Events\\MCXRateUpdates";
  RxDouble goldPrice = 0.0.obs;
  RxDouble silverPrice = 0.0.obs;
  Color selectedColourSilver = Colors.black;
  Color selectedColourGold = Colors.black;
  Timer timerGold;
  Timer timerSilver;

  @override
  void onInit() {
    super.onInit();
    socketConnection();
  }

  SocketIO socket;

  Future socketConnection() async {
    SocketIOManager manager = SocketIOManager();
    socket = await manager.createInstance(SocketOptions(
      // Socket IO server URI
      "http://209.59.158.15:3001/",

      transports: [
        Transports.WEB_SOCKET /*, Transports.POLLING*/
      ],
    ));
    socket.onConnect((data) {
      print("Connected");
    });
    socket.onConnectError((data) => print(data));
    socket.onConnectTimeout((data) => print(data));
    socket.onError((data) => print(data));
    socket.onDisconnect((data) => print("Disconnected"));

    socket.on(socketUrl, (data) {
      List<BullionPriceModel> _priceList =
          BullionPriceModel.listFromString(data["updatedata"]);
      //print("api_data: " + data.toString());

      BullionPriceModel goldTemp =
          _priceList.singleWhere((element) => element.gold1Symbol == "GOLD-C");

      if (goldPrice.value > goldTemp.gold1Ask) {
        selectedColourGold = Colors.red;
        stopGoldTime();
        startGoldTimer();
      }else if (goldTemp.gold1Ask > goldPrice.value) {
        selectedColourGold = Colors.green;
        stopGoldTime();
        startGoldTimer();
      } else{
        selectedColourGold = Colors.black;
        stopGoldTime();
      }

      goldPrice.value = goldTemp.gold1Ask;

      BullionPriceModel silverTemp = _priceList
          .singleWhere((element) => element.gold1Symbol == "SILVER-C");

      if (silverPrice.value > silverTemp.gold1Ask) {
        selectedColourSilver = Colors.red;
        stopSilverTime();
        startSilverTimer();
      }else if(silverTemp.gold1Ask > silverPrice.value){
        selectedColourSilver = Colors.green;
        stopSilverTime();
        startSilverTimer();
      }else{
        selectedColourSilver = Colors.black;
        stopSilverTime();
      }

      silverPrice.value = silverTemp.gold1Ask;


    });
    socket.connect();
  }

  @override
  void onClose() {
    goldPrice.close();
    silverPrice.close();
    socket.off(socketUrl);
    super.onClose();
  }

  void stopGoldTime(){
    if(timerGold != null){
      print("Old timerGold Canceled");
      timerGold.cancel();
    }
  }

  void startGoldTimer(){
    print("New timerGold Registered");
    timerGold = Timer(Duration(milliseconds: 500), (){
      print("timerGold Executed");
      selectedColourSilver = Colors.black;
    });
  }

  void stopSilverTime(){
    if(timerSilver != null){
      print("Old timerSilver Canceled");
      timerSilver.cancel();
    }
  }

  void startSilverTimer(){
    print("New timerSilver Registered");
    timerSilver = Timer(Duration(milliseconds: 500), (){
      print("timerSilver Executed");
      selectedColourSilver = Colors.black;
    });
  }
}
