import 'dart:convert';

class BullionPriceModel {
  double gold1Bid;
  double gold1Ask;
  double gold1Low;
  double gold1Close;
  double gold1Ltp;
  String gold1Symbol;
  double gold1Open;
  double gold1High;

  BullionPriceModel({
    this.gold1Bid,
    this.gold1Ask,
    this.gold1Low,
    this.gold1Close,
    this.gold1Ltp,
    this.gold1Symbol,
    this.gold1Open,
    this.gold1High,
  });

  factory BullionPriceModel.fromJson(Map<String, dynamic> parsedJson) {
    return BullionPriceModel(
      gold1Bid: double.parse(parsedJson["gold1_bid"].toString()),
      gold1Ask: double.parse(parsedJson["gold1_ask"].toString()),
      gold1Low: double.parse(parsedJson["gold1_low"].toString()),
      gold1Close: double.parse(parsedJson["gold1_close"].toString()),
      gold1Ltp: double.parse(parsedJson["gold1_ltp"].toString()),
      gold1Symbol: parsedJson["gold1_symbol"],
      gold1Open: double.parse(parsedJson["gold1_open"].toString()),
      gold1High: double.parse(parsedJson["gold1_high"].toString()),
    );
  }

  static List<BullionPriceModel> listFromJson(List<dynamic> list) {
    List<BullionPriceModel> rows =
        list.map((i) => BullionPriceModel.fromJson(i)).toList();
    return rows;
  }

  static List<BullionPriceModel> listFromString(String responseBody) {
    return List<BullionPriceModel>.from(
        json.decode(responseBody).map((x) => BullionPriceModel.fromJson(x)));
  }

  Map<String, dynamic> toJson() => {
        "gold1_bid": gold1Bid,
        "gold1_ask": gold1Ask,
        "gold1_low": gold1Low,
        "gold1_close": gold1Close,
        "gold1_ltp": gold1Ltp,
        "gold1_symbol": gold1Symbol,
        "gold1_open": gold1Open,
        "gold1_high": gold1High,
      };
}
