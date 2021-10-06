import 'package:flutter/material.dart';
import 'package:sonaar_retailer/models/city.dart';

class RatingFilters extends StatefulWidget {
  final RFilter filter;

  RatingFilters(this.filter);

  @override
  RatingFiltersState createState() => RatingFiltersState(filter);
}

class RatingFiltersState extends State<RatingFilters> {
  final RFilter filter;
  int expandedItem = -1;

  RatingFiltersState(this.filter);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Material(
          color: Colors.grey.shade200,
          child: ListTile(
            title: Text('Cities - ${getCount(filter.cities)} selected'),
            trailing: IconButton(
              icon: Icon(Icons.done),
              onPressed: () => Navigator.pop(context, 'filter'),
            ),
          ),
        ),
        Expanded(
          child: buildCitiesTile(),
        ),
      ],
    );
  }

  Widget buildCitiesTile() {
    return ListView(
      children: filter.cities.map((c) {
        return CheckboxListTile(
          value: c.checked,
          title: Text(c.displayName),
          activeColor: Colors.grey.shade600,
          onChanged: (bool checked) {
            setState(() => c.checked = checked);
          },
        );
      }).toList(),
    );
  }

  getCount(List<dynamic> list) {
    return list.where((i) => i.checked).length;
  }
}

class RFilter {
  List<City> cities = [];
}
