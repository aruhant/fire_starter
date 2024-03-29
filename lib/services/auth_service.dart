import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fire_starter/helpers/helpers.dart';
import 'package:fire_starter/services/config_service.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import '../models/models.dart';
import 'package:fire_starter/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:fire_starter/localizations.dart';
import 'package:fire_starter/models/models.dart';
import 'package:fire_starter/ui/components/components.dart';

class AuthService extends GetxService {
  static AuthService to = Get.find();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Rx<User?> firebaseUser = Rx<User?>(null);
  Rx<UserModel?> firestoreUser = Rx<UserModel?>(null);

  // Firebase user one-time fetch
  Future<User?> get getFirebaseUser async => _auth.currentUser;

  // Firebase user a realtime stream
  Stream<User?> get user => _auth.authStateChanges();

  @override
  void onReady() async {
    //run every time auth state changes
    ever(firebaseUser, handleAuthChanged);
    firebaseUser.value = await getFirebaseUser;
    firebaseUser.bindStream(user);
    firebaseUser.stream.first.then((value) => Get.offNamed('/'));
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  handleAuthChanged(User? _firebaseUser) async {
    //get user data from firestore
    if (_firebaseUser?.uid != null) {
      firestoreUser.bindStream(await streamFirestoreUser());
    }
    Get.offNamed('/');
  }

  //Streams the firestore user from the firestore collection
  Future<Stream<UserModel?>> streamFirestoreUser() async {
    UserModel? userRecord = await getFirestoreUser();
    var value = firebaseUser.value;
    if (userRecord != null && value != null) {
      return _db.doc('${FirebasePaths.prefix}${FirebasePaths.users}/${value.uid}').snapshots().map((snapshot) {
        if (!snapshot.exists) {
          signOut();
          return null;
        }
        GetLogger.to.d('Writing User to stream... ${snapshot.id} ' + snapshot.data().toString());
        return UserModel.fromMap(snapshot.data()!, value.uid);
      });
    }
    return Future.value();
  }

  //get the firestore user from the firestore collection
  Future<UserModel?> getFirestoreUser() {
    User? uservalue = firebaseUser.value;
    if (uservalue != null) {
      return _db.doc('${FirebasePaths.prefix}${FirebasePaths.users}/${uservalue.uid}').get().then((documentSnapshot) {
        if (documentSnapshot.exists)
          return UserModel.fromMap(documentSnapshot.data()!, uservalue.uid);
        else {
          return _createNewUserFirestore();
        }
      });
    }
    return Future.value();
  }

  //handles updating the user when updating profile
  Future<void> updateUser(BuildContext context, UserModel user) async {
    final labels = context.localizations;
    try {
      User _firebaseUser = firebaseUser.value!;
      _updateUserFirestore(user, _firebaseUser);
      hideLoadingIndicator();
      showSnackBar(labels.auth.updateUserSuccessNoticeTitle, labels.auth.updateUserSuccessNotice);
    } on PlatformException catch (error) {
      //List<String> errors = error.toString().split(',');
      // print("Error: " + errors[1]);
      hideLoadingIndicator();
      print(error.code);
      showSnackBar(labels.auth.unknownError, error.code);
    }
  }

  //updates the firestore user in users collection
  void _updateUserFirestore(UserModel user, User _firebaseUser) {
    _db.doc('${FirebasePaths.prefix}${FirebasePaths.users}/${_firebaseUser.uid}').update(user.toJson());
  }

  //create the firestore user in users collection
  _createUserFirestore(UserModel user, User _firebaseUser) {
    return _db.doc('${FirebasePaths.prefix}${FirebasePaths.users}/${_firebaseUser.uid}').set(user.toJson());
  }

  Future<UserModel?> _createNewUserFirestore() async {
    if (firebaseUser.value == null) return null;
    User _firebaseUser = firebaseUser.value!;
    UserModel _newUser = UserModel(
        id: _firebaseUser.uid,
        email: _firebaseUser.email,
        name: _firebaseUser.displayName,
        photoUrl: _firebaseUser.photoURL,
        phone: _firebaseUser.phoneNumber,
        memberOf: ConfigStorage.isAlpha ? ['alpha_users'] : ['users']);
    //create the user in firestore
    await _createUserFirestore(_newUser, _firebaseUser);
    return _newUser;
  }

  // Sign out
  Future<void> signOut() async {
    firestoreUser(null);
    firebaseUser(null);
    ConfigStorage.saveShowIntroSlider(true);
    ConfigStorage.saveLocale(null);
    await Future.delayed(Duration(seconds: 2));
    return _auth.signOut();
  }
}
