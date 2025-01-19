import 'package:flutter/material.dart';

class ListTitleItem extends StatelessWidget {
  final String title;
  final bool featureEnabled;
  final bool additionalShowCondition;
  final IconData iconData;
  final void Function() onTap;

  const ListTitleItem({
    super.key,
    required this.title,
    this.featureEnabled = true,
    this.additionalShowCondition = true,
    required this.iconData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!featureEnabled || !additionalShowCondition) {
      return Container();
    }

    return ListTile(
      leading: Icon(iconData,
          size: 25, color: Theme.of(context).colorScheme.onSurface),
      title: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(color: Theme.of(context).colorScheme.onSurface),
      ),
      onTap: onTap,
    );
  }
}
