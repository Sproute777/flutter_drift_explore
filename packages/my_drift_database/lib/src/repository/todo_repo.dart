import 'package:drift/drift.dart';
import 'package:rxdart/rxdart.dart';
import '../database/database.dart';

/*-----------------------------------------------------------------------------*/
class CategoryWithActiveInfo {
  CategoryWithActiveInfo(this.categoryWithCount, this.isActive);

  CategoryWithCount categoryWithCount;
  bool isActive;
}

/*-----------------------------------------------------------------------------*/

class TodoRepo {
  TodoRepo(this.db) {
    init();
  }

//______________________________________________________________________________
  final Database db;
  final BehaviorSubject<Category?> _activeCategory =
      BehaviorSubject.seeded(null);
  final BehaviorSubject<List<CategoryWithActiveInfo>> _allCategories =
      BehaviorSubject();

  Stream<List<EntryWithCategory>>? _currentEntries;
  Stream<List<EntryWithCategory>>? get homeScreenEntries => _currentEntries;
  Stream<List<CategoryWithActiveInfo>> get categories => _allCategories;

//______________________________________________________________________________
  void init() {
    // listen for the category to change. Then display all entries that are in
    // the current category on the home screen.
    _currentEntries = _activeCategory.switchMap(db.watchEntriesInCategory);

    // also watch all categories so that they can be displayed in the navigation
    // drawer.
    Rx.combineLatest2<List<CategoryWithCount>, Category?,
        List<CategoryWithActiveInfo>>(
      db.categoriesWithCount(),
      _activeCategory,
      (allCategories, selected) {
        return allCategories.map((category) {
          final isActive = selected?.id == category.category?.id;

          return CategoryWithActiveInfo(category, isActive);
        }).toList();
      },
    ).listen(_allCategories.add);
  }

//______________________________________________________________________________
  void showCategory(Category? category) {
    _activeCategory.add(category);
  }

//______________________________________________________________________________
  void addCategory(String description) async {
    final id = await db.createCategory(description);
    showCategory(Category(id: id, description: description));
  }

//______________________________________________________________________________
  void createEntry(String content) async {
    await db.createTodo(TodosCompanion(
      content: Value(content),
      category: Value(_activeCategory.value?.id),
    ));
  }

//______________________________________________________________________________
  void updateEntry(TodoEntry entry) async {
    db.updateTodo(entry);
  }

//______________________________________________________________________________
  void deleteEntry(TodoEntry entry) async {
    db.deleteTodo(entry);
  }

//______________________________________________________________________________
  void deleteCategory(Category category) async {
    if (_activeCategory.value?.id == category.id) {
      showCategory(null);
    }
    await db.deleteCategory(category);
  }

//______________________________________________________________________________
  void dispose() {
    _allCategories.close();
  }
}

/*-----------------------------------------------------------------------------*/