import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/categories_drawer.dart';
import '../common/todo_card.dart';
import '../cubit/todo_bloc.dart';

class HomeScreen extends StatelessWidget {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo list'),
      ),
      drawer: CategoriesDrawer(),
      body: BlocBuilder<TodoCubit, TodoState>(
        builder: (context, state) {
          if (state.status == TodoStatus.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.status == TodoStatus.noData) {
            return Center(
              child: Text('no data'),
            );
          }

          return ListView.builder(
            itemCount: state.entries!.length,
            itemBuilder: (context, index) {
              return TodoCard(state.entries![index].entry);
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
                Text('Напиши что-нибудь ?'),
                Container(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: controller,
                          onSubmitted: (_) {
                            _createTodoEntry(context);
                          },
                        ),
                      ),
                      IconButton(
                          icon: Icon(Icons.send),
                          color: Theme.of(context).colorScheme.secondary,
                          onPressed: () {
                            _createTodoEntry(context);
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

  void _createTodoEntry(BuildContext ctx) {
    if (controller.text.isNotEmpty) {
      ctx.read<TodoCubit>().createTodo(controller.text);
      controller.clear();
    }
  }
}
