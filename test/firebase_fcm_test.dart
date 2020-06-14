import 'package:dartbase/dartbase.dart';
import 'package:dartbase/fcm/message.dart';
import 'package:test/test.dart';

import 'test_config.dart';

Future main() async {
  FCM fcm;
  final nameRegExp = RegExp(r'projects/.*/messages/[0-9]+');

  setUpAll(() async {
    await Firebase.initialize(projectId, await ServiceAccount.fromFile(serviceAccountPath));
    fcm = FCM.initialize();
  });

  await test('Send message with token', () async {
    var message = Message(
      token: cloudMessagingToken,
      notification: MessageNotification(
        title: 'test with token',
        body: 'Some body text here',
      ),
    );
    var name = await fcm.send(message);
    expect(nameRegExp.hasMatch(name), true);
  });

  await test('Send message with topic', () async {
    var message = Message(
      topic: cloudMessagingTopic,
      notification: MessageNotification(
        title: 'test with token',
        body: 'Some body text here',
      ),
    );
    var name = await fcm.send(message);
    expect(nameRegExp.hasMatch(name), true);
  });
}
