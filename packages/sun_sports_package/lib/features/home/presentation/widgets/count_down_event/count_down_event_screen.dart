import 'package:flutter/material.dart';
import 'package:sun_sports/features/home/presentation/widgets/count_down_event/count_down_event_desktop.dart';
import 'package:sun_sports/features/home/presentation/widgets/count_down_event/count_down_event_mobile.dart';
import 'package:sun_sports/shared/responsive/responsive_layout.dart';

class CountDownEventScreen extends StatelessWidget {
  const CountDownEventScreen({super.key});

  @override
  Widget build(BuildContext context) => const ResponsiveLayout(
    mobile: CountDownEventMobile(),
    tablet: CountDownEventMobile(),
    desktop: CountDownEventDesktop(),
  );
}
