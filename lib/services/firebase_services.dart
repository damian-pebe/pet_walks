// ignore_for_file: prefer_typing_uninitialized_variables, empty_catches

import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

//obtener usuarios
Future<List> getUsers() async {
  List users = [];
  CollectionReference collectionReferenceUsers = db.collection('users');
  QuerySnapshot queryUsers = await collectionReferenceUsers.get();

  for (var element in queryUsers.docs) {
    users.add(element.data());
  }

  return users;
}

Future<List<String>> getPets(String email) async {
  var userDoc =
      await db.collection("users").where("email", isEqualTo: email).get();

  if (userDoc.docs.isEmpty) {
    return [];
  } else {
    var doc = userDoc.docs.first;
    var idPetsArray = List<String>.from(doc.data()['idPets'] ?? []);
    return idPetsArray;
  }
}

Future<List<String>> getBusinessByIds() async {
  String fetchedEmail = await fetchUserEmail();

  var userDoc = await db
      .collection("users")
      .where("email", isEqualTo: fetchedEmail)
      .get();

  if (userDoc.docs.isEmpty) {
    return [];
  } else {
    var doc = userDoc.docs.first;
    var businessArray = List<String>.from(doc.data()['idBusiness'] ?? []);
    return businessArray;
  }
}

Future<List<String>> getbusinessIds() async {
  String fetchedEmail = await fetchUserEmail();
  var userDoc = await db
      .collection("users")
      .where("email", isEqualTo: fetchedEmail)
      .get();

  if (userDoc.docs.isEmpty) {
    return [];
  } else {
    var doc = userDoc.docs.first;
    var idPetsArray = List<String>.from(doc.data()['idBusiness'] ?? []);
    return idPetsArray;
  }
}

Future<Set<Map<String, dynamic>>> getPetsHistory(List<String> idPets) async {
  if (idPets.isEmpty) {
    return {};
  }

  var petsQuerySnapshot = await db
      .collection("pets")
      .where(FieldPath.documentId, whereIn: idPets.toList())
      .get();

  Set<Map<String, dynamic>> pets =
      petsQuerySnapshot.docs.map((doc) => doc.data()).toSet();

  return pets;
}

Future<void> updatePet(
    String id,
    String name,
    String race,
    String size,
    String description,
    String old,
    String color,
    List<String> downloadUrls) async {
  await db.collection("pets").doc(id).update({
    "name": name,
    "race": race,
    "size": size,
    "description": description,
    "old": old,
    "color": color,
    "imageUrls": downloadUrls
  });
}

Future<void> updateBusiness(
    String id,
    String name,
    String category,
    String phone,
    String address,
    String description,
    List<String> downloadUrls) async {
  await db.collection("business").doc(id).update({
    "name": name,
    "category": category,
    "phone": phone,
    "address": address,
    "description": description,
    "imageUrls": downloadUrls,
  });
}

Future<Map<String, dynamic>> getInfoPets(String email, String? idPet) async {
  var petDoc = await db.collection("pets").doc(idPet).get();

  if (petDoc.exists) {
    Map<String, dynamic> data = petDoc.data()!;
    return data;
  } else {
    return {};
  }
}

Future<Map<String, dynamic>> getInfoBusinessById(String id) async {
  var petDoc = await db.collection("business").doc(id).get();

  if (petDoc.exists) {
    Map<String, dynamic> data = petDoc.data()!;
    return data;
  } else {
    return {};
  }
}

Future<Map<String, dynamic>> fetchBuilderInfo(List<String> idPets) async {
  Map<String, dynamic> allPetsData = {};

  for (var element in idPets) {
    var petDoc = await db.collection("pets").doc(element).get();

    if (petDoc.exists) {
      Map<String, dynamic>? data = petDoc.data();
      if (data != null) {
        String? imageUrl = (data['imageUrls'] as List<dynamic>?)?.firstOrNull;
        String? name = data['name'] as String?;
        List<dynamic>? imageUrls = data['imageUrls'];

        allPetsData[element] = {
          'imageUrl': imageUrl,
          'name': name,
          'imageUrls': imageUrls,
          'id': element,
        };
      }
    } else {}
  }
  return allPetsData;
}

Future<Map<String, dynamic>> fetchBuilderInfoBusiness(List<String> ids) async {
  Map<String, dynamic> allBusinessData = {};

  for (var element in ids) {
    var doc = await db.collection("business").doc(element).get();

    if (doc.exists) {
      Map<String, dynamic>? data = doc.data();
      if (data != null) {
        String? imageUrl = (data['imageUrls'] as List<dynamic>?)?.firstOrNull;
        String? name = data['name'] as String?;
        List<dynamic>? imageUrls = data['imageUrls'] as List<dynamic>?;

        // Log the URL for debugging

        if (imageUrl != null && !Uri.parse(imageUrl).isAbsolute) {
          imageUrl = null;
        }

        allBusinessData[element] = {
          'imageUrl': imageUrl,
          'name': name,
          'imageUrls': imageUrls,
          'id': element,
        };
      }
    }
  }
  return allBusinessData;
}

Future<Set<Map<String, dynamic>>> fetchImageNamePet(List<String> idPets) async {
  Set<Map<String, dynamic>> allPetsData = {};

  for (var element in idPets) {
    var petDoc = await db.collection("pets").doc(element).get();

    if (petDoc.exists) {
      Map<String, dynamic>? data = petDoc.data();
      if (data != null) {
        String? imageUrl =
            data['imageUrls'] != null && data['imageUrls'].isNotEmpty
                ? data['imageUrls'][0] as String?
                : null;
        String? name = data['name'] as String?;

        allPetsData.add({
          'imageUrl': imageUrl,
          'name': name,
        });
      }
    }
  }
  return allPetsData;
}

