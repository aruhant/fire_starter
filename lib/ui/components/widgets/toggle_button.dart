import 'package:fire_starter/controllers/theme_controller.dart';
import 'package:fire_starter/ui/components/widgets/glass/glass_card.dart';
import 'package:flutter/material.dart';

class ToggleButton<T> extends StatelessWidget {
  ToggleButton({this.labelText = '', required this.selected, this.padding = const EdgeInsets.all(22.0), required this.value, required this.onChange});

  final String labelText;
  final T value;
  final bool selected;
  final void Function(T) onChange;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChange(value),
      child: GlassCard(
        color: (selected) ? Theme.of(context).backgroundColor.withAlpha(180) : Theme.of(context).backgroundColor.withAlpha(30),
        borderWidth: selected ? 1 : 2,
        child: Padding(
          padding: padding,
          child: Wrap(
            children: [
              if (selected) Icon(Icons.check),
              Text(
                labelText,
                style: Theme.of(context).textTheme.headline6?.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}