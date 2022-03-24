import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_drift_database/my_drift_database.dart';

import '../common/index.dart';

class HomeScreen extends StatelessWidget {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final TodoRepo repo = RepositoryProvider.of<TodoRepo>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo list'),
      ),
      drawer: CategoriesDrawer(),
      body: StreamBuilder<List<EntryWithCategory>>(
        stream: repo.homeScreenEntries,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return Center(child: Text('no data!'));
          }

          final activeTodos = snapshot.data!;

          return ListView.builder(
            itemCount: activeTodos.length,
            itemBuilder: (context, index) {
              return TodoCard(activeTodos[index].entry);
            },
          );
        },
      ),
      bottomSheet: Material(
        elevation: 12.0,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('What needs to be done?'),
                Container(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: controller,
                          onSubmitted: (_) {
                            _createTodoEntry(repo);
                          },
                        ),
                      ),
                      IconButton(
                          icon: Icon(Icons.send),
                          color: Theme.of(context).colorScheme.secondary,
                          onPressed: () {
                            _createTodoEntry(repo);
                          }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _createTodoEntry(TodoRepo repo) {
    if (controller.text.isNotEmpty) {
      repo.createEntry(controller.text);
      controller.clear();
    }
  }
}