Future<Map<String, dynamic>> fetchBuilderInfos(List<String>? idPets) async {
  Map<String, dynamic> allPetsData = {};

  if (idPets != null && idPets.isNotEmpty) {
    for (var element in idPets) {
      var petDoc = await db.collection("pets").doc(element).get();

      if (petDoc.exists) {
        Map<String, dynamic>? data = petDoc.data();
        if (data != null) {
          List<dynamic>? imageUrls = data['imageUrls'];

          // Check if rating is a List<double>
          List<double>? rating;
          if (data['rating'] is List) {
            rating = List<double>.from(data['rating'].map((r) => r.toDouble()));
          }

          String name = data['name'] ?? '';
          List<String>? comments = List<String>.from(data['comments'] ?? []);

          allPetsData[element] = {
            'imageUrls': imageUrls,
            'name': name,
            'comments': comments,
            'rating': rating ?? [],
            'id': element,
          };
        }
      } else {}
    }
  }

  return allPetsData;
}

Future<void> newUser(
    String? name, String email, String? phone, String? home) async {
  List<double> rating = [0];

  var userDoc =
      await db.collection("users").where("email", isEqualTo: email).get();
  if (userDoc.docs.isEmpty) {
    await db.collection("users").add({
      "name": name ?? "",
      "email": email,
      "phone": phone ?? "",
      "address": home ?? "",
      "idPets": [],
      "idBusiness": [],
      "idPost": [],
      "idWalks": [],
      "idHistory": [],
      "profilePhoto": '',
      "activeServices": ['walk', 'request', 'business'],
      "language": true, //true == sp/ false == en
      "rating": rating,
      "docs": 'unverified',
      "reports": 0
    });
  }
}

Future<List<String>> getServices(String email) async {
  var userDoc =
      await db.collection("users").where("email", isEqualTo: email).get();
  if (userDoc.docs.isNotEmpty) {
    var user = userDoc.docs.first;
    var services = List<String>.from(user.data()['activeServices'] ?? []);
    return services;
  } else {
    return [];
  }
}

Future<Set<Map<String, dynamic>>> ownPosts() async {
  Set<Map<String, dynamic>> posts = {};
  CollectionReference collectionReferencePosts = db.collection('post');
  QuerySnapshot queryPosts = await collectionReferencePosts.get();

  for (var element in queryPosts.docs) {
    posts.add({
      'id': element.id,
      "description": element['description'] ?? "",
      "imageUrls": element['imageUrls'],
      "address": element['address'],
      "type": element['type'],
      "deleteTime": element['deleteTime'],
      "comments": element['comments'],
    });
  }

  return posts;
}

Future<Set<Map<String, dynamic>>> getPost() async {
  Set<Map<String, dynamic>> posts = {};
  CollectionReference collectionReferencePosts = db.collection('post');
  QuerySnapshot queryPosts = await collectionReferencePosts.get();
  DateTime now = DateTime.now();

  for (var element in queryPosts.docs) {
    Timestamp deleteTimeTimestamp = element['deleteTime'] as Timestamp;
    DateTime deleteTime = deleteTimeTimestamp.toDate();

    if (deleteTime.isBefore(now)) {
      deletePost(element.id);
    } else {
      posts.add({
        'id': element.id,
        'address': element['address'],
        'premium': element['premium'],
        'type': element['type'],
      });
    }
  }

  return posts;
}

Future<void> deletePost(String idToDelete) async {
  CollectionReference collectionReferencePosts = db.collection('post');
  await collectionReferencePosts.doc(idToDelete).delete();
}

Future<void> checkArrayDeletedPosts() async {
  String email = await fetchUserEmail();
  var userDoc =
      await db.collection("users").where("email", isEqualTo: email).get();
  CollectionReference collectionReferencePosts = db.collection('post');
  QuerySnapshot queryPosts = await collectionReferencePosts.get();

  if (userDoc.docs.isNotEmpty) {
    var user = userDoc.docs.first;
    var post = List<String>.from(user.data()['idPost'] ?? []);

    var existingPostIds = queryPosts.docs.map((doc) => doc.id).toSet();

    post.removeWhere((id) => !existingPostIds.contains(id));

    await db.collection("users").doc(user.id).update({"idPost": post});
  }
}

Future<Set<Map<String, dynamic>>> getInfoPosts(List<String> postIds) async {
  Set<Map<String, dynamic>> posts = {};
  CollectionReference collectionReferencePosts = db.collection('post');

  for (var postId in postIds) {
    DocumentSnapshot docSnapshot =
        await collectionReferencePosts.doc(postId).get();

    if (docSnapshot.exists) {
      posts.add(docSnapshot.data() as Map<String, dynamic>);
    }
  }

  return posts;
}

Future<void> updateServices(String email, List? services) async {
  var userDoc =
      await db.collection("users").where("email", isEqualTo: email).get();
  if (userDoc.docs.isNotEmpty) {
    var user = userDoc.docs.first;

    await db
        .collection("users")
        .doc(user.id)
        .update({"activeServices": services});
  }
}

Future<bool> getLanguage() async {
  String fetchedEmail = await fetchUserEmail();
  var userDoc = await db
      .collection("users")
      .where("email", isEqualTo: fetchedEmail)
      .get();

  var user = userDoc.docs.first;

  var languajeValue = user.data()['language'];

  bool languaje;
  if (languajeValue is String) {
    languaje = languajeValue.toLowerCase() == 'true';
  } else if (languajeValue is bool) {
    languaje = languajeValue;
  } else {
    return true;
  }
  return languaje;
}

Future<void> updateLanguage(bool lang) async {
  String fetchedEmail = await fetchUserEmail();

  var userDoc = await db
      .collection("users")
      .where("email", isEqualTo: fetchedEmail)
      .get();

  var user = userDoc.docs.first;
  await db.collection("users").doc(user.id).update({"language": lang});
}

