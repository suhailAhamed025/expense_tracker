import 'package:expense_tracker/data_model.dart';
import 'package:flutter/material.dart';
import "home.dart";
import 'bar graph/report.dart';
import 'package:provider/provider.dart';

//<uses-permission android:name="android.permission.READ_SMS" />

void main() {
  runApp( 
     MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (_)=>DataModel()),
     // ChangeNotifierProvider(create: (_)=>)
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

     int _selectedIndex = 0;

  // Defining pages
  List<Widget> _pages = [
    //  pages
    Container(child: HomePage()),
    Container( child: Report()),
  ];
   
       
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
      //function to calculate the total amount
    
    return  Scaffold(
        backgroundColor: Colors.grey[300],
        // appBar: AppBar(
        //   backgroundColor: Colors.blue.shade400,
        //   title: Text(
        //     'E X P E N S E  T R A C K E R'
        //   ),

        // ),
        body: SafeArea(
          child: _pages[_selectedIndex],
          
        ),
          
          
        
        bottomNavigationBar:BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home'
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.report),
                label: "report"
                )
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          onTap: _onItemTapped,
          )
        
      );
    
  }

  void _onItemTapped(int index)=>{
      setState(() {
        _selectedIndex=index;
      }),
  };
    
}
