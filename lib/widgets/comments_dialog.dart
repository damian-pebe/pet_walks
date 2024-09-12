import 'package:flutter/material.dart';
import 'package:petwalks_app/services/firebase_services.dart';

class CommentsDialog extends StatefulWidget {
  final List<dynamic> comments;
  final String collection;
  final String id;
  final bool addNewComment;

  const CommentsDialog(
      {required this.comments,
      required this.collection,
      required this.id,
      required this.addNewComment,
      super.key});

  @override
  _CommentsDialogState createState() => _CommentsDialogState();
}

class _CommentsDialogState extends State<CommentsDialog> {
  final TextEditingController _commentController = TextEditingController();
  String? email;

  @override
  void initState() {
    super.initState();
    _initializeFutures();
    _getLanguage();
  }

  bool? lang;
  void _getLanguage() async {
    lang = await getLanguage();
    setState(() {});
  }

  Future<void> _initializeFutures() async {
    email = await fetchUserEmail();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: lang == null
          ? null
          : Material(
              borderRadius: BorderRadius.circular(20.0),
              elevation: 10,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.message,
                            color: Theme.of(context).primaryColor),
                        const SizedBox(width: 10),
                        Text(
                          lang! ? 'Comentarios' : 'Comments',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    if (widget.comments.isEmpty)
                      Text(
                        lang!
                            ? 'No hay comentarios disponibles'
                            : 'There are no comments yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      )
                    else
                      ...widget.comments.map((comment) {
                        return Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Text(
                                      comment.toString(),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.report,
                                        color: Color(0xFFBB1408),
                                        size: 28,
                                      ),
                                      onPressed: () {},
                                    ),
                                    Text(
                                      lang! ? 'Denunciar' : 'Report',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Divider(
                              thickness: 1.5,
                              color: Colors.grey[300],
                            ),
                          ],
                        );
                      }),
                    const SizedBox(height: 10),
                    if (widget.addNewComment)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              decoration: InputDecoration(
                                hintText: lang!
                                    ? 'Escribe un comentario...'
                                    : 'Write a new comment...',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.send,
                                color: Theme.of(context).primaryColor),
                            onPressed: () {
                              if (_commentController.text.isNotEmpty) {
                                setState(() {
                                  widget.comments.add(_commentController.text);
                                });
                                addComment(
                                    email!,
                                    _commentController.toString(),
                                    widget.collection,
                                    widget.id);
                                _commentController.clear();
                              }
                            },
                          ),
                        ],
                      ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 20),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        lang! ? 'Cerrar' : 'Close',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