Future<void> modifyUser(String? name, String email, String? phone, String? home,
    String? url) async {
  var userDoc =
      await db.collection("users").where("email", isEqualTo: email).get();
  if (userDoc.docs.isNotEmpty) {
    var user = userDoc.docs.first;

    await db.collection("users").doc(user.id).update({
      "name": name ?? user.data()['name'],
      "phone": phone ?? user.data()['phone'],
      "address": home ?? user.data()['address'],
      "profilePhoto": url,
    });
  } else {}
}

Future<void> addPetToUser(String email, String? newPetId) async {
  var userDoc =
      await db.collection("users").where("email", isEqualTo: email).get();
  if (userDoc.docs.isNotEmpty) {
    var user = userDoc.docs.first;
    var pets = List<String>.from(user.data()['idPets'] ?? []);
    pets.add(newPetId ?? 'Invalid state for pet');

    await db.collection("users").doc(user.id).update({"idPets": pets});
  }
}

Future<void> addWalkToUser(String email, String? newWalkId) async {
  var userDoc =
      await db.collection("users").where("email", isEqualTo: email).get();
  if (userDoc.docs.isNotEmpty) {
    var user = userDoc.docs.first;
    var walk = List<String>.from(user.data()['idWalks'] ?? []);
    walk.add(newWalkId ?? 'Invalid state for walk');

    await db.collection("users").doc(user.id).update({"idWalks": walk});
  }
}

Future<void> addBusinessToUser(String email, String? newBusinessId) async {
  var userDoc =
      await db.collection("users").where("email", isEqualTo: email).get();
  if (userDoc.docs.isNotEmpty) {
    var user = userDoc.docs.first;
    var business = List<String>.from(user.data()['idBusiness'] ?? []);
    business.add(newBusinessId ?? 'Invalid state for walk');

    await db.collection("users").doc(user.id).update({"idBusiness": business});
  }
}

Future<void> addPostToUser(String email, String? newPostId) async {
  var userDoc =
      await db.collection("users").where("email", isEqualTo: email).get();
  if (userDoc.docs.isNotEmpty) {
    var user = userDoc.docs.first;
    var post = List<String>.from(user.data()['idPost'] ?? []);
    post.add(newPostId ?? 'Invalid state for walk');

    await db.collection("users").doc(user.id).update({"idPost": post});
  }
}

class UserService {
  Future<Set<Map<String, dynamic>>> getUser(String email) async {
    var userDoc =
        await db.collection("users").where("email", isEqualTo: email).get();

    if (userDoc.docs.isEmpty) {
      return {};
    } else {
      return userDoc.docs.map((doc) => doc.data()).toSet();
    }
  }
}

Future<String> newBusiness(
    String? name,
    String? category,
    String? phone,
    String? place,
    LatLng position,
    String? description,
    List<String>? downloadUrls) async {
  List<double> rating = [];
  String fetchedEmail = await fetchUserEmail();
  DocumentReference userDoc = await db.collection("business").add({
    "name": name ?? "",
    "category": category ?? "",
    "phone": phone ?? "",
    "address": place ?? "",
    "position": GeoPoint(position.latitude, position.longitude),
    "description": description ?? "",
    "rating": rating,
    "comments": [
      'la mejor veterinariaaa',
      'super recomendadooo',
      'super buen servicio!!'
    ],
    "imageUrls": downloadUrls ?? [],
    "email": fetchedEmail,
    "premium": false
  });
  String lastBusinessId = userDoc.id;

  await db.collection("business").doc(lastBusinessId).update({
    "id": lastBusinessId,
  });
  return lastBusinessId;
}

Future<String> newWalk(
    DateTime timeShow, //for the script as well
    String? timeShowController, //for the script as well
    String? payMethod,
    String? walkWFriends,
    String? timeWalking,
    String? place,
    LatLng position,
    String? description,
    List<String> selectedPets,
    String ownerEmail,
    bool premium,
    String? addressBusiness,
    LatLng? positionBusiness,
    String? idBusiness) async {
  int price;
  if (timeWalking != null) {
    int timeWalkingInt = int.parse(timeWalking);
    price = getPriceWalk(timeWalkingInt, selectedPets);
  } else {
    price = getPriceTravel(positionBusiness!, position, selectedPets);
  }

  DocumentReference userDoc;
  if (timeWalking != null) {
    userDoc = await db.collection("walks").add({
      "timeShow": timeShow,
      "timeShowController": timeShowController ?? "",
      "payMethod": payMethod ?? "",
      "walkWFriends": walkWFriends ?? "",
      "timeWalking": timeWalking,
      "address": place ?? "",
      "position": GeoPoint(position.latitude, position.longitude),
      "description": description ?? "",
      "selectedPets": selectedPets,
      "price": price,
      "ownerEmail": ownerEmail,
      "premium": premium,
    });
  } else {
    userDoc = await db.collection("walks").add({
      "timeShow": timeShow,
      "timeShowController": timeShowController ?? "",
      "payMethod": payMethod ?? "",
      "walkWFriends": walkWFriends ?? "",
      "timeWalking": timeWalking,
      "address": place ?? "",
      "position": GeoPoint(position.latitude, position.longitude),
      "description": description ?? "",
      "selectedPets": selectedPets,
      "price": price,
      "ownerEmail": ownerEmail,
      "premium": premium,
      "addressBusiness": addressBusiness,
      "positionBusiness":
          GeoPoint(positionBusiness!.latitude, positionBusiness.longitude),
      "idBusiness": idBusiness
    });
  }
  String lastWalkId = userDoc.id;

  await db.collection("walks").doc(lastWalkId).update({
    "id": lastWalkId,
  });

  return lastWalkId;
}

