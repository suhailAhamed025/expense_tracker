import 'package:expense_tracker/data_model.dart';
import 'package:fl_chart/fl_chart.dart' as fl_chart;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/home.dart';
import 'bar_data.dart';

class Report extends StatefulWidget {
  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
    BarData createBarData(Map<String, Map<String, double>> monthlyTotals) {
    List<BarChartData> barDataList = [];


   
    
    monthlyTotals.forEach((month, totals) {
      double totalExpense = totals['totalExpense'] ?? 0.0;
      double totalIncome = totals['totalIncome'] ?? 0.0;
      
      // x-axis labels are month 
     

      //  to calculate the y-values
      // double yValue = totalExpense - totalIncome;

      BarChartData barChartData = BarChartData(
        income: totalIncome,
        expense: totalExpense,
      );
    
      barDataList.add(barChartData);
    });

    return BarData(barData: barDataList);
  }



  @override
  Widget build(BuildContext context) {
  final myExpense = Provider.of<DataModel>(context).mydataList ;
  // num rodLimit = Provider.of<DataModel>(context).limit;
  //   double rodsLimit =rodLimit.toDouble();
  

   // Group transactions by month
  Map<String, List<TransactionalSms>> transactionsByMonth = {};

    // Function to get a list of month names
   List<String> getUniqueMonthNames(List<TransactionalSms> data) {
    Set<String> uniqueMonths = {};
    List<String> monthNames = [];

    data.forEach((sms) {
      DateTime smsDate = DateTime.parse(sms.date);
      String monthName = DateFormat.MMM().format(smsDate);

      if (!uniqueMonths.contains(monthName)) {
        uniqueMonths.add(monthName);
        monthNames.add(monthName);
      }
    });
    // print(uniqueMonths);
    // print(monthNames);

    return monthNames;
  }


  List<String> monthNames = getUniqueMonthNames(myExpense);
 

  

  myExpense.forEach((sms) {
  DateTime smsDate = DateTime.parse(sms.date);
  String monthKey = '${smsDate.year}-${smsDate.month}';

  if (!transactionsByMonth.containsKey(monthKey)) {
    transactionsByMonth[monthKey] = [];
  }

  transactionsByMonth[monthKey]!.add(sms);
});

// Calculate total expenses and income for each month
Map<String, Map<String, double>> monthlyTotals = {};
transactionsByMonth.forEach((month, transactions) {
  List<TransactionalSms> expenses = transactions.where((sms) => sms.content.contains("Dr")||sms.content.contains("debited")).toList();
  List<TransactionalSms> income = transactions.where((sms)=> sms.content.contains("Cr")||sms.content.contains("credited")).toList();
  double totalExpense = expenses.map((sms) => double.parse(sms.money)).fold(0, (sum, amount) => sum + amount);
  double totalIncome = income.map((sms) => double.parse(sms.money)).fold(0, (sum, amount) => sum + amount);
      
  // Storing totals in the monthlyTotals map
  monthlyTotals[month] = {
    'totalExpense': totalExpense,
    'totalIncome': totalIncome,
  
  };

   
});
   BarData myBarData = createBarData(monthlyTotals);

   fl_chart.SideTitles _bottomTitles(){
    return fl_chart.SideTitles(
      showTitles: true,
      getTitlesWidget: (value, meta){
        var index = value.toInt()<monthNames.length ? monthNames[value.toInt()] : "";
         return fl_chart.SideTitleWidget(child: Text(index), axisSide: meta.axisSide);
      }
    );
   }


   return Scaffold(
    backgroundColor: Colors.grey[300],
      
      body: SafeArea(
            child:Column(
             children:[ 
              Container(
                margin: EdgeInsets.only(bottom: 25, top:15 ),
                child: Text(
                  'Transactions In Last Six Months',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600]
                  ),
                ),
              ) ,
              Container(
                margin: EdgeInsets.only(bottom: 15),
                child: SizedBox( 
                  height: 300,
                 child: fl_chart.BarChart(
                fl_chart.BarChartData(
                  maxY: 100000,
                  minY: 0,
                  gridData: fl_chart.FlGridData(show: false),
                  borderData: fl_chart.FlBorderData(show: false),
                          
                  titlesData:  fl_chart.FlTitlesData(
                    show: true,
                    leftTitles:  const fl_chart.AxisTitles(
                      sideTitles: fl_chart.SideTitles(
                        showTitles: false,
                      )
                    ),
                    topTitles:  const fl_chart.AxisTitles(
                      sideTitles: fl_chart.SideTitles(
                        showTitles: false,
                      )
                    ),
                    rightTitles: const  fl_chart.AxisTitles(
                      sideTitles: fl_chart.SideTitles(
                        showTitles: false,
                      )
                    ),
                      bottomTitles: fl_chart.AxisTitles(
                        sideTitles: _bottomTitles()
                        
                      ),
                    ),
                  
                  barGroups: myBarData.barData.map(
                    (data) => fl_chart.BarChartGroupData(
                      x: myBarData.barData.indexOf(data),
                      barRods: [
                        fl_chart.BarChartRodData(toY: data.income,
                        color: Color.fromARGB(167, 33, 132, 56),
                        width: 15,
                        borderRadius: BorderRadius.circular(4),
                        backDrawRodData: fl_chart.BackgroundBarChartRodData(
                          show: true,
                          toY: 100000,
                          color: Colors.grey[200]
                        )
                        ),
                        fl_chart.BarChartRodData(toY: data.expense,
                        color: Color.fromARGB(209, 210, 6, 10),
                        width: 15,
                        borderRadius: BorderRadius.circular(4),
                        backDrawRodData: fl_chart.BackgroundBarChartRodData(
                          show: true,
                          toY: 100000,
                          color: Colors.grey[200]
                        )
                        )

                        ],
                    ),
                  ).toList(),
                ),
                            ),
                            ),
              ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: monthNames.length,
                itemBuilder: (context, index) {
                  var month = monthNames[index];
                  String monthKey = monthlyTotals.keys.elementAt(index);
                  Map<String, double> totals = monthlyTotals[monthKey]!;
                  return Card(
                    color: Colors.grey[200],
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: ListTile(
                      leading: Text(month,
                          style:TextStyle(fontSize: 15),
                      ),
                      title: Text("Expenses: ${totals['totalExpense']!-100}",
                              
                      ),
                      subtitle: Text("Income: ${totals['totalIncome']}"),
                      
                    ),
                  );
                }
                ),
              ),

          ]
      ),
      ),
      );   
  }
}
