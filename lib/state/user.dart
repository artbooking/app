import 'package:artbooking/utils/app_localstorage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobx/mobx.dart';

part 'user.g.dart';

class UserState = UserStateBase with _$UserState;

abstract class UserStateBase with Store {
  FirebaseUser _userAuth;

  @observable
  String lang = 'en';

  @observable
  bool isQuotidianNotifActive = true;

  @observable
  bool isUserConnected = false;

  @observable
  String _name = '';

  /// Last time the favourites has been updated.
  @observable
  DateTime updatedFavAt = DateTime.now();

  Future<FirebaseUser> get userAuth async {
    if (_userAuth != null) {
      return _userAuth;
    }

    _userAuth = await FirebaseAuth.instance.currentUser();

    if (_userAuth == null) {
      await _signin();
    }

    if (_userAuth != null) {
      setUserName(_userAuth.displayName);
    }

    return _userAuth;
  }

  String get name { return _name; }

  /// To use chen user's data has changed.
  void clearAuthCache() {
    _userAuth = null;
  }

  @action
  void setLang(String newLang) {
    lang = newLang;
  }

  @action
  void setUserConnected() {
    isUserConnected = true;
  }

  @action
  void setUserDisconnected() {
    isUserConnected = false;
  }

  @action
  void setUserName(String newName) {
    _name = newName;
  }

  /// Signin user with credentials if FirebaseAuth is null.
  Future _signin() async {
    try {
      final credentialsMap = appLocalStorage.getCredentials();

      final email = credentialsMap['email'];
      final password = credentialsMap['password'];

      if ((email == null || email.isEmpty) || (password == null || password.isEmpty)) {
        return null;
      }

      final auth = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
          email: email,
          password: password,
        );

      _userAuth = auth.user;
      isUserConnected = true;

    } catch (error) {
      appLocalStorage.clearUserAuthData();
    }
  }

  @action
  void signOut() {
    _userAuth = null;
    isUserConnected = false;
  }

  @action
  void updateFavDate() {
    updatedFavAt = DateTime.now();
  }
}

final userState = UserState();