int getPriceWalk(int time, List<String> pets) {
  int numPets = pets.length;
  int price = (numPets - 1) * 20;
  if (time == 15) {
    return (50 * numPets) - price;
  }
  if (time == 30) {
    return (80 * numPets) - price;
  }
  if (time == 45) {
    return (120 * numPets) - price;
  }

  return 0;
}

// Function to calculate the distance between two LatLng points
double calculateDistance(LatLng goTo, LatLng goFrom) {
  const R = 6371;
  final double lat1 = goFrom.latitude;
  final double lon1 = goFrom.longitude;
  final double lat2 = goTo.latitude;
  final double lon2 = goTo.longitude;

  final double dLat = radians(lat2 - lat1);
  final double dLon = radians(lon2 - lon1);

  final double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(radians(lat1)) * cos(radians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
  final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return R * c;
}

double radians(double degree) {
  return degree * pi / 180;
}

int getPriceTravel(LatLng goTo, LatLng goFrom, List<String> pets) {
  double distance = calculateDistance(goTo, goFrom);
  const double costPerKilometer = 5;
  int costPets = pets.length * 20;
  return (costPets + 10 + (distance * costPerKilometer)).round();
}

Future<String> newPreHistory(
  String idWalk,
  String emailOwner,
  String emailWalker,
  String? idBusiness,
) async {
  DocumentReference userDoc = await db.collection("preHistory").add({
    "idWalk": idWalk,
    "emailOwner": emailOwner,
    "emailWalker": emailWalker,
    "idBusiness": idBusiness ?? "",
  });
  String lastWalkId = userDoc.id;

  return lastWalkId;
}

Future<String> newStartWalk(
  String idWalk,
  String emailOwner,
  String emailWalker,
  String? idBusiness,
  String idHistory,
) async {
  DocumentReference userDoc = await db.collection("startWalkHistory").add({
    "idWalk": idWalk,
    "emailOwner": emailOwner,
    "emailWalker": emailWalker,
    "idBusiness": idBusiness ?? "",
    "idHistory": idHistory,
    //staatus to start walk
    "ownerStatus": '', //'ready' or ''
    "walkerStatus": '' //'ready' or ''
  });
  String lastWalkId = userDoc.id;

  return lastWalkId;
}

Future<String> newEndWalk(
  String idWalk,
  String emailOwner,
  String emailWalker,
  String? idBusiness,
  String idHistory,
) async {
  DocumentReference userDoc = await db.collection("endWalkHistory").add({
    "idWalk": idWalk,
    "emailOwner": emailOwner,
    "emailWalker": emailWalker,
    "idBusiness": idBusiness ?? "",
    "idHistory": idHistory,
    //staatus to start walk
    "ownerStatus": '', //'ready' or ''
    "walkerStatus": '' //'ready' or ''
  });
  String lastWalkId = userDoc.id;

  return lastWalkId;
}

Future<String> newHistoryWalk(
  String idWalk,
  String emailOwner,
  String emailWalker,
  String? idBusiness,
) async {
  DocumentReference newHistoryDoc = await db.collection("history").add({
    "idWalk": idWalk,
    "emailOwner": emailOwner,
    "emailWalker": emailWalker,
    "idBusiness": idBusiness ?? "",
    "status": 'awaiting', // 'awaiting', 'walking', 'done',
  });

  await db.collection("history").doc(newHistoryDoc.id).update({
    "id": newHistoryDoc.id,
  });

  Map<String, dynamic> data = await getInfoWalk(idWalk);
  String payMethod = data['payMethod'];
  if (payMethod == 'Tarjeta') {
    await db.collection("history").doc(newHistoryDoc.id).update({
      "payment": 'awaiting',
    });
  }

  return newHistoryDoc.id;
}

Future<String?> getPaymentMethod(String idHistory) async {
  Map<String, dynamic> data = await getOneHistory(idHistory);
  String? payMethod = data['payment'];
  if (payMethod != null) {
    return payMethod;
  }
  return null;
}

Future<Set<Map<String, dynamic>>> getHistory(List<String> listOfHistory) async {
  Set<Map<String, dynamic>> history = {};
  CollectionReference collectionReferenceHistory = db.collection('history');

  for (String id in listOfHistory) {
    if (id.isNotEmpty) {
      DocumentSnapshot docSnapshot =
          await collectionReferenceHistory.doc(id).get();
      if (docSnapshot.exists) {
        history.add(docSnapshot.data() as Map<String, dynamic>);
      }
    }
  }

  return history;
}

Future<Map<String, dynamic>> getOneHistory(String id) async {
  Map<String, dynamic> history = {};
  CollectionReference collectionReferenceHistory = db.collection('history');

  DocumentSnapshot docSnapshot = await collectionReferenceHistory.doc(id).get();
  if (docSnapshot.exists) {
    history = docSnapshot.data() as Map<String, dynamic>;
  }

  return history;
}

Future<List<String>> getSuggestions() async {
  var doc = await db.collection('suggestions').doc('suggestions').get();

  List<String> suggestions =
      List<String>.from(doc.data()?['suggestions'] ?? []);

  return suggestions;
}

Future<Set<Map<String, dynamic>>> getBusiness() async {
  Set<Map<String, dynamic>> business = {};
  CollectionReference collectionReferenceBusiness = db.collection('business');
  QuerySnapshot queryBusiness = await collectionReferenceBusiness.get();

  for (var element in queryBusiness.docs) {
    business.add(element.data() as Map<String, dynamic>);
  }

  return business;
}

Future<Set<Map<String, dynamic>>> getWalks() async {
  Set<Map<String, dynamic>> walks = {};
  CollectionReference collectionReferenceWalks = db.collection('walks');
  QuerySnapshot queryWalks = await collectionReferenceWalks.get();

  DateTime now = DateTime.now();

  for (var element in queryWalks.docs) {
    var data = element.data() as Map<String, dynamic>?;
    if (data != null) {
      Timestamp timeShowTimestamp = data['timeShow'] as Timestamp;
      DateTime timeShow = timeShowTimestamp.toDate();
      int timeShowController = int.tryParse(data['timeShowController']) ?? 0;
      DateTime timeShowEnd = timeShow.add(Duration(hours: timeShowController));

      //CORRECT!!!
      if (timeShow.isBefore(now) && timeShowEnd.isAfter(now)) {
        walks.add(data);
      }
    }
  }
  return walks;
}

Future<Map<String, dynamic>> getInfoWalk(String idWalk) async {
  var petDoc = await db.collection("walks").doc(idWalk).get();

  if (petDoc.exists) {
    Map<String, dynamic>? data = petDoc.data();
    return data!;
  }

  return {};
}

List<DateTime> getArrayOfDateTime(Map<String, dynamic> data) {
  List<DateTime> list = [];

  if (data['startDate'] is Timestamp && data['endDate'] is Timestamp) {
    Timestamp startTimestamp = data['startDate'] as Timestamp;
    DateTime timeShowStart = startTimestamp.toDate();
    Timestamp endTimestamp = data['endDate'] as Timestamp;
    DateTime timeShowEnd = endTimestamp.toDate();

    while (timeShowStart.isBefore(timeShowEnd) ||
        timeShowStart.isAtSameMomentAs(timeShowEnd)) {
      list.add(timeShowStart);
      timeShowStart = timeShowStart.add(const Duration(days: 1));
    }
  } else {}

  return list;
}

Future<String> newPost(
    String? description, List<String?> imageUrls, String? type) async {
  DateTime now = DateTime.now();
  DateTime futureDate = now.add(const Duration(days: 7));

  var address;
  bool premium = false;
  // ignore: no_leading_underscores_for_local_identifiers
  String _email = await fetchUserEmail();
  var userDocEmail =
      await db.collection("users").where("email", isEqualTo: _email).get();

  if (userDocEmail.docs.isNotEmpty) {
    var user = userDocEmail.docs.first;
    address = user.data()['address'] ?? '';
    premium = user.data()['premium'] == 'active' ? true : false;
  }

  DocumentReference userDoc = await db.collection("post").add({
    "description": description ?? "",
    "imageUrls": imageUrls,
    "address": address,
    "type": type,
    "deleteTime": futureDate,
    "comments": ['RECOMENDADOOO!'],
    "emailUser": _email,
    'premium': premium
  });
  String lastPostId = userDoc.id;

  await db.collection("post").doc(userDoc.id).update({
    "id": lastPostId,
  });

  return lastPostId;
}

Future<LatLng?> getLatLngFromAddress(String address) async {
  List<Location> locations = await locationFromAddress(address);
  if (locations.isNotEmpty) {
    final location = locations.first;
    return LatLng(location.latitude, location.longitude);
  }
  return null;
}

Future<String> newPet(
    String? name,
    String? race,
    String? size,
    String? description,
    String? old,
    String? color,
    List<String>? imageUrls) async {
  List<double> rating = [0];

  DocumentReference userDoc = await db.collection("pets").add({
    "name": name ?? "",
    "race": race ?? "",
    "size": size ?? "",
    "old": old ?? "",
    "color": color ?? "",
    "description": description ?? "",
    "imageUrls": imageUrls ?? [],
    //example
    "rating": rating,
    "comments": ['muy buena mascota', 'linda mascota', 'muy cariñoso!'],
  });
  late String lastPetId;

  lastPetId = userDoc.id;

  return lastPetId;
}

Future<void> deletePet(String id, String email) async {
  await db.collection('pets').doc(id).delete();

  var userDoc =
      await db.collection("users").where("email", isEqualTo: email).get();

  if (userDoc.docs.isNotEmpty) {
    var user = userDoc.docs.first;
    var idPets = List<String>.from(user.data()['idPets'] ?? []);

    if (idPets.contains(id)) {
      idPets.removeWhere((element) => element == id);

      await db.collection("users").doc(user.id).update({
        "idPets": idPets,
      });
    }
  }
}

Future<void> deleteBusiness(String id) async {
  String fetchedEmail = await fetchUserEmail();

  await db.collection('business').doc(id).delete();

  var userDoc = await db
      .collection("users")
      .where("email", isEqualTo: fetchedEmail)
      .get();

  if (userDoc.docs.isNotEmpty) {
    var user = userDoc.docs.first;
    var ids = List<String>.from(user.data()['idBusiness'] ?? []);

    if (ids.contains(id)) {
      ids.removeWhere((element) => element == id);

      await db.collection("users").doc(id).update({
        "idBusiness": ids,
      });
    }
  }
}

Future<String> fetchUserEmail() async {
  String? email;
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    email = user.email;
  } else {}
  return email ?? 'Error fetching the email';
}

