import 'package:get/get.dart';

// Controllers
import '../../feature/auth/signup/controller/sign_up_controller.dart';
import '../../feature/auth/account text editing controller/account_text_editing_controller.dart';
import '../../feature/media/audio/controller/audio_paly_api_controller.dart';
import '../../feature/media/audio/controller/audio_summary_api_controller.dart';
import '../../feature/media/audio/controller/search_text_api_controller.dart';
import '../../feature/search/controller/searching_api_controller.dart';

class AppBindingsGetXDependencyInjection extends Bindings {
  @override
  void dependencies() {
    // 🔐 Auth / Account
    Get.lazyPut<AccountTextEditingController>(
          () => AccountTextEditingController(),
      fenix: true,
    );

    Get.lazyPut<SignUpApiController>(
          () => SignUpApiController(),
      fenix: true,
    );

    // 🔍 Search
    Get.lazyPut<SearchingApiController>(
          () => SearchingApiController(),
      fenix: true,
    );

    // 🎧 Audio / Media
    Get.lazyPut<AudioPlayApiController>(
          () => AudioPlayApiController(),
      fenix: true,
    );

    Get.lazyPut<AudioPlayApiControllers>(
          () => AudioPlayApiControllers(),
      fenix: true,
    );

    Get.lazyPut<AudioSummaryApiController>(
          () => AudioSummaryApiController(),
      fenix: true,
    );

    Get.lazyPut<SearchTextApiController>(
          () => SearchTextApiController(),
      fenix: true,
    );
  }
}
