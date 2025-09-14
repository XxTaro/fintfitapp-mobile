abstract class PopUp {
  Future<void> showDeleteDialog(int id);
  Future<void> showAddOrEditDialog(bool isToAdd, int id);
}