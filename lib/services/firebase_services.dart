import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  try {
    var userDoc =
        await db.collection("users").where("email", isEqualTo: email).get();

    if (userDoc.docs.isEmpty) {
      return [];
    } else {
      var doc = userDoc.docs.first;
      var idPetsArray = List<String>.from(doc.data()['idPets'] ?? []);
      return idPetsArray;
    }
  } catch (e) {
    print('Error fetching user: $e');
    return [];
  }
}

Future<List<String>> getBusinessByIds() async {
  String fetchedEmail = await fetchUserEmail();

  try {
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
  } catch (e) {
    print('Error fetching user: $e');
    return [];
  }
}

Future<List<String>> getbusinessIds() async {
  String fetchedEmail = await fetchUserEmail();
  try {
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
  } catch (e) {
    print('Error fetching user: $e');
    return [];
  }
}

Future<Set<Map<String, dynamic>>> getPetsHistory(List<String> idPets) async {
  try {
    if (idPets.isEmpty) {
      return {};
    }

    var petsQuerySnapshot = await db
        .collection("pets")
        .where(FieldPath.documentId, whereIn: idPets.toList())
        .get();

    Set<Map<String, dynamic>> pets = petsQuerySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toSet();

    return pets;
  } catch (e) {
    print('Error fetching pets: $e');
    return {};
  }
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
        List<dynamic>? imageUrls = data['imageUrls'];

        allBusinessData[element] = {
          'imageUrl': imageUrl,
          'name': name,
          'imageUrls': imageUrls,
          'id': element,
        };
      }
    } else {}
  }
  return allBusinessData;
}

Future<Set<Map<String, dynamic>>> fetchImageNamePet(List<String> idPets) async {
  print('idPets: $idPets');
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
          List<double> rating =
              data['rating'] ?? 0.0; // Default to 0.0 if not present
          String name =
              data['name'] ?? ''; // Default to an empty string if not present
          List<String>? comments = List<String>.from(data['comments'] ?? []);

          print(
              'Fetched Data: ImageUrls: $imageUrls, Rating: $rating, Name: $name, Comments: $comments');

          allPetsData[element] = {
            'imageUrls': imageUrls,
            'name': name,
            'comments': comments,
            'rating': rating,
            'id': element,
          };
        }
      } else {
        print("Pet with ID: $element not found");
      }
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
      "rating": rating
    });
  }
}

Future<List<String>> getServices(String email) async {
  try {
    var userDoc =
        await db.collection("users").where("email", isEqualTo: email).get();
    if (userDoc.docs.isNotEmpty) {
      var user = userDoc.docs.first;
      var services = List<String>.from(user.data()['activeServices'] ?? []);
      return services;
    } else {
      print("User with email $email not found.");
      return [];
    }
  } catch (e) {
    print(e);
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
  } else {
    print("User with email $email not found.");
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
    throw Exception('Unexpected type for languaje field');
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
  } else {
    print("User with email $email not found.");
  }
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
  try {
    var userDoc =
        await db.collection("users").where("email", isEqualTo: email).get();
    if (userDoc.docs.isNotEmpty) {
      var user = userDoc.docs.first;
      var walk = List<String>.from(user.data()['idWalks'] ?? []);
      walk.add(newWalkId ?? 'Invalid state for walk');

      await db.collection("users").doc(user.id).update({"idWalks": walk});
    }
  } catch (e) {}
}

Future<void> addBusinessToUser(String email, String? newBusinessId) async {
  try {
    var userDoc =
        await db.collection("users").where("email", isEqualTo: email).get();
    if (userDoc.docs.isNotEmpty) {
      var user = userDoc.docs.first;
      var business = List<String>.from(user.data()['idBusiness'] ?? []);
      business.add(newBusinessId ?? 'Invalid state for walk');

      await db
          .collection("users")
          .doc(user.id)
          .update({"idBusiness": business});
    }
  } catch (e) {}
}

