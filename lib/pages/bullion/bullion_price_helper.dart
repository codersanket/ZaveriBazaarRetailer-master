class BullionPriceHelper {
  static String getLivePrice(double livePrice, double marginPrice) {
    //print("price_live" + livePrice.toString() + "_" + marginPrice.toString());
    double sumPrice = livePrice + marginPrice;
    double taxPrice = (sumPrice * 3.75) / 100;
    double totalPrice = sumPrice + taxPrice;
    return totalPrice.toInt().toString();
  }

  static String getEstimatedPrice(double livePrice, double marginPrice) {
    //print("price_estimated" + livePrice.toString() + "_" + marginPrice.toString());
    double sumPrice = livePrice + marginPrice;
    return sumPrice.toInt().toString();
  }
}
