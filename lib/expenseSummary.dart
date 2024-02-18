import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'data_model.dart';

num limit = 0;

class expenseSummary extends StatefulWidget {
  final String balance;
  final String income;
  final String expense;

  expenseSummary({
    required this.balance,
    required this.expense,
    required this.income,
  });

  @override
  State<expenseSummary> createState() => _expenseSummaryState();
}

class _expenseSummaryState extends State<expenseSummary> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('S E T  L I M I T',
                  style: TextStyle(color: Colors.grey[500], fontSize: 16)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Expanded(
                    // child: 
                    Center(
                      child: Text(
                        '\₹' + widget.balance,
                        style: TextStyle(color: Colors.grey[800], fontSize: 40),
                      ),
                    // ),
                  ),
                  IconButton(
                    
                      onPressed: () async {
                        final text = await openPopup(context);

                        if (text != null) {
                          var converted = double.parse(text);
                          //print('converted:  $converted');
                          Provider.of<DataModel>(context, listen: false)
                              .updateDataList([],[], converted);
                        }
                      },
                      icon: Icon(
                        Icons.edit,
                        ),
                      )
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[200],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.arrow_downward,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Income',
                                style: TextStyle(color: Colors.grey[500])),
                            SizedBox(
                              height: 5,
                            ),
                            Text('\₹' + widget.income,
                                style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold)),
                          ],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[200],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.arrow_upward,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Expense',
                                style: TextStyle(color: Colors.grey[500])),
                            SizedBox(
                              height: 5,
                            ),
                            Text('\₹' + widget.expense,
                                style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold)),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.grey[300],
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.shade500,
                  offset: Offset(4.0, 4.0),
                  blurRadius: 15.0,
                  spreadRadius: 1.0),
              BoxShadow(
                  color: Colors.white,
                  offset: Offset(-4.0, -4.0),
                  blurRadius: 15.0,
                  spreadRadius: 1.0),
            ]),
      ),
    );
  }

  Future<String?> openPopup(BuildContext context) {
    return showDialog<String?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('SET LIMIT'),
          content: TextField(
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            controller: controller,
            decoration: InputDecoration(hintText: 'Set your limit'),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(controller.text);
                },
                child: Text('SUBMIT'))
          ],
        );
      },
    );
  }
}
