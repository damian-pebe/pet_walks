import 'package:flutter/material.dart';
import 'package:petwalks_app/widgets/comments_dialog.dart';

void showCommentsDialog(BuildContext context, List<dynamic> comments,
    String collection, String id) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black45,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return CommentsDialog(
        comments: comments,
        collection: collection,
        id: id,
      );
    },
  );
}
