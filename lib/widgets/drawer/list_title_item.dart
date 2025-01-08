import 'package:flutter/material.dart';
import 'package:image_viewer_app/permissions/access_checker.dart';

class ListTitleItem extends StatelessWidget {
  final String title;
  final String? env;
  final bool additionalShowCondition;
  final IconData iconData;
  final void Function() onTap;

  const ListTitleItem({
    super.key,
    required this.title,
    this.env,
    this.additionalShowCondition = true,
    required this.iconData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if ((env != null && !isFeatureAvailable(env)) || !additionalShowCondition) {
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
