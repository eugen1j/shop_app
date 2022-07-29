import 'package:flutter/material.dart';

class FutureProgressBuilder<T> extends StatelessWidget {
  final ValueWidgetBuilder<T?> builder;
  final Future<T> future;
  final Widget? child;

  const FutureProgressBuilder({required this.builder, required this.future, this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final error = snapshot.error;
          final data = snapshot.data;
          if (error == null) {
            return builder(context, data, child);
          } else {
            return Center(child: Text('An error occurred: ${error}'));
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}