Future<void> addPostToUser(String email, String? newPostId) async {
  try {
    var userDoc =
        await db.collection("users").where("email", isEqualTo: email).get();
    if (userDoc.docs.isNotEmpty) {
      var user = userDoc.docs.first;
      var post = List<String>.from(user.data()['idPost'] ?? []);
      post.add(newPostId ?? 'Invalid state for walk');

      await db.collection("users").doc(user.id).update({"idPost": post});
    }
  } catch (e) {}
}

class UserService {
  Future<Set<Map<String, dynamic>>> getUser(String email) async {
    try {
      var userDoc =
          await db.collection("users").where("email", isEqualTo: email).get();

      if (userDoc.docs.isEmpty) {
        return {};
      } else {
        return userDoc.docs.map((doc) => doc.data()).toSet();
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching user: $e');
      return {};
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
  List<double> rating = [0];
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
  });
  String lastBusinessId = userDoc.id;

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
    List<String>? selectedPets,
    String? type,
    String ownerEmail) async {
  int timeWalkingInt = int.parse(timeWalking!);
  int price = getPriceWalk(timeWalkingInt, selectedPets!);

  DocumentReference userDoc = await db.collection("walks").add({
    "timeShow": timeShow,
    "timeShowController": timeShowController ?? "",
    "payMethod": payMethod ?? "",
    "walkWFriends": walkWFriends ?? "",
    "timeWalking": timeWalking,
    "address": place ?? "",
    "position": GeoPoint(position.latitude, position.longitude),
    "description": description ?? "",
    "selectedPets": selectedPets,
    "mode": '',
    "type": type ?? '',
    "price": price,
    "ownerEmail": ownerEmail
  });
  String lastWalkId = userDoc.id;

  await db.collection("walks").doc(lastWalkId).update({
    "id": lastWalkId,
  });

  return lastWalkId;
}

Future<String> newProgramWalk(
    DateTime? timeShow, //for the script as well
    String? timeShowController, //for the script as well
    String? payMethod,
    String? walkWFriends,
    String? timeWalking,
    String? travelTo,
    LatLng travelToPosition,
    String? place,
    LatLng position,
    String? description,
    List<String>? selectedPets,
    //this fields are gonna be checked to return the walk or not
    List<DateTime>? dateTime,
    DateTime? startDate,
    DateTime? endDate,
    String? mode,
    String? type,
    String ownerEmail) async {
  int? price;
  if (timeWalking != '') {
    int timeWalkingInt = int.parse(timeWalking!);
    price = getPriceWalk(timeWalkingInt, selectedPets!);
  } else {
    price = getPriceTravel(travelToPosition);
  }
  DocumentReference userDoc = await db.collection("walks").add({
    "timeShow": timeShow ?? "",
    "timeShowController": timeShowController ?? "",
    "payMethod": payMethod ?? "",
    "walkWFriends": walkWFriends ?? "",
    "timeWalking": timeWalking ?? "",
    "travelTo": travelTo ?? "",
    "travelToPosition":
        GeoPoint(travelToPosition.latitude, travelToPosition.longitude),
    "address": place ?? "",
    "position": GeoPoint(position.latitude, position.longitude),
    "description": description ?? "",
    "selectedPets": selectedPets ?? [],
    "dateTime": dateTime ?? [],
    "startDate": startDate ?? [],
    "endDate": endDate ?? [],
    "mode": mode ?? '',
    "type": type ?? '',
    "price": price,
    "ownerEmail": ownerEmail
  });
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

int getPriceTravel(LatLng goTo) {
  return 0;
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
    "position": idBusiness ?? "",
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
    "position": idBusiness ?? "",
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
    "position": idBusiness ?? "",
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
  DocumentReference userDoc = await db.collection("history").add({
    "idWalk": idWalk,
    "emailOwner": emailOwner,
    "emailWalker": emailWalker,
    "position": idBusiness ?? "",
    "status": 'awaiting' // 'awaiting', 'walking', 'done'
  });

  return userDoc.id;
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
      String? mode = data['mode'] as String?;
      Timestamp? timeShowTimestamp = data['timeShow'] as Timestamp?;
      DateTime? timeShow = timeShowTimestamp?.toDate();
      print('Processing data with mode: $mode, timeShow: $timeShow');

      if (mode == '') {
        //CORRECT!!!
        if (timeShow != null && timeShow.isAfter(now)) {
          walks.add(data);
        }
      } else if (mode == 'selectedDates') {
        print('Processing selectedDates mode');
        var listDynamic = data['dateTime'];
        if (listDynamic is List<dynamic>) {
          List<DateTime> list = listDynamic
              .whereType<Timestamp>()
              .map((item) => item.toDate())
              .toList();
          for (var elementInto in list) {
            print('Checking date in selectedDates: $elementInto');
            if (elementInto.isAfter(now)) {
              int? timeShowController = data['timeShowController'] as int?;
              if (timeShowController != null) {
                DateTime dateFuture =
                    now.add(Duration(hours: timeShowController));
                print('Calculated dateFuture: $dateFuture');
                if (elementInto.isBefore(dateFuture)) {
                  walks.add(data);
                  print('Added walk to set, selectedDates mode');
                  break;
                }
              }
            }
          }
        }
      } else if (mode == 'startEnd') {
        print('Processing startEnd mode');

        List<DateTime> list = getArrayOfDateTime(data);
        if (list.isNotEmpty) {
          for (var elementInto in list) {
            print('Checking date in startEnd: $elementInto');
            if (elementInto.isAfter(now)) {
              int? timeShowController;

              if (data['timeShowController'] is String) {
                timeShowController =
                    int.tryParse(data['timeShowController'] as String);
              } else if (data['timeShowController'] is int) {
                timeShowController = data['timeShowController'] as int?;
              }

              if (timeShowController != null) {
                DateTime dateFuture =
                    elementInto.add(Duration(hours: timeShowController));
                print('Calculated dateFuture from elementInto: $dateFuture');

                if (elementInto.isBefore(now) && dateFuture.isAfter(now)) {
                  // ELEMENT INTO BEFORE NOW & DATE FUTURE AFTER NOW i guess
                  walks.add(data);
                  print('Added walk to set, startEnd mode');
                  break;
                }
              }
            }
          }
        }
      }
    } else {
      print('Data is null for document id: ${element.id}');
    }
  }

