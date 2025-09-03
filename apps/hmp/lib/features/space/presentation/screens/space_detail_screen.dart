import 'package:flutter/material.dart';
import 'package:mobile/app/core/cubit/cubit.dart';
import 'package:mobile/app/core/extensions/log_extension.dart';
import 'package:mobile/app/core/injection/injection.dart';
import 'package:mobile/app/core/util/observer_utils.dart';
import 'package:mobile/features/space/domain/entities/space_entity.dart';
import 'package:mobile/features/space/presentation/cubit/space_cubit.dart';
import 'package:mobile/features/space/presentation/views/space_detail_view.dart';

/// [SpaceDetailScreen] is the screen for displaying the details of a space.
///
/// This screen is used to display the details of a space such as its name,
/// description, address, and other relevant information.
class SpaceDetailScreen extends StatefulWidget {
  /// Default constructor for [SpaceDetailScreen].
  ///
  /// This constructor is used to create a new instance of [SpaceDetailScreen].
  const SpaceDetailScreen({super.key});

  /// Pushes [SpaceDetailScreen] on to the navigation stack.
  ///
  /// This method is used to push [SpaceDetailScreen] on to the navigation stack.
  /// It returns a [Future] that completes with the value returned by [Navigator.push].
  static Future<T?> push<T extends Object?>(BuildContext context) async {
    // Pushes [SpaceDetailScreen] on to the navigation stack and returns a [Future]
    // that completes with the value returned by [Navigator.push].
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
      backgroundColor: const Color(0xFFEAF8FF),
      body: SingleChildScrollView(
        child: BlocBuilder<SpaceCubit, SpaceState>(
          bloc: getIt<SpaceCubit>(),
          builder: (context, state) {
            if (state.submitStatus == RequestStatus.loading) {
              return const Center(child: SizedBox.shrink());
            }
            
            // 현재 선택된 매장의 전체 정보 찾기
            final currentSpace = state.spaceList.firstWhere(
              (space) => space.id == state.currentSpaceId,
              orElse: () => SpaceEntity.empty(),
            );
            
            return SpaceDetailView(
              space: state.spaceDetailEntity,
              spaceEntity: currentSpace,
            );
          },
        ),
      ),
    );
  }
}