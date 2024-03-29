import 'package:fire_starter/constants/globals.dart';
import 'package:fire_starter/helpers/helpers.dart';
import 'package:fire_starter/models/metadata_model.dart';
import 'package:fire_starter/services/package_info.dart';
import 'package:get/utils.dart';
import 'package:get/get.dart';
import 'package:fire_starter/localizations.dart';

class UpgradeCheckService {
  static init() async {
    if (GetPlatform.isWeb) return _result = 0;
    MetadataModel? metadata = PackageInfoService.metadata;
    if (metadata == null || metadata.build == 0) return Future.delayed(Duration(seconds: 5)).then((value) => UpgradeCheckService.init());
    int appVersion = PackageInfoService.majorVersion;
    GetLogger.to.i('Upgrade check: Local ${PackageInfoService.majorVersion} server: $metadata');

    if (metadata.majorVersion > appVersion) {
      Get.offAllNamed('/${RouteNames.UPGRADE}');
      return _result = 1;
    } // forced upgrade
    int appMinorVersion = PackageInfoService.minorVersion;
    if (metadata.majorVersion == appVersion && metadata.minorVersion > appMinorVersion) {
      Future.delayed(Duration(seconds: 10)).then((value) {
        showSnackBar('Upgrade Available', 'It is recommended that you update to the latest build');
      });

      return _result = 2;
    } // optional
    _result = 0;
  }

  static int _result = -1;
  static int get check => _result;

  static void reset() {
    _result = 0;
  }
}
