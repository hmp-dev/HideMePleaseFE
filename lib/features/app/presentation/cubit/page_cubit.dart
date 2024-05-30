import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/app/core/helpers/preload_page_view/preload_page_view.dart';

part 'page_state.dart';

@lazySingleton
class PageCubit extends BaseCubit<PageState> {
  PageCubit() : super(PageState.initial());

  void changePage(int index) {
    state.pageController.jumpToPage(index);
  }
}
