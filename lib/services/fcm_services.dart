import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> sendNotificationsToUserDevices(
    String emailID, String title, String body) async {
  DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
      .collection('tokenNotifications')
      .doc(emailID)
      .get();

  if (userSnapshot.exists && userSnapshot['tokens'] != null) {
    List<String> tokens = List<String>.from(userSnapshot['tokens']);

    for (String token in tokens) {
      await PushNotifications.sendNotificationToDeviceByToken(
          token, title, body);
    }
  } else {
    print("No device tokens found for user.");
  }
}

class PushNotifications {
  static Future<void> sendNotificationToDeviceByToken(
      String token, String title, String body) async {
    final String serverKey = await getAccessToken();
    print("Access Token: $serverKey");

    String endPointFirebaseCloudMessaging =
        'https://fcm.googleapis.com/v1/projects/petwalks-ef2a9/messages:send';

    final Map<String, dynamic> message = {
      'message': {
        'token': token,
        'notification': {
          'title': 'PET WALKS, Has sido aceptado',
          'body': 'Has sido aceptado en el programa PetWalks...'
        },
      }
    };

    try {
      final response = await http.post(
        Uri.parse(endPointFirebaseCloudMessaging),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serverKey',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print("Notification sent successfully to $token");
      } else {
        print("Error sending notification to $token: ${response.statusCode}");
      }
    } catch (e) {
      print("Failed to send notification: $e");
    }
  }

  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "petwalks-ef2a9",
      "private_key_id": "5f60c8383a329c9593febc8762d668ca7532f14f",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCpHgQlyimy9cu4\nUKDQRqizxUWQKUySYErHraq4druB07fbk9tBnp+dOwCL3vVQKCAfzIoWVvj7FZxJ\n7PHx16iSG6VQV7VqQ13KlzEN9JGHymJaq7Ms7bNuoWLTwWslNvV3wSQ7DfNHospM\n+F+nTzlM3vVaFkFhAru9WAwD8/VOX90nU4xXkqIKcydMO8H8r9FyqkjKMoqL3O6k\n0B/u8M7h8ph1WxYBruaxAcQiGxcoPc0l13e8DMnZfNxQezB4ptOEppgghvtvf3EL\n5T8frVqCclOnmWlVL6s0YqWrdd6exue8SC2kLVJ8HhZV19BsbVrPxDW1Cfa9XsZn\nVIArUL9dAgMBAAECggEAEsZyJ8SKcu5ROCdnZcgPxFQzNV6IZuXJgjftxf3p3O96\n2tCkR7mLDI3M2+UcWfz3wrVWt+/e7iKHj+N+Nt8Tkr5T+5fz3EDEtxBS/LLOvK3D\nfpUlAWjAV24TsTZTerW1Hx7yXUYJYMYaFzJ/OBgWYJ+OIKVri7rIdKxuOmV0B0fJ\n3ISM+fBSHEQ2sgeVzxloGbIGJmUgHgojTuhCHRu9RRhk1XU3IybEzZE2DRmBcAXt\nZcexr/vHI3fvn5Fq7BAn5lC+I9QhM7f33sFZneIzoObOlJeNSj1vqO4CIheaJ9xj\nMW7jsekH87FCT1ZGqNzND+djfJ/lFifDLwOHEX6t1wKBgQDluLNmL9g02kXF8g5W\ngyNZ+mdfyMZcSpy2dZ9oFWWc86WqBp8jc0/vW5z3ZI7EDydVXQ9Yj515YVhecyhh\n54TV6DTceGmSzZSdfcP91A4ANONubdshidwZgqT6jSUEX1GapKEZbcBesrDCiujm\nqoKAvvT1mg3nDa//up5PXvfYOwKBgQC8douYabOKTnpLxPo2ud13md7QeoaCpWba\nIKCTiafSgljlkjdrgNh8I5/Ff7zlaegSzU++TxfemKCb+hRyn5dPds8WEV36Wbw1\ng5cSEaZfKSTdupYD8QTpKDnqhKkfdsF4Bj0yboslVkVc63nw16a/guqKSt6iItYz\nXPCeRQXlRwKBgEE27w8KdBmFAZvRPMrIjcekc6ZYjB91Own9WFSnBmLJNHWRTao1\nuTKdUnFVBcaY+rScJ5gfpTfpL7oYfRVWMXq8Yg1YzbfUTuVq57Huek8KtKoL29Ko\nnWhMk2NhoGmeWb9KD0X1x0/a8J057CZXr5a3Hzl+E4ZNd3Jk2z5zGm8zAoGAf7nX\n4fPBOnr1Z2SYL37IGcauu5xOjTyL+EkkitlAY+rzVKND7BfmoDuEjNWFr/WW0ydS\nZCg2hSXrs8pJEWYXpkNfFhWvG3y1kY8dU6Gin9vCoINUKFewfFRG7Cn8dNaHSFDy\nKLvCkgtl9xOgERoWaLTRP+h9+mShxy215Y3h8QECgYAyBmbiJ0+kQHi08LpugTdD\nB/YS9hrpnvyUz6MbDzD9XWgduDCngo9C9q9N7V9x4M00TRkk7szFt/cvzL0hQK5E\n29uLAAyu73U3K3r4fAqAKr4ss66kLra8tyZ3wvfEeSc7peJMwTumers03S6YjKNL\nZ6kcwh+207Yi4EvFNKbBMQ==\n-----END PRIVATE KEY-----\n",
      "client_email":
          "flutter-pet-walks-fmc@petwalks-ef2a9.iam.gserviceaccount.com",
      "client_id": "104594059197050817742",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/flutter-pet-walks-fmc%40petwalks-ef2a9.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/firebase.messaging",
    ];

    var client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes);

    final credentials = client.credentials.accessToken.data;

    client.close();
    return credentials;
  }
}
