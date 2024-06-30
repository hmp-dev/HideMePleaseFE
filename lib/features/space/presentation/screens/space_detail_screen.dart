import 'package:flutter/material.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/util/observer_utils.dart';
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';
import 'package:mobile/features/space/presentation/views/space_detail_view.dart';

class SpaceDetailScreen extends StatefulWidget {
  const SpaceDetailScreen({super.key});

  static push(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SpaceDetailScreen(),
      ),
    );
  }

  @override
  State<SpaceDetailScreen> createState() => _SpaceDetailScreenState();
}

class _SpaceDetailScreenState extends State<SpaceDetailScreen> with RouteAware {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ObserverUtils.routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPush() {
    // Screen was pushed onto the stack
    ('SecondScreen was pushed').log();
  }

  @override
  void didPopNext() {
    // Called when the top route has been popped off, and the current route shows up
    ('Returned back to SecondScreen').log();
    final state = getIt<SpaceCubit>().state;
    // fetch Space related Benefits
    getIt<SpaceCubit>()
        .onGetSpaceBenefitsOnSpaceDetailView(spaceId: state.currentSpaceId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: BlocBuilder<SpaceCubit, SpaceState>(
          bloc: getIt<SpaceCubit>(),
          builder: (context, state) {
            return state.submitStatus == RequestStatus.loading
                ? const Center(child: SizedBox.shrink())
                : SpaceDetailView(space: state.spaceDetailEntity);
          },
        ),
      ),
    );
  }
}
