// import "individualBar.dart";
class BarData{
  List<BarChartData> barData;
  
  BarData({
            required this.barData,
          });
}
class BarChartData {
  double income;
  double expense;

  BarChartData({
    required this.income,
    required this.expense,
  });
 }