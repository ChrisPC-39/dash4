import 'database/item.dart';

const String itemBoxName = "itemBoxName${33}";

Item section(int id) {
  return Item(
    name: 'Section $id',
    id: id,
    isSection: true,
  );
}