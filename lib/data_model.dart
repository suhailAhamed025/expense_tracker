import 'package:flutter/material.dart';
import 'home.dart';

class DataModel extends ChangeNotifier{
   List<TransactionalSms> _mydataList = [];
   List<TransactionalSms> _currentMonth = [];
    num _limit = 0 ; 

  List<TransactionalSms> get mydataList=>_mydataList;
  List<TransactionalSms> get cuttentMonth=>_currentMonth;

   num get limit=> _limit;
   
  void updateDataList(List<TransactionalSms> newDataList, List<TransactionalSms> currentMonthsList, num newLimit){
    _mydataList= newDataList;
    _currentMonth=currentMonthsList;
    print("suhail $newLimit");
    _limit= newLimit;
    notifyListeners();
  }
}