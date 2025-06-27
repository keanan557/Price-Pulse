import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({super.key});

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  List<String> names = [
    "joe",
    "davy",
    "johnny"
  ];
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pulse Price"),
        // Place SearchAnchor.bar directly in the appBar
        actions: [ // Use actions to place widgets next to the title
          Expanded( // Use Expanded to make the SearchAnchor take available space
            child: SearchAnchor.bar(
              suggestionsBuilder: (context, controller) {
                return names.where((e)=>controller.text.isEmpty ||
                    e.toLowerCase().contains(controller.text.toLowerCase()))
                    .map((e) => ListTile(
                  title: Text(e),
                  onTap: () {
                    controller.text = e; // Optional: set text when a suggestion is tapped
                    controller.closeView(e); // Close the search view and pass the selected item
                  },
                ));
              },
            ),
          ),
        ],
      ),
      body: Center(
        child: Text("Welcome to Pulse Price!"), // You can add other body content here
      ),
    );
  }
}