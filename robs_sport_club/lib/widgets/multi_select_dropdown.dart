import 'package:flutter/material.dart';

class MultiSelectDropdown extends StatefulWidget {
  final List<String> items; // List of items to select from
  final ValueChanged<List<String>> onSelectionChanged; // Callback for when the selection changes

  const MultiSelectDropdown({
    Key? key,
    required this.items,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  MultiSelectDropdownState createState() => MultiSelectDropdownState();
}

class MultiSelectDropdownState extends State<MultiSelectDropdown> {
  final List<String> _selectedItems = []; // Stores the selected items

  // Method to reset the selection if needed
  void resetSelection() {
    setState(() {
      _selectedItems.clear();
      widget.onSelectionChanged(_selectedItems);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Validation to handle empty items list
    if (widget.items.isEmpty) {
      return const Text('No items available to select.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Children',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: widget.items.map((item) {
            final isSelected = _selectedItems.contains(item);
            return FilterChip(
              label: Text(item),
              selected: isSelected,
              tooltip: 'Select $item', // Accessibility improvement
              selectedColor: Colors.blue.shade200, // Highlight color for selected items
              backgroundColor: Colors.grey.shade200, // Background color for non-selected items
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedItems.add(item);
                  } else {
                    _selectedItems.remove(item);
                  }
                  widget.onSelectionChanged(_selectedItems);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