//REQUESTS
Future<List<DocumentSnapshot>> fetchPendingRequests(String emailOwner) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('preHistory')
      .where('emailOwner', isEqualTo: emailOwner)
      .get();
  return snapshot.docs;
}

Future<List<DocumentSnapshot>> fetchPendingRequestStart(String email) async {
  QuerySnapshot emailOwnerSnapshot = await FirebaseFirestore.instance
      .collection('startWalkHistory')
      .where('emailOwner', isEqualTo: email)
      .get();

  QuerySnapshot emailWalkerSnapshot = await FirebaseFirestore.instance
      .collection('startWalkHistory')
      .where('emailWalker', isEqualTo: email)
      .get();

  Set<DocumentSnapshot> combinedDocsSet = {};

  combinedDocsSet.addAll(emailOwnerSnapshot.docs);

  combinedDocsSet.addAll(emailWalkerSnapshot.docs);

  List<DocumentSnapshot> combinedDocs = combinedDocsSet.toList();

  return combinedDocs;
}

Future<List<String>> fetchHistoryIds(String email) async {
  QuerySnapshot emailOwnerSnapshot = await FirebaseFirestore.instance
      .collection('history')
      .where('emailOwner', isEqualTo: email)
      .get();

  QuerySnapshot emailWalkerSnapshot = await FirebaseFirestore.instance
      .collection('history')
      .where('emailWalker', isEqualTo: email)
      .get();

  Set<String> docIds = {};

  for (var doc in emailOwnerSnapshot.docs) {
    docIds.add(doc.id);
  }

  for (var doc in emailWalkerSnapshot.docs) {
    docIds.add(doc.id);
  }

  return docIds.toList();
}

