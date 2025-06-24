import 'package:fluent_ui/fluent_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'package:picturebot/presentation/page/home_page.dart';

import 'data/model/database/database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase();

  await database
      .into(database.todoItems)
      .insert(
        TodoItemsCompanion.insert(
          title: 'Tomek is de beste',
          content: 'We can now write queries and define our own tables.',
        ),
      );
  List<TodoItem> allItems = await database.select(database.todoItems).get();
  final item = await (database.select(
    database.todoItems,
  )..where((tbl) => tbl.id.equals(7))).getSingleOrNull();
  print(item?.title);
  runApp(
    FluentApp(
      title: 'Fluent UI for Flutter',
      home: HomePage(),
    ),
  );
}
