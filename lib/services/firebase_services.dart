import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

Future<Map<String, dynamic>> getInfoPets(String email, String? idPet) async {
  var petDoc = await db.collection("pets").doc(idPet).get();

  if (petDoc.exists) {
    Map<String, dynamic> data = petDoc.data()!;
    return data;
  } else {
    print("pet: ${idPet} not found");
    return {};
  }
}

Future<Map<String, dynamic>> fetchBuilderInfo(
    String email, List<String>? idPets) async {
  Map<String, dynamic> allPetsData = {};

  if (idPets != null && idPets.isNotEmpty) {
    for (var element in idPets) {
      var petDoc = await db.collection("pets").doc(element).get();

      if (petDoc.exists) {
        Map<String, dynamic>? data = petDoc.data();
        if (data != null) {
          String? imageUrl = (data['imageUrls'] as List<dynamic>?)?.firstOrNull;
          String? name = data['name'] as String?;
          List<dynamic>? imageUrls = data['imageUrls'];

          print(
              'Fetched Data: ImageUrl: $imageUrl, Name: $name, ImageUrls: $imageUrls');

          allPetsData[element] = {
            'imageUrl': imageUrl,
            'name': name,
            'imageUrls': imageUrls,
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

Future<Map<String, dynamic>> fetchBuilderInfos(
    String email, List<String>? idPets) async {
  Map<String, dynamic> allPetsData = {};

  if (idPets != null && idPets.isNotEmpty) {
    for (var element in idPets) {
      var petDoc = await db.collection("pets").doc(element).get();

      if (petDoc.exists) {
        Map<String, dynamic>? data = petDoc.data();
        if (data != null) {
          List<dynamic>? imageUrls = data['imageUrls'];
          double rating =
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
  var userDoc =
      await db.collection("users").where("email", isEqualTo: email).get();
  if (userDoc.docs.isEmpty) {
    await db.collection("users").add({
      "name": name ?? "",
      "email": email,
      "phone": phone ?? "",
      "address": home ?? "",
      "idPets": [],
      "profilePhoto": '',
      "activeServices": ['walk', 'request', 'business'],
      "languaje": 'spanish'
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

Future<String> getLanguaje(String? email) async {
  var userDoc =
      await db.collection("users").where("email", isEqualTo: email).get();

  if (userDoc.docs.isNotEmpty) {
    var user = userDoc.docs.first;
    var languaje = user.data()['languaje'];
    return languaje;
  } else {
    print("User with email $email not found.");
    return 'Error';
  }
}

Future<void> updateLanguaje(String? email, String languaje) async {
  var userDoc =
      await db.collection("users").where("email", isEqualTo: email).get();
  if (userDoc.docs.isNotEmpty) {
    var user = userDoc.docs.first;

    await db.collection("users").doc(user.id).update({"languaje": languaje});
  } else {
    print("User with email $email not found.");
  }
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
  } else {
    print("User with email $email not found.");
  }
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

Future<void> newBusiness(
    String? name,
    String? category,
    String? phone,
    String? place,
    LatLng position,
    String? description,
    List<String>? downloadUrls) async {
  double rating = 0;
  await db.collection("business").add({
    "name": name ?? "",
    "email": category ?? "",
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
}

Future<void> newWalk(
    DateTime? timeShow, //for the script as well
    String? timeShowController, //for the script as well
    String? payMethod,
    String? walkWFriends,
    String? timeWalking,
    String? place,
    LatLng position,
    String? description,
    List<String>? selectedPets) async {
  await db.collection("walks").add({
    "timeShow": timeShow ?? "",
    "timeShowController": timeShowController ?? "",
    "payMethod": payMethod ?? "",
    "walkWFriends": walkWFriends ?? "",
    "timeWalking": timeWalking ?? "",
    "address": place ?? "",
    "position": GeoPoint(position.latitude, position.longitude),
    "description": description ?? "",
    "selectedPets": selectedPets ?? [],
    //just to be empty
    "dateTime": [],
    "startDate": [],
    "endDate": [],
    "mode": '',
  });
}

Future<void> newProgramWalk(
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
) async {
  await db.collection("walks").add({
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
  });
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
    walks.add(element.data() as Map<String, dynamic>);
  }
/*
  for (var element in queryWalks.docs) {
    var data = element.data() as Map<String, dynamic>?;
    if (data != null) {
      String? mode = data['mode'] as String?;
      DateTime? timeShow = data['timeShow'] as DateTime?;
      print('INICIO DE GET2');
      if (mode == '') {
        print('INICIO DE GET mode empty');
        if (timeShow != null && !timeShow.isAfter(now)) {
          walks.add(data);
        }
      } else if (mode == 'selectedDates') {
        print('INICIO DE GET mode selected');
        List<DateTime>? list = data['dateTime'] as List<DateTime>?;
        if (list != null) {
          for (var elementInto in list) {
            if (elementInto.isAfter(now)) {
              int? timeShowController = data['timeShowController'] as int?;
              if (timeShowController != null) {
                DateTime dateFuture =
                    now.add(Duration(hours: timeShowController));
                if (elementInto.isBefore(dateFuture)) {
                  walks.add(data);
                  break;
                }
              }
            }
          }
        }
      } else if (mode == 'startEnd') {
        print('INICIO DE GET mode started');
        List<DateTime>? list = data['dateTime'] as List<DateTime>?;
        if (list != null) {
          for (var elementInto in list) {
            if (elementInto.isAfter(now)) {
              int? timeShowController = data['timeShowController'] as int?;
              if (timeShowController != null) {
                DateTime dateFuture =
                    now.add(Duration(hours: timeShowController));
                if (elementInto.isBefore(dateFuture)) {
                  walks.add(data);
                  break;
                }
              }
            }
          }
        }
      }
    } else {
      print('INICIO DE GET');
    }
  }
*/
  return walks;
}

Future<String> newPet(
    String? name,
    String? race,
    String? size,
    String? description,
    String? old,
    String? color,
    List<String>? imageUrls) async {
  late String lastPetId;
  DocumentReference userDoc = await db.collection("pets").add({
    "name": name ?? "",
    "race": race ?? "",
    "size": size ?? "",
    "old": old ?? "",
    "color": color ?? "",
    "description": description ?? "",
    "imageUrls": imageUrls ?? [],
    //example
    "rating": 0.0,
    "comments": ['muy buena mascota', 'linda mascota', 'muy cariñoso!'],
  });

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

String? email;
Future<String> fetchUserEmail() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    email = user.email;
  } else {
    print('Error getting email from user');
  }
  return email ?? 'Error fetching the email';
}
