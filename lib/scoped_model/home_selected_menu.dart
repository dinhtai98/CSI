import 'package:scoped_model/scoped_model.dart';

class PopupMenu extends Model{
  int _name = -1;
  String _selectedDate = '';

  int get name => _name;
  String get selectedDate => _selectedDate;

  void changeName(int name){
    this._name = name;
    notifyListeners();
  }
  void changeDate(String date){
    this._selectedDate = date;
    notifyListeners();
  }
}