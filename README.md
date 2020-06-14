# Dartbase Admin SDK™️

A dart-native implementation of the Firebase Admin SDK.

This library is a fork of cachapa's client firebase sdk; cachapa/firedart; modified and converted to support admin only firebase features.
This library also uses these files from appsup-dart/firebase_admin to enable admin authentication to firebase because it is not documented on firebase's official documentation (May 2020):
* user_record.dart.
* token_handler.dart

## Currently supported:

* Firebase Auth
* Firestore
* Firebase Storage
* Firebase Cloud Messaging

## Installing

Add dartbase to your `pubspec.yaml` file:

``` yaml
dependencies:
  dartbase: [latest version]
```

## Setup & Usage
``` dart
import 'package:dartbase_admin/dartbase.dart';
```

To begin, you need to initialize Firebase:
- You can initialize the global singleton instance provided by the package that you can access anywhere.

- You can initialize a new local instance of Firebase as a variable and as many times as you want. You can pass that instance to all the other Firebase features, but if you don't, they default back to the global instance.

### Global Instance
``` dart
await Firebase.initialize(projectId, ServiceAccount);

var firebase = Firebase.instance;
```

### Local Instance
``` dart
var firebase = Firebase(projectId, ServiceAccount);

await firebase.init();
```

### ServiceAccount

You can reference a service account through several means:

## First way:
``` dart
ServiceAccount.fromEnvironmentVariable('Environment Variable Key');
```
If you do NOT specify an environment variable key, it will fallback to `GOOGLE_APPLICATION_CREDENTIALS`

## Second way:
``` dart
ServiceAccount.fromJson(r'''
{
      Project Settings -> Service Accounts -> generate new private key
      Paste the json here
}
''');
```

## Third way:
``` dart
await ServiceAccount.fromFile(serviceAccountFilePath);
```

## Firebase Auth

The [FirebaseAuth](https://github.com/SwissCheese5/Dartbase-Admin-SDK/blob/master/lib/auth/firebase_auth.dart) class will let you control administrative tasks related to user management.

Currently, the feature-set for it is very limited, but the available methods are:

### Get a user
``` dart
UserRecord user = await FirebaseAuth.instance.getUserById(uid);
```
The UserRecord object holds data like id, email, profilePicture, etc...

### Verify an ID Token
``` dart
try {
    String id = await FirebaseAuth.instance.verifyIdToken(<client token>, enforceEmailVerification: true, checkRevoked: true);
} catch (e) {
    print(e);
}
```
The client token can be acquired from any client using a Firebase Client SDK of any kind.
There should be a method called firebase.currentUser.idToken() (or something along those lines) that gives you an id token you can send to your backend, waiting to be processed by this method here.

The returned id is the user's id. This method will throw an exception if verification does not succeed, with a descriptive exception message.

Further usage examples can be found in the [integration tests](https://github.com/SwissCheese5/Dartbase-Admin-SDK/blob/master/test/firebase_auth_test.dart).

## Firestore
This will give you ADMIN access to firestore, be careful.
The [Firestore](https://github.com/SwissCheese5/Dartbase-Admin-SDK/blob/master/lib/firestore/firestore.dart) class implements the necessary functionality for a usable firestore implementation.

### Usage
``` dart
  // Instantiate a reference to a document - this happens offline
  var ref = Firestore.instance.collection('test').document('doc');

  // Subscribe to changes to that document
  ref.stream.listen((document) => print('updated: $document'));

  // Update the document
  await ref.update({'value': 'test'});

  // Get a snapshot of the document
  var document = await ref.get();
  print('snapshot: ${document['value']}');

  print(
      'Sleeping for 30 seconds. You can make changes to test/doc in the UI console');
  await Future.delayed((const Duration(seconds: 30)));

  print('closing the connection');
  await Firestore.instance.close();
```

Further usage examples can be found in the [integration tests](https://github.com/SwissCheese5/Dartbase-Admin-SDK/blob/master/test/firestore_test.dart).

### Limitations

* The data is not cached locally.
* Failed writes (e.g. due to network errors) are not retried.
* Closed streams are not automatically recovered.

## Firebase Storage

The [FirebaseStorage](https://github.com/SwissCheese5/Dartbase-Admin-SDK/blob/master/lib/storage/firebase_storage.dart) class implements the necessary functionality for bucket interactions with firebase.
Note that it is a wrapper from [gcloud](https://pub.dev/packages/gcloud) and made io-safe. It does not reference dart:io

### Usage
There is no global/local instances to initialize here. You can reference a Bucket at any time as a local variable anywhere.

The storageURL looks like so: `<project-id>.appspot.com`

``` dart
var bucket = await FirebaseStorage.getBucket(storageUrl);

/// UPLOAD
await bucket.upload('remoteDirectory/remoteFile.jpg', localFile.absolute.path);

/// INFO
var info = await bucket.info('remoteDirectory/remoteFile.jpg');

/// DOWNLOAD
await bucket.download('remoteDirectory/remoteFile.jpg', localFile.absolute.path);

/// LIST
var list = await (await bucket.list(prefix: 'remoteDirectory/')).toList();

/// DELETE
await bucket.delete('remoteDirectory/remoteFile.jpg');
```

Several helper methods exist for uploading and downloading if you explore the `FirebaseStorage` class.

More advanced usages and further usage examples can be found in the [integration tests](https://github.com/SwissCheese5/Dartbase-Admin-SDK/blob/master/test/firebase_storage_test.dart).

## Firebase Cloud Messaging

The `FCM` class implements the necessary functionality for sending cloud messages.

Make sure you've enabled `Cloud Messaging` in the `Firebase Console`, also enroll a test device there.
You'll also need to go to open `Project Settings` and under the `Cloud Messaging` tab copy the `Server key`.

### Usage

Then in your main script:
``` dart
import 'package:dartbase_admin/dartbase.dart';
import 'package:dartbase_admin/fcm/message.dart';

const cloudMessagingServerKey = 'Project settings -> Cloud Messaging -> Server key';

main() async {

  var firebase = await Firebase.initialize(projectId,
      await ServiceAccount.fromFile(serviceAccountPath));
  var fcm = FCM(firebase, FCMConfig(firebase.projectId));
  const token = '<Your device token here>';
  const topic = '<Choose a topic name>';

  // Send to a token
  var message = Message(
    token: token,
    notification: MessageNotification(
      title: "plantyplants test",
      body: "Some body text here",
    ),
  );
  var nameTopicMessage = await fcm.send(message);

  // Send to a topic
  var message = Message(
    topic: topic,
    notification: MessageNotification(
      title: "plantyplants test",
      body: "Some body text here",
    ),
  );
  var nameTopicMessage = await fcm.send(message);

  return;
}
```

Further usage examples can be found in the [integration tests](https://github.com/SwissCheese5/Dartbase-Admin-SDK/blob/master/test/firebase_fcm_test.dart).

### Limitations

* Doesn't support [batch send](https://firebase.google.com/docs/cloud-messaging/send-message#send-messages-to-multiple-devices).
* Doesn't support receiving a cloud message.