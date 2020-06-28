import 'Types.dart';
import 'package:flutter/material.dart';

class ListViewComponentState extends State<ListViewComponent> {
  @override
  final Function getMoreItems;
  var renderedListItems = <ListItem>[];

  ListViewComponentState(this.getMoreItems);

  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(itemBuilder: (context, i) {
        if(i >= renderedListItems.length) {
          renderedListItems.addAll(
              this.getMoreItems()
          );
        }
        return buildRow(renderedListItems[i]);
      }),
    );
  }

  Widget buildRow(ListItem item) {
    return Card(
      child: ListTile(
          title: Text(item.title),
          subtitle: Text(item.subtitle)
      ),
    );
  }
}

class ListViewComponent extends StatefulWidget {
  @override
  final Function getMoreItems;
  ListViewComponent(this.getMoreItems);
  ListViewComponentState createState() => ListViewComponentState(this.getMoreItems);
}