Future<List<DocumentSnapshot>> fetchPendingRequestEnd(String email) async {
  QuerySnapshot emailOwnerSnapshot = await FirebaseFirestore.instance
      .collection('endWalkHistory')
      .where('emailOwner', isEqualTo: email)
      .get();

  QuerySnapshot emailWalkerSnapshot = await FirebaseFirestore.instance
      .collection('endWalkHistory')
      .where('emailWalker', isEqualTo: email)
      .get();

  Set<DocumentSnapshot> combinedDocsSet = {};

  combinedDocsSet.addAll(emailOwnerSnapshot.docs);

  combinedDocsSet.addAll(emailWalkerSnapshot.docs);

  List<DocumentSnapshot> combinedDocs = combinedDocsSet.toList();

  return combinedDocs;
}

// Future<String> findMatchingWalkId(String idWalk) async {
//   QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//       .collection('walks')
//       .doc(id)
//       .get();

//   return querySnapshot.docs.first.id;
// }

Future<String?> findMatchingBusinessId(String address) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('business')
      .where('address', isEqualTo: address)
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    return querySnapshot.docs.first.id;
  } else {
    return null;
  }
}

Future<String> findMatchingUserId(String email1) async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('email', isEqualTo: email1)
      .get();

  return querySnapshot.docs.first.id;
}

Future<Map<String, dynamic>> manageStartWalk(String id) async {
  DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
      .collection('startWalkHistory')
      .doc(id)
      .get();

  if (docSnapshot.exists) {
    final data = docSnapshot.data() as Map<String, dynamic>;

    return {
      'idWalk': data['idWalk'] ?? '',
      'emailOwner': data['emailOwner'] ?? '',
      'emailWalker': data['emailWalker'] ?? '',
      'idBusiness': data['idBusiness'] ?? '',
      'idHistory': data['idHistory']
    };
  } else {
    return {};
  }
}

Future<Map<String, dynamic>> manageEndWalk(String id) async {
  DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
      .collection('endWalkHistory')
      .doc(id)
      .get();

  if (docSnapshot.exists) {
    final data = docSnapshot.data() as Map<String, dynamic>;

    return {
      'idWalk': data['idWalk'] ?? '',
      'emailOwner': data['emailOwner'] ?? '',
      'emailWalker': data['emailWalker'] ?? '',
      'idBusiness': data['idBusiness'] ?? '',
      'idHistory': data['idHistory'] ?? '',
    };
  } else {
    return {};
  }
}

Future<Map<String, dynamic>> managePreHistory(String id) async {
  DocumentSnapshot docSnapshot =
      await FirebaseFirestore.instance.collection('preHistory').doc(id).get();

  if (docSnapshot.exists) {
    final data = docSnapshot.data() as Map<String, dynamic>;

    return {
      'idWalk': data['idWalk'] ?? '',
      'emailOwner': data['emailOwner'] ?? '',
      'emailWalker': data['emailWalker'] ?? '',
      'idBusiness': data['idBusiness'] ?? '',
    };
  } else {
    return {};
  }
}

Future<void> updateOwner(bool bool, String id, bool col) async {
  String status = bool ? 'ready' : '';
  String collection = col ? "startWalkHistory" : "endWalkHistory";
  await db.collection(collection).doc(id).update({
    "ownerStatus": status,
  });
}

Future<void> updateWalker(bool bool, String id, bool col) async {
  String status = bool ? 'ready' : '';
  String collection = col ? "startWalkHistory" : "endWalkHistory";
  await db.collection(collection).doc(id).update({
    "walkerStatus": status,
  });
}

Future<bool> getOwnerStatus(String id, bool col) async {
  String collection = col ? "startWalkHistory" : "endWalkHistory";

  DocumentSnapshot doc = await db.collection(collection).doc(id).get();

  if (doc.exists && doc.data() != null) {
    final data = doc.data() as Map<String, dynamic>;

    if (data['ownerStatus'] == 'ready') {
      return true;
    }
  }

  return false;
}

Future<bool> getWalkerStatus(String id, bool col) async {
  String collection = col ? "startWalkHistory" : "endWalkHistory";

  DocumentSnapshot doc = await db.collection(collection).doc(id).get();

  final data = doc.data() as Map<String, dynamic>;
  if (data['walkerStatus'] == 'ready') {
    return true;
  }

  return false;
}

Future<LatLng?> getWalkerPosition(String id, bool col) async {
  String collection = col ? "startWalkHistory" : "endWalkHistory";

  DocumentSnapshot doc = await db.collection(collection).doc(id).get();

  final data = doc.data() as Map<String, dynamic>;
  return data['walkerPosition'];
}

Future<void> deletePreHistory(requestId) async {
  CollectionReference collectionReferencePosts = db.collection('preHistory');
  await collectionReferencePosts.doc(requestId).delete();
}

