import 'package:flutter/material.dart';
import 'package:lista_de_tarefa/repositories/todo_repository.dart';

import '../models/todo.dart';
import '../widgets/todo_item.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<Todo> todos = [];
  TodoRepository repository = TodoRepository();
  String? error;
  @override
  void initState() {
    super.initState();

    repository.getTodoList().then((value) {
      setState(
        () {
          todos = value;
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    void onDelete(Todo todo) {
      int position = todos.indexOf(todo);
      setState(() {
        todos.remove(todo);
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // duration: const Duration(seconds: 3),
          content: Text(
            'Tarefa ${todo.title} foi removida com sucesso',
            style: const TextStyle(
              color: Colors.red,
            ),
          ),
          backgroundColor: Colors.white,
          action: SnackBarAction(
            label: 'Desfazer',
            textColor: const Color(0xff00d7f3),
            onPressed: () {
              setState(() {
                todos.insert(position, todo);
              });
              repository.saveTodoList(todos);
            },
          ),
        ),
      );
    }

    void showDialogDeleteAll() {
      showDialog(
        context: context,
        builder: ((context) => AlertDialog(
              title: const Text('Limpar Tudo?'),
              content: const Text(
                'Voce realmente deseja limpar todas as tarefas?',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Color(0xff00d7f3),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      todos.clear();
                    });
                    repository.saveTodoList(todos);
                  },
                  child: const Text(
                    'Limpar',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            )),
      );
    }

    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: 'Adicione uma tarefa',
                          border: const OutlineInputBorder(),
                          errorText: error,
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xff00d7f3),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (controller.text.isEmpty) {
                          setState(() {
                            error = 'O titulo é obrigatório';
                          });
                          return;
                        }
                        Todo newTodo = Todo(
                          title: controller.text,
                          date: DateTime.now(),
                        );
                        setState(() {
                          todos.add(newTodo);
                          error = null;
                        });
                        repository.saveTodoList(todos);
                        controller.clear();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff00d7f3),
                        padding: const EdgeInsets.all(14),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (Todo todo in todos)
                        TodoItem(todo: todo, onDelete: onDelete),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child:
                          Text('Você possui ${todos.length} tarefas pendentes'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: showDialogDeleteAll,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff00d7f3),
                        padding: const EdgeInsets.all(14),
                      ),
                      child: const Text('Limpar Tudo'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
