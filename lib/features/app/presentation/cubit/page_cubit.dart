import 'package:injectable/injectable.dart';
import 'package:mobile/app/core/cubit/base_cubit.dart';
import 'package:mobile/app/core/enum/menu_type.dart';
import 'package:mobile/app/core/helpers/preload_page_view/preload_page_view.dart';

part 'page_state.dart';

@lazySingleton
class PageCubit extends BaseCubit<PageState> {
  PageCubit() : super(PageState.initial());

  void changePage(int index, MenuType menuType) {
    state.pageController.jumpToPage(index);
    emit(state.copyWith(menuType: menuType));
  }
}
