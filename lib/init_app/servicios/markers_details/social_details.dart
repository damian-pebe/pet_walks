import 'package:flutter/material.dart';
import 'package:petwalks_app/services/firebase_services.dart';
import 'package:petwalks_app/widgets/call_comments.dart';
import 'package:petwalks_app/widgets/carousel_widget.dart';

class SocialNetworkDetails extends StatefulWidget {
  final List<String> postIds;

  const SocialNetworkDetails({
    required this.postIds,
    super.key,
  });

  @override
  State<SocialNetworkDetails> createState() => _SocialNetworkDetailsState();
}

class _SocialNetworkDetailsState extends State<SocialNetworkDetails> {
  late Future<Set<Map<String, dynamic>>> _futurePosts;

  @override
  void initState() {
    super.initState();
    _futurePosts = getInfoPosts(widget.postIds);
    _getLanguage();
  }

  bool? lang;
  void _getLanguage() async {
    lang = await getLanguage();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Set<Map<String, dynamic>>>(
      future: _futurePosts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
              child: Text(lang!
                  ? 'Error: ${snapshot.error}'
                  : 'Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
              child: Text(lang!
                  ? 'No hay publicaciones disponibles'
                  : 'No posts available'));
        }

        final posts = snapshot.data!;

        return FractionallySizedBox(
          heightFactor: 1.7,
          child: lang == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: posts.map((post) {
                      String id = post['id'];

                      String description = post['description'] ?? '';
                      String type = post['type'] ?? '';
                      List<String> imageUrls =
                          List<String>.from(post['imageUrls'] ?? []);
                      List<String> comments =
                          List<String>.from(post['comments'] ?? []);

                      return Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16.0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                type,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Stack(
                              children: [
                                Center(
                                  child: SizedBox(
                                    height: 200,
                                    child: PhotoCarousel(imageUrls: imageUrls),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              lang!
                                  ? 'Descripcion: $description'
                                  : 'Description: $description',
                              style: const TextStyle(
                                  fontSize: 15, color: Colors.black),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    showCommentsDialog(
                                        context, comments, 'post', id, true);
                                  },
                                  child: Text(
                                    lang! ? "Comentarios" : "Comments",
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Icon(
                                        Icons.message,
                                        size: 20,
                                        color: Colors.black,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        lang! ? "Chat" : "Chat",
                                        style: const TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            const Divider()
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
        );
      },
    );
  }
}

// Own details only
class SocialNetworkDetailsAlone extends StatefulWidget {
  final List<String> postIds;

  const SocialNetworkDetailsAlone({
    required this.postIds,
    super.key,
  });

  @override
  State<SocialNetworkDetailsAlone> createState() =>
      _SocialNetworkDetailsAlone();
}

class _SocialNetworkDetailsAlone extends State<SocialNetworkDetailsAlone> {
  late Future<Set<Map<String, dynamic>>> _futurePosts;

  @override
  void initState() {
    super.initState();
    _futurePosts = getInfoPosts(widget.postIds);
    _getLanguage();
  }

  bool? lang;
  void _getLanguage() async {
    lang = await getLanguage();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Set<Map<String, dynamic>>>(
      future: _futurePosts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
              child: Text(lang!
                  ? 'Error: ${snapshot.error}'
                  : 'Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
              child: Text(lang!
                  ? 'No hay publicaciones disponibles'
                  : 'No posts available'));
        }

        final posts = snapshot.data!;

        return FractionallySizedBox(
          heightFactor: 1,
          child: lang == null
              ? const Center(child: CircularProgressIndicator())
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: posts.map((post) {
                        String id = post['id'];

                        String description = post['description'] ?? '';
                        String type = post['type'] ?? '';
                        List<String> imageUrls =
                            List<String>.from(post['imageUrls'] ?? []);
                        List<String> comments =
                            List<String>.from(post['comments'] ?? []);

                        return Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16.0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  type,
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Stack(
                                children: [
                                  Center(
                                    child: SizedBox(
                                      height: 200,
                                      child:
                                          PhotoCarousel(imageUrls: imageUrls),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                lang!
                                    ? 'Descripcion: $description'
                                    : 'Description: $description',
                                style: const TextStyle(
                                    fontSize: 15, color: Colors.black),
                              ),
                              const SizedBox(height: 5),
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    showCommentsDialog(
                                        context, comments, 'post', id, true);
                                  },
                                  child: Text(
                                    lang! ? "Comentarios" : "Comments",
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