Future<void> deleteStartHistory(String requestId, bool col) async {
  String collection = col ? "startWalkHistory" : "endWalkHistory";

  await FirebaseFirestore.instance
      .collection(collection)
      .doc(requestId)
      .delete();
}

Future<void> updateHistory(
    String id, String type, DateTime startOrEnd, bool start) async {
  await db.collection('history').doc(id).update({
    "status": type,
  });

  start
      ? await db.collection('history').doc(id).update({
          "timeStart": startOrEnd,
        })
      : await db.collection('history').doc(id).update({
          "timeEnd": startOrEnd,
        });
}

Future<Map<String, dynamic>> getInfoCollectionWithId(
    String id, String collection) async {
  if (id == '') return {};
  var doc = await db.collection(collection).doc(id).get();

  if (doc.exists) {
    Map<String, dynamic>? data = doc.data();
    return data!;
  }

  return {};
}

Future<void> addComment(
    String email, String comment, String collection, String id) async {
  var doc = await db.collection(collection).doc(id).get();

  List<String> comments = List<String>.from(doc.data()?['comments'] ?? []);

  if (comment.isNotEmpty) {
    comments.add(comment);
  }

  await db.collection(collection).doc(doc.id).update({"comments": comments});
}

Future<void> addSuggestion(String suggestion) async {
  var doc = await db.collection('suggestions').doc('suggestions').get();

  List<String> suggestions =
      List<String>.from(doc.data()?['suggestions'] ?? []);

  if (suggestions.isNotEmpty) {
    suggestions.add(suggestion);
  }

  await db
      .collection('suggestions')
      .doc(doc.id)
      .update({"suggestions": suggestions});
}

Future<void> addRateToUser(double rate, String collection, String id) async {
  var doc = await db.collection(collection).doc(id).get();

  var ratingList = (doc['rating'] ?? []).map<double>((e) {
    if (e is int) {
      return e.toDouble();
    } else if (e is double) {
      return e;
    } else {
      throw Exception('Invalid type in rating list');
    }
  }).toList();

  ratingList.add(rate);

  await db.collection(collection).doc(id).update({"rating": ratingList});
}

//shared preferences

Future<void> saveLanguagePreference(bool lang) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('lang', lang);
}

Future<bool> getLanguagePreference() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('lang') ?? true; // Default value, if not set
}
//shared preferences

Future<void> updateINEUser(String url, String id) async {
  await db.collection('users').doc(id).update({"ine": url});
}

Future<void> updateAdressProofUser(String url, String id) async {
  await db.collection('users').doc(id).update({"addressProof": url});
}

Future<void> uploadAgreementUserStatus(String id, String status) async {
  await db
      .collection('users')
      .doc(id)
      .update({"docs": status}); //unverified, inCheck, verified
}

Future<String> getAgreementStatus(String id) async {
  DocumentSnapshot docSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(id).get();

  if (docSnapshot.exists) {
    final data = docSnapshot.data() as Map<String, dynamic>;

    return data['docs'];
  } else {
    return '';
  }
}

Future<void> updateHistoryPaymentStatus(
  String? idHistory,
) async {
  String fetchedEmail = await fetchUserEmail();
  var userDoc = await db
      .collection("users")
      .where("email", isEqualTo: fetchedEmail)
      .get();
  var user = userDoc.docs.first;

  idHistory == null
      ? await db
          .collection('users')
          .doc(user.id)
          .update({"premium": 'active', "startPremium": DateTime.now()})
      : await db
          .collection('history')
          .doc(idHistory)
          .update({"payment": 'done'});
}

//CHAT
Future<String> newChat(String emailUser2) async {
  String currentUserByEmail = await fetchUserEmail();
  var userDoc = await db
      .collection("chat")
      .add({"user1": currentUserByEmail, "user2": emailUser2, "messages": []});
  await db.collection("chat").doc(userDoc.id).update({"chatId": userDoc.id});
  return userDoc.id;
}

Future<String> newChatReport(String emailUser2, bool msg) async {
  String currentUserByEmail = await fetchUserEmail();
  Map message = msg
      ? {
          "m":
              "Para confirmar que la empresa que está siendo reclamada es suya será necesario que envíe: imágenes de la empresa, RFC, nombre, escritura o contrato de arrendamiento del lugar y cualquier información extra que pueda ayudar a la verificación\nTo confirm that the company that is being claimed is yours, you will need to send: images of the company, RFC, name, deed or lease contract for the location and any extra information that may help with verification.",
          "t": DateTime.now().millisecondsSinceEpoch,
          "s": "admin",
        }
      : {
          "m":
              "Por favor envie la informacion necesaria para verificar su reporte\nPlease send the information necessary to verify your report",
          "t": DateTime.now().millisecondsSinceEpoch,
          "s": "admin",
        };
  var userDoc = await db.collection("chat").add({
    "user1": currentUserByEmail,
    "user2": emailUser2,
    "messages": [message]
  });
  await db.collection("chat").doc(userDoc.id).update({"chatId": userDoc.id});
  return userDoc.id;
}

Future<String?> getOldChatId(String emailUser2) async {
  String currentUserByEmail = await fetchUserEmail();
  var userDoc = await db
      .collection("chat")
      .where("user1", isEqualTo: currentUserByEmail)
      .where("user2", isEqualTo: emailUser2)
      .get();
  if (userDoc.docs.isNotEmpty) {
    return userDoc.docs.first.id;
  }
//both cases
  var userDoc2 = await db
      .collection("chat")
      .where("user1", isEqualTo: emailUser2)
      .where("user2", isEqualTo: currentUserByEmail)
      .get();
  if (userDoc2.docs.isNotEmpty) {
    return userDoc2.docs.first.id;
  }

  return null;
}