  print('Total walks collected: ${walks.length}');
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
      timeShowStart = timeShowStart.add(Duration(days: 1));
    }
  } else {
    print("startDate or endDate is not of type Timestamp");
  }

  return list;
}

Future<String> newPost(
    String? description, List<String?> imageUrls, String? type) async {
  DateTime now = DateTime.now();
  DateTime futureDate = now.add(const Duration(days: 7));

  var address;
  String _email = await fetchUserEmail();
  var userDocEmail =
      await db.collection("users").where("email", isEqualTo: _email).get();

  if (userDocEmail.docs.isNotEmpty) {
    var user = userDocEmail.docs.first;
    address = user.data()['address'] ?? '';
  }

  DocumentReference userDoc = await db.collection("post").add({
    "description": description ?? "",
    "imageUrls": imageUrls,
    "address": address,
    "type": type,
    "deleteTime": futureDate,
    "comments": ['RECOMENDADOOO!'],
  });
  String lastPostId = userDoc.id;

  return lastPostId;
}

Future<LatLng?> getLatLngFromAddress(String address) async {
  try {
    List<Location> locations = await locationFromAddress(address);
    if (locations.isNotEmpty) {
      final location = locations.first;
      return LatLng(location.latitude, location.longitude);
    }
  } catch (e) {
    print("Error getting location: $e");
  }
  return null; // Return null if the address cannot be converted to LatLng
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
  } else {
    print('Error getting email from user');
  }
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

  final data = doc.data() as Map<String, dynamic>;
  if (data['ownerStatus'] == 'ready') {
    return true;
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

Future<void> updateHistory(String id, String type) async {
  await db.collection('history').doc(id).update({
    "status": type,
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
