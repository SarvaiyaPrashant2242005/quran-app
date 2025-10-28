import 'package:get/get.dart';
import 'package:firebase_test_quran/controller/home_controller.dart';
import 'package:firebase_test_quran/services/firestore_service.dart';
import 'package:firebase_test_quran/services/local_data_service.dart';
import 'package:firebase_test_quran/services/tts_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Register services (singletons)
    Get.lazyPut<LocalDataService>(() => LocalDataService(), fenix: true);
    Get.lazyPut<FirestoreService>(() => FirestoreService(), fenix: true);
    Get.lazyPut<TtsService>(() => TtsService(), fenix: true);
    
    // Register controller
    Get.lazyPut<HomeController>(
      () => HomeController(
        local: Get.find<LocalDataService>(),
        remote: Get.find<FirestoreService>(),
        tts: Get.find<TtsService>(),
      ),
    );
  }
}