// EXAMPLE
// Map<String, dynamic> newMessage = {
//   "m": "Hello, how are you?", // Message content
//   "t": DateTime.now().millisecondsSinceEpoch, // Timestamp
//   "s": "user1", // Sender identifier (user1 or user2) it can be admin in other case
// };

Future<void> updateChatWithNewMessage(
    String chatId, Map<String, dynamic> newMessage) async {
  DocumentSnapshot doc = await db.collection("chat").doc(chatId).get();

  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  List<dynamic> currentMessages = data['messages'] ?? [];

  currentMessages.add(newMessage);

  await db.collection("chat").doc(chatId).update({
    "messages": currentMessages,
  });
}

Future<List<dynamic>> getChat(String chatId, bool type) async {
  DocumentSnapshot doc = await db.collection("chat").doc(chatId).get();

  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  List<dynamic> currentMessages = data['messages'] ?? [];
  return currentMessages;
}

// the same but as stream builder
Stream<List<dynamic>> getChatStream(String chatId) {
  return FirebaseFirestore.instance
      .collection("chat")
      .doc(chatId)
      .snapshots()
      .map((snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return data['messages'] ?? [];
  });
}

Future<Set<Map<String, dynamic>>> getChats() async {
  String fetchedEmail = await fetchUserEmail();

  QuerySnapshot emailOwnerSnapshot = await FirebaseFirestore.instance
      .collection('chat')
      .where('user1', isEqualTo: fetchedEmail)
      .get();

  QuerySnapshot emailWalkerSnapshot = await FirebaseFirestore.instance
      .collection('chat')
      .where('user2', isEqualTo: fetchedEmail)
      .get();

  List<DocumentSnapshot> combinedDocs = [
    ...emailOwnerSnapshot.docs,
    ...emailWalkerSnapshot.docs,
  ];

  Set<Map<String, dynamic>> allChatsData =
      combinedDocs.map((doc) => doc.data() as Map<String, dynamic>).toSet();

  return allChatsData;
}

Future<String?> getProfilePhoto(String emailUser) async {
  var querySnapshot =
      await db.collection("users").where("email", isEqualTo: emailUser).get();

  if (querySnapshot.docs.isNotEmpty) {
    var doc = querySnapshot.docs.first;
    String urlPhoto = doc['profilePhoto'];
    return urlPhoto;
  } else {
    return null;
  }
}

Future<String?> getUserName(String emailUser) async {
  var querySnapshot =
      await db.collection("users").where("email", isEqualTo: emailUser).get();

  if (querySnapshot.docs.isNotEmpty) {
    var doc = querySnapshot.docs.first;
    String name = doc['name'];
    return name;
  } else {
    return null;
  }
}

Future<bool> getPremiumStatus(String fetchedEmail) async {
  var userDoc = await db
      .collection("users")
      .where("email", isEqualTo: fetchedEmail)
      .get();

  if (userDoc.docs.isEmpty) {
    return false;
  } else {
    var doc = userDoc.docs.first;
    var statusPremium = doc.data()['premium'] ?? '';

    if (statusPremium == 'active') return true;
  }
  return false;
}

Future<String> getBusinessEmail(String business) async {
  var petDoc = await db.collection("business").doc(business).get();

  if (petDoc.exists) {
    String email = petDoc.data()!['email'];
    return email;
  } else {
    return '';
  }
}

//!token to array

Future<void> getAndAddTokenToArray() async {
  //add this on every login on the app
  String? token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    String fetchedEmail = await fetchUserEmail();
    var doc = await db.collection("tokenNotifications").doc(fetchedEmail).get();

    if (doc.exists) {
      List<String> tokenArray = List<String>.from(doc.data()!['tokens'] ?? []);

      // Check if the token is not already in the list
      if (!tokenArray.contains(token)) {
        tokenArray.add(token); // Add the new token to the list
        await db.collection("tokenNotifications").doc(fetchedEmail).update({
          "tokens": tokenArray, // Update with the new array of tokens
        });
      }
    } else {
      await db.collection("tokenNotifications").doc(fetchedEmail).set({
        "tokens": [token],
      });
    }
  }
}

Future<void> disableWalk(String idWalk) async {
  DateTime set = DateTime.now().subtract(const Duration(days: 5000));
  db
      .collection('walks')
      .doc(idWalk)
      .update({"timeShow": set}); //just so its on the past
}

Future<String> getUserPhone(String email) async {
  var userDoc =
      await db.collection("users").where("email", isEqualTo: email).get();

  if (userDoc.docs.isEmpty) {
    return '';
  } else {
    return userDoc.docs.first.data()['phone'];
  }
}

Future<void> newReport(
    String sender, String reported, String reason, String type) async {
  await db.collection("reports").add(
      {"sender": sender, "reported": reported, "reason": reason, "type": type});
}

Future<String> fetchEmailByIdBusiness(String idBusiness) async {
  var userDoc = await db
      .collection("users")
      .where("idBusiness", arrayContains: idBusiness)
      .get();

  var doc = userDoc.docs.first;
  String? email = doc['email'];
  return email ?? '';
}

Future<void> addNewDistribution(bool type) async {
  //*type true = travel
  Timestamp today = Timestamp.now();

  DateTime onlyDay =
      DateTime(today.toDate().year, today.toDate().month, today.toDate().day);

  String campo = type ? 'travel' : 'walk';

  var userDoc = await db
      .collection("distributionWalks")
      .where("t", isEqualTo: onlyDay)
      .get();

  if (userDoc.docs.isNotEmpty) {
    var user = userDoc.docs.first;
    int c = user[campo];

    await db.collection("walksDistribution").doc(user.id).update({
      campo: c + 1, // Increment the counter
    });
  } else {
    await db
        .collection("walksDistribution")
        .add({"t": onlyDay, "travel": type ? 1 : 0, "walk": !type ? 1 : 0});
  }
}
