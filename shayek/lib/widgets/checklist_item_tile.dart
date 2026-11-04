import 'package:flutter/material.dart';

import '../models/packing_item.dart';

class ChecklistItemTile extends StatelessWidget {
  const ChecklistItemTile({super.key, required this.item, this.onChanged});

  final PackingItem item;
  final ValueChanged<bool?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: item.isPacked,
      onChanged: onChanged,
      title: Text(item.name),
      subtitle: Text('${item.category} • Quantity: ${item.quantity}'),
    );
  }
}
