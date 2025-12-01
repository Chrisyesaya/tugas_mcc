import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';

Future<void> initFirebase({bool logConnection = true}) async {

  if (Firebase.apps.isEmpty) {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  if (logConnection) {
    FirebaseDatabase.instance.ref('.info/connected').onValue.listen(
      (e) => print(e.snapshot.value == true ? 'Connected to DB' : 'Disconnected from DB'),
      onError: (err) => print('Error Connection: $err'),
    );
  }
}