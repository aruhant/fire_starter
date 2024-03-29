import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_starter/constants/firebase_paths.dart';
import 'package:fire_starter/helpers/helpers.dart';
import 'package:fire_starter/services/package_info.dart';
import 'package:fire_starter/services/upgrade_check.dart';
import 'package:get/get.dart';

class MetadataModel {
  int build;
  int majorVersion;
  int minorVersion;
  List<Map<String, dynamic>>? introSlider;
  List<Map<String, dynamic>>? introSlider_hi;

  String version;

  MetadataModel({
    required this.build,
    required this.minorVersion,
    this.introSlider,
    this.introSlider_hi,
    required this.majorVersion,
    required this.version,
  });

  Map toJson() => {'build': build, 'version': version};

  static init() {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    GetLogger.to.w('Waiting for ${FirebasePaths.prefix}${FirebasePaths.metadata}/all');
    db.doc('${FirebasePaths.prefix}${FirebasePaths.metadata}/all').snapshots().listen((event) {
      DocumentSnapshot<Map<String, dynamic>> doc = event;
      GetLogger.to.w('Snapshot ${FirebasePaths.prefix}${FirebasePaths.metadata}/all');
      if (!doc.exists) GetLogger.to.w('Cannout find ${FirebasePaths.prefix}${FirebasePaths.metadata}/all');
      PackageInfoService.metadata = MetadataModel._fromDocumentSnapshot(doc);
      UpgradeCheckService.init();
    });
  }

  factory MetadataModel._fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    var data = snapshot.data();
    if (data == null) return MetadataModel(build: 1, version: '0.0.0', majorVersion: 0, minorVersion: 0);
    var version = data["${GetPlatform.isIOS ? 'version-i' : (GetPlatform.isAndroid ? 'version-a' : 'version')}"] ?? data['version'];
    var build = data["${GetPlatform.isIOS ? 'build-i' : (GetPlatform.isAndroid ? 'build-a' : 'build')}"] ?? data['build'];
    return MetadataModel(
        build: build,
        version: version,
        introSlider: ((data['introSlider'] ?? []) as List).cast(),
        introSlider_hi: ((data['introSlider_hi'] ?? []) as List).cast(),
        majorVersion: int.parse(version.split('.')[0]),
        minorVersion: int.parse(version.split('.')[1]));
  }

  String toString() {
    return toJson().toString();
  }
}
