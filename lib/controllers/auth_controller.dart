import 'dart:typed_data';

import 'package:bungkus_bang/views/screens/auth/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../provider/product_provider.dart';
import '../views/screens/main_Screen.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

   late Rx<User?> _user;
  User get user => _user.value!;
  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(_auth.currentUser);
    _user.bindStream(_auth.authStateChanges());
    ever(_user, _setInitialScreen);
  }

  _setInitialScreen(User? user) {
    if (user == null) {
      Get.off(() => LoginScreen());
    } else {
      Get.off(() => MainScreen());
    }
  }
//UPLOADING IMAGE AND PICK IMAGE
//UPLOADING IMAGE AND PICK IMAGE

  _uploadProfileImageToStorage(Uint8List? image) async {
    Reference ref =
        _storage.ref().child('profilePics').child(_auth.currentUser!.uid);

    UploadTask uploadTask = ref.putData(image!);

    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  pickProfileImage(ImageSource source) async {
    final ImagePicker _imagePicker = ImagePicker();

    XFile? _file = await _imagePicker.pickImage(source: source);

    if (_file != null) {
      return await _file.readAsBytes();
    } else {
      print('No Image Selected');
    }
  }

//UPLOADING IMAGE AND PICK IMAGE ENDS HERE

//FUNCTION TO CREATE NEW USER
  Future<String> createUser(
    String firstName,
    String lastName,
    String email,
    String password,
    Uint8List? image,
  ) async {
    String res = 'some error occured';

    try {
      if (image != null) {
        //CREATE NEW USER IN FIREBASE AUTH
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        String profileImageUrl = await _uploadProfileImageToStorage(image);

        await _firestore.collection('buyers').doc(cred.user!.uid).set({
          'longitude': '',
          'latitude': '',
          'placeName': '',
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'address': '',
          'userImage': profileImageUrl,
          'buyerId': cred.user!.uid,
        });

        res = 'success';
      } else {
        res = 'please Fields must be field in';
      }
    } catch (e) {
      res = e.toString();
    }

    return res;
  }

  // FUNCTION TO CREATE NEW USER ENDS HERE

//FUNCTION TO LOGIN USER

  Future<String> loginUser(
    String email,
    String password,
  ) async {
    String res = 'some error occured';

    try {
      //CREATE NEW USER IN FIREBASE AUTH
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      res = 'success';
    } catch (e) {
      res = e.toString();
    }

    return res;
  }
}
