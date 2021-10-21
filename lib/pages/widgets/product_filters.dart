import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sonaar_retailer/models/category.dart';
import 'package:sonaar_retailer/models/city.dart';
import 'package:sonaar_retailer/models/product_type.dart';
import 'package:sonaar_retailer/models/subcategory.dart';
import 'package:sonaar_retailer/models/weight_range.dart';
import 'package:sonaar_retailer/services/product_service.dart';
import 'package:flutter_range_slider/flutter_range_slider.dart' as RS;
import 'package:sonaar_retailer/services/user_tracking.dart';

class ProductFilters extends StatefulWidget {
  final Filter filter;
  final BuildContext parentContext;

  ProductFilters(this.filter, this.parentContext);

  @override
  ProductFiltersState createState() => ProductFiltersState(filter);
}

class ProductFiltersState extends State<ProductFilters> {
  final Filter filter;
  int expandedItem = -1;

  final weightFormKey = GlobalKey<FormState>();
  final weightFromController = TextEditingController();
  final weightToController = TextEditingController();

  ProductFiltersState(this.filter);

  @override
  void initState() {
    super.initState();
    weightFromController.text = filter.weightRangeLower.toString();
    weightToController.text = filter.weightRangeUpper.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(widget.parentContext).padding.top,
          bottom: MediaQuery.of(widget.parentContext).viewInsets.bottom,
        ),
        child: Column(
          children: <Widget>[
            Material(
              color: Colors.grey.shade200,
              child: ListTile(
                title: Text('Filter products'),
                trailing: IconButton(
                  icon: Icon(Icons.done),
                  onPressed: () {
                    final from = double.tryParse(weightFromController.text);
                    filter.weightRangeLower = from ?? filter.weightRange.lower;

                    final to = double.tryParse(weightToController.text);
                    filter.weightRangeUpper = to ?? filter.weightRange.upper;
                    Tracking.getFilterData(
                        filter.subcategories1.toString(),
                        filter.categoryId,
                        weightFromController.text,
                        weightToController.text,filter.searchkey,
                        filter.cities1.toString(),
                        filter.types1.toString());
                    Navigator.pop(context, 'filter');
                  },

                )
              ),
            ),
            Expanded(
              child: ListView(
                children: <Widget>[
                  // Categories
                  Visibility(
                    visible: filter.categories.length > 0,
                    child: ExpansionTile(
                      title: Text(
                        'Categories - ${getCount(filter.categories)} selected',
                      ),
                      children: filter.categories.map((s) {
                        return RadioListTile(
                          title: Text(s.name),
                          value: s.id,
                          groupValue: filter.categoryId,
                          onChanged: (val) {
                            setState(() => filter.categoryId = val);
                            onCategoryChange(val);
                          },
                        );
                      }).toList(),
                    ),
                  ),

                  // Subcategories
                  Visibility(
                    visible: filter.subcategories.length > 0,
                    child: ExpansionTile(
                      title: Text(
                        'Subcategories - ${getCount(filter.subcategories)} selected',
                      ),
                      children: filter.subcategories.map((s) {
                        return CheckboxListTile(
                          value: s.checked,
                          title: Text(s.name),
                          onChanged: (bool checked) {
                            //  setState(() => s.checked = checked);
                            setState(() {
                              s.checked = checked;
                              if (checked == true) {
                                // print("Name-"+s.name);
                                filter.subcategories1.add(s.name);

                                print("SubCategories Name-" +
                                    jsonEncode(filter.subcategories1));
                              } else if (checked == false) {
                                //print("Name-"+s.name);
                                filter.subcategories1.remove(s.name);

                                print("SubCategories Name-" +
                                    jsonEncode(filter.subcategories1));
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),

                  // Cities
                  Visibility(
                    visible: filter.cities.length > 0,
                    child: ExpansionTile(
                      title: Text(
                        'Cities - ${getCount(filter.cities)} selected',
                      ),
                      children: filter.cities.map((c) {
                        return CheckboxListTile(
                          value: c.checked,
                          title: Text(c.name),
                          onChanged: (bool checked) {
                            //  setState(() => c.checked = checked);
                            setState(() {
                              c.checked = checked;
                              if (checked == true) {
                                filter.cities1.add(c.name);
                                print("Cities Name-" +
                                    jsonEncode(filter.cities1));
                              } else if (checked == false) {
                                filter.cities1.remove(c.name);
                                print("Cities Name-" +
                                    jsonEncode(filter.cities1));
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),

                  // Types
                  Visibility(
                    visible: filter.types.length > 0,
                    child: ExpansionTile(
                      title: Text(
                          'Product types - ${getCount(filter.types)} selected'),
                      children: filter.types.map((t) {
                        return CheckboxListTile(
                          value: t.checked,
                          title: Text(t.name),
                          onChanged: (bool checked) {
                            // setState(() => t.checked = checked);
                            setState(() {
                              t.checked = checked;
                              if (checked == true) {
                                filter.types1.add(t.name);
                                print("Product type Name-" +
                                    jsonEncode(filter.types1));
                              } else if (checked == false) {
                                filter.types1.remove(t.name);
                                print("Product type Name-" +
                                    jsonEncode(filter.types1));
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),

                  // Weight range
                  // ListTile(
                  //   title: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: <Widget>[
                  //       Text(
                  //         'Weight range',
                  //       ),
                  //       Container(
                  //         height: 25,
                  //         width: 60,
                  //         child: FlatButton(
                  //           padding: EdgeInsets.all(0),
                  //           child: Text(
                  //             'Clear',
                  //             style: TextStyle(color: Colors.grey.shade700),
                  //           ),
                  //           color: Colors.grey.shade300,
                  //           onPressed: () {
                  //             setState(() {
                  //               weightFromController.text = filter.weightRange.lower.toString();
                  //               weightToController.text = filter.weightRange.upper.toString();

                  //             });
                  //           },
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  //   subtitle: Padding(
                  //     padding: EdgeInsets.only(top: 8.0),
                  //     child: _buildWeightForm(),/*RS.RangeSlider(
                  //       min: filter.weightRange.lower,
                  //       max: filter.weightRange.upper,
                  //       lowerValue: filter.weightRangeLower,
                  //       upperValue: filter.weightRangeUpper,
                  //       divisions:
                  //           (filter.weightRange.upper - filter.weightRange.lower)
                  //               .toInt(),
                  //       showValueIndicator: true,
                  //       valueIndicatorMaxDecimals: 0,
                  //       onChanged: (double newLower, double newUpper) {
                  //         setState(() {
                  //           filter.weightRangeLower = newLower;
                  //           filter.weightRangeUpper = newUpper;
                  //         });
                  //       },
                  //     ),*/
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ));
  }

  Widget _buildWeightForm() {
    return Form(
        key: weightFormKey,
        child: Table(
          children: [
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: TextFormField(
                    controller: weightFromController,
                    cursorColor: Theme.of(context).primaryColor,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'From',
                      isDense: true,
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: TextFormField(
                    controller: weightToController,
                    cursorColor: Theme.of(context).primaryColor,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'To',
                      isDense: true,
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                ),
              ],
            )
          ],
        ));
  }

  onCategoryChange(String categoryId) async {
    try {
      filter.subcategories = await ProductService.getSubcategories(categoryId);
    } catch (ignored) {}

    setState(() {});
  }

  getCount(var list) {
    int count = 0;
    list.forEach((item) {
      if (item.checked) count++;
    });
    return count;
  }

  getItems(var list) {
    list.forEach((item) {
      if (item.checked) {
        print('item' + item.toString());
      }
    });
  }
}

class Filter {
  // List<Melting> meltings = [];
  List<ProductType> types = [];
  List<String> types1 = [];
  List<Category> categories = [];
  String categoryId;
  List<Subcategory> subcategories = [];
  List<String> subcategories1 = [];
  List<City> cities = [];
  List<String> cities1 = [];
  WeightRange weightRange = WeightRange(lower: 0, upper: 0);
  // double weightRangeValue = 0;
  double weightRangeLower = 0, weightRangeUpper = 0;
  String searchkey='Search something';
}
