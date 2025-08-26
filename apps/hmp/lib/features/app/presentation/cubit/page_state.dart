part of 'page_cubit.dart';

class PageState extends BaseState {
  final PreloadPageController pageController;
  final MenuType menuType;
  final bool showBottomBar;

  @override
  final RequestStatus submitStatus;

  const PageState({
    required this.pageController,
    required this.menuType,
    this.showBottomBar = true,
    this.submitStatus = RequestStatus.initial,
  });

  factory PageState.initial() => PageState(
      submitStatus: RequestStatus.initial,
      menuType: MenuType.space,
      showBottomBar: true,
      pageController: PreloadPageController(initialPage: 0));

  @override
  List<Object?> get props => [pageController, menuType, submitStatus, showBottomBar];

  @override
  PageState copyWith({
    RequestStatus? status,
    MenuType? menuType,
    bool? showBottomBar,
  }) {
    return PageState(
      pageController: pageController,
      menuType: menuType ?? this.menuType,
      showBottomBar: showBottomBar ?? this.showBottomBar,
      submitStatus: status ?? submitStatus,
    );
  }
}
