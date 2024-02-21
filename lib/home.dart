//import 'package:expense_tracker/bar%20graph/report.dart';
import 'package:expense_tracker/data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'expenseSummary.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

//just trying
class TransactionalSms {
  String content;
  String date;
  String money;

  TransactionalSms(this.content, this.date, this.money);
}

class _HomePageState extends State<HomePage> {
  List<TransactionalSms> currentMonthsSMSList = [];
  List<TransactionalSms> lastSixMonthsSMSList = [];
  num setLimit = 0; 

  //to read SMS from inbox
  void readTransactionSMS() async {
    if (setLimit == 0) {
      // Show alert dialog to set the limit first
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Set Your Limit'),
          content: Text('Please set your limit first.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // SmsQuery is a built in function
      try {
        SmsQuery query = SmsQuery();
        //we are storing all the inbox messages massages
        List<SmsMessage> messages = await query.getAllSms;
        //just trying
        lastSixMonthsSMSList.clear();
        currentMonthsSMSList.clear();

        DateTime today = DateTime.now();
        DateTime sixMothsAgo = DateTime(today.year, today.month - 6, today.day);
        DateTime firstDayofmonth = DateTime(today.year, today.month, 1);
        DateTime lastDayOfmonth = DateTime(today.year, today.month + 1, 0);
        

        //print(transactionalSMSList);
        parseTransactionalSms(var message) {
          //print (message.body);
          DateTime smsDateTime = message.date;
          String smsDate = smsDateTime.toString().split(' ')[0];
          RegExp statusRegex = RegExp(r'(\bCr\b|\bDr\b|credited|debited)');
          RegExp amountRegex = RegExp(r'(INR|Rs)\s?\.?\s?(\d+(\.\d{1,2})?)');

          RegExpMatch? statusMatch = statusRegex.firstMatch(message.body);
          RegExpMatch? amountMatch = amountRegex.firstMatch(message.body);

          if (statusMatch != null && amountMatch != null) {
            String? status = statusMatch.group(1).toString();
            String? amount = amountMatch.group(2).toString();

            //  print('status: ' + status!);
            //  print('smsDate: ' + smsDate);
            //  print('amount: ' + amount!);
            return TransactionalSms(status, smsDate, amount);
          } else {
            return null;
          }
        }

        bool isWithinCurrentMonth(DateTime smsDate, DateTime firstDayOfMonth,
            DateTime lastDayOfmonth) {
          return smsDate.isAfter(firstDayOfMonth) &&
              smsDate.isBefore(lastDayOfmonth.add(Duration(days: 1)));
        }

        bool isWithinSixMonth(
            DateTime smsDate, DateTime startDate, DateTime endDate) {
          return smsDate.isAfter(startDate) && smsDate.isBefore(endDate);
        }

        for (SmsMessage message in messages) {
          // if(isTransactionalSms(message)){
          TransactionalSms? transactionalSms = parseTransactionalSms(message);
          if (transactionalSms != null) {
            // Process the valid transactional SMS
            // print(transactionalSms.date);

            if (transactionalSms != null && transactionalSms.date != null) {
              String dateString =
                  transactionalSms.date; // Asserting non-null for Date
              DateTime dateTime = DateTime.parse(dateString);
              if (isWithinSixMonth(dateTime, sixMothsAgo, today)) {
               // setState(() {
                  lastSixMonthsSMSList.add(transactionalSms);
                //});
              }
              if (isWithinCurrentMonth(
                  dateTime, firstDayofmonth, lastDayOfmonth)) {
                //setState(() {
                  currentMonthsSMSList.add(transactionalSms);
                  //totalAmount = 0;
                //});

                //List<String> stringList = lastSixMonthsSMSList.map((sms) => sms.toString()).toList();
                Provider.of<DataModel>(context, listen: false)
                    .updateDataList(lastSixMonthsSMSList, currentMonthsSMSList, 0);
              } else {
                // print('TransactionalSms or smsDate is null');
                //print('TansactionalSms: ${message.body}');
              }
            }
          } else {
            // Exclude messages without a valid match
            // print('Message excluded: ${message.body}');
          }

          //  }
        }

        //   //using for in loop to itterate from the messages
        //   for(SmsMessage message in messages){
        //      if((message.body!.toLowerCase().contains('cr'))||(message.body!.toLowerCase().contains('dr'))){
        //       if(isTransactionalSms(message)){

        //             var amount = extractAmount(message.body);
        //         if(amount.isNotEmpty){
        //            setState((){
        //              myAmount.add(amount);
        //         });
        //         }
        //         }
        //       }
        //     }
      } catch (e) {
        print('Error reading SMS : ${e}');
      }
    }
  }

  //late List<String> stringList;

  //List<String> stringList = lastSixMonthsSMSList.map((tsms) => tsms.toString()).toList();
  // void initState(){
  //   super.initState();
  //   readTransactionSMS();
  // }
  void initState() {
    super.initState();
    //readTransactionSMS();
    //stringList = lastSixMonthsSMSList.map((sms) => sms.toString()).toList();
  }
  //   void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   Provider.of<DataModel>(context, listen: false).updateDataList(stringList);
  // }

  @override
  Widget build(BuildContext context) {
    var totalBalance = calculateTotalAmount(
        currentMonthsSMSList, Provider.of<DataModel>(context).limit);
    // List<String> stringList = lastSixMonthsSMSList.map((sms) => sms.toString()).toList();
    // Provider.of<DataModel>(context, listen: false).updateDataList(stringList);

    return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              expenseSummary(
                  balance: (totalBalance?[0] ?? 0).toStringAsFixed(2),
                  income: (totalBalance?[2] ?? 0).toStringAsFixed(2),
                  expense: (totalBalance?[1] ?? 0).toStringAsFixed(2)),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: currentMonthsSMSList.length,
                  itemBuilder: (context, index) {
                    TransactionalSms sms = currentMonthsSMSList[index];
                    return Card(
                      color: Colors.grey[200],
                      margin:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: ListTile(
                        leading: Icon(Icons.currency_rupee),
                        title: Text(sms.money),
                        subtitle: Text(sms.content),
                        trailing: _getArrowIcon(sms.content),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              readTransactionSMS();
              //Provider.of<DataModel>(context, listen:false).updateDataList(lastSixMonthsSMSList);
            },
            child: Icon(Icons.sync)));
  }

  Icon _getArrowIcon(String content) {
    // default color
    Color arrowColor = Colors.black;
    if (content == "Cr" || content == "credited") {
      // color for up arrow
      arrowColor = Colors.green;
      return Icon(
        Icons.arrow_downward,
        color: arrowColor,
      );
    } else {
      arrowColor = Colors.red;
      return Icon(Icons.arrow_upward, color: arrowColor);
    }
  }

  num totalAmount = 0;
  List? calculateTotalAmount(List myAmount, num limit) {
    print('mydata $limit');
    setLimit += totalAmount + limit;
    num expense = 0;
    num income = 0;
    for (int i = 0; i < myAmount.length; i++) {
      var sms = myAmount[i];
      if (sms.content == 'Cr') {
        setLimit += double.parse(sms.money);
        income += double.parse(sms.money);
      } else if (sms.content == 'Dr') {
        // print('sms money : $sms.money ');
        setLimit -= double.parse(sms.money);
        expense += double.parse(sms.money);
      } else if (sms.content == 'debited') {
        setLimit -= double.parse(sms.money);
        expense += double.parse(sms.money);
      } else if (sms.content == 'credited') {
        setLimit += double.parse(sms.money);
        income += double.parse(sms.money);
      }
    }
    List result = [setLimit, expense, income];
    return result;
  }

  //  bool isTransactionalSms(SmsMessage message){
  //    return message.body!.toLowerCase().contains('bank');
  //  }

  // dynamic extractAmount(text){
  //   //regular expression to match the currency symbol and amount
  //   //'[rR][sS]\.?\s[,\d]+\.?\d{0,2}|[iI][nN][rR]\.?\s*[,\d]+\.?\d{0,2}'
  //   RegExp regex = RegExp(r'INR\.(\d+(\.\d{1,2})?)');
  //   RegExp regex1 = RegExp(r'(\d+(\.\d{1,2})?)');

  //   RegExp statusRegex =RegExp(r'(Cr|Dr)');
  //   //finding the first match in the text

  //   var amount1 = regex.stringMatch(text)??0;
  //   var amount = regex1.stringMatch(amount1.toString())??0;

  //   var status = statusRegex.stringMatch(text)??'nothing';

  //       return [amount,status];

  // }
}
