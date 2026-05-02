import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // make the whole app's Scaffold background this color
        scaffoldBackgroundColor: const Color(0xFFF2F2F7),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF2F2F7)),
      ),
      home: const MyHomePage(title: 'Home'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F7),
        title: Text(title),
      ),


      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 20),

          const Padding(
           padding: EdgeInsets.only(left: 16),
            child: Text("Quick Access"),
            ),

          const SizedBox(height: 10),
          
          Padding(
           padding: const EdgeInsets.symmetric(horizontal: 5),
           child: SizedBox(
            height: 120,
           child: ListView(
            scrollDirection: Axis.horizontal,
           children: <Widget>[
            Card(
              shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(16),
                ),
               child: Container(
               width: 100,
               height: 100,
               decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                ),
                child: Column(  
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 
                 Icon(
                    Icons.badge,
                    size: 32,
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 8),
                 Text("Identification Documents",
                 style: TextStyle(fontSize: 12),
                 textAlign: TextAlign.center,
                 ),
                ],
                ),
                ),
            ),
            //const SizedBox(width: 10),
            Card(
              shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(16),
                ),
               child: Container(
               width: 100,
               height: 100,
               decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                ),
                child: Column(  
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 Icon(
                  Icons.description,
                  size: 32,
                  color: Colors.teal,
                ),
                  const SizedBox(height: 8),
                 Text("Vehicle Sale Deeds",
                 style: TextStyle(fontSize: 12),
                 textAlign: TextAlign.center,
                 ),
                ],
                ),
                ),
            ),
            //const SizedBox(width: 10),
            Card(
              shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(16),
                ),
               child: Container(
               width: 100,
               height: 100,
               decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                ),
                child: Column(  
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 
                 Icon(
                    Icons.draw,
                    size: 32,
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 8),
                 Text("Sale Power of Attorney",
                 style: TextStyle(fontSize: 12),
                 textAlign: TextAlign.center,
                 ),
                ],
                ),
                ),
            ),
            //const SizedBox(width: 10),
            Card(
              shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(16),
                ),
               child: Container(
               width: 100,
               height: 100,
               decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                ),
                child: Column(  
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 7),
                 Icon(
                    Icons.gavel,
                    size: 30,
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 8),

                 Text("Special/General Power of Attorney",
                 style: TextStyle(fontSize: 11),
                 textAlign: TextAlign.center,
                 ),

                ],
                ),
                ),
            ),
            Card(
              shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(16),
                ),
               child: Container(
               width: 100,
               height: 100,
               decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                ),
                child: Column(  
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 
                 Icon(
                    Icons.local_police,
                    size: 32,
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 8),
                 Text("Police Reports",
                 style: TextStyle(fontSize: 12),
                 textAlign: TextAlign.center,
                 ),
                ],
                ),
                ),
            ),


            Card(
              shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(16),
                ),
               child: Container(
               width: 100,
               height: 100,
               decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                ),
                child: Column(  
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 const SizedBox(height: 17),
                 Icon(
                    Icons.family_restroom,
                    size: 32,
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 8),

                 Text("Inheritance Certificates",
                 style: TextStyle(fontSize: 12),
                 textAlign: TextAlign.center,
                 ),
                ],
                ),
                ),
            ),


            Card(
              shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(16),
                ),
               child: Container(
               width: 100,
               height: 100,
               decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                ),
                child: Column(  
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 const SizedBox(height: 7),
                 Icon(
                  Icons.lock_open,
                  size: 32,
                   color: Colors.teal,
                 ),
                  const SizedBox(height: 8),
                 
                 Text("Lien Release",
                 style: TextStyle(fontSize: 12),
                 textAlign: TextAlign.center,
                 ),
                ],
                ),
                ),
            ),

            Card(
              shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(16),
                ),
               child: Container(
               width: 100,
               height: 100,
               decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                ),
                child: Column(  
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                 const SizedBox(height: 17),
                 Icon(
                    Icons.delete_forever,
                    size: 32,
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 8),
                 
                 Text("Vehicle Scrap Certificate",
                 style: TextStyle(fontSize: 11),
                 textAlign: TextAlign.center,
                 ),
                ],
                ),
                ),
            ),

            Card(
              shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(16),
                ),
               child: Container(
               width: 100,
               height: 100,
               decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                ),
                child: Column(  
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  Icon(
                    Icons.more_horiz,
                    size: 32,
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 8),
                 Text("Other",
                 style: TextStyle(fontSize: 12),
                 textAlign: TextAlign.center,
                 ),
                ],
                ),
                ),
            ),



          ]

          ),
          ),
          ),

          const SizedBox(height: 20), 
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child:Row(
              children: [
                Expanded(
               child: TextField(
                decoration: InputDecoration(
                  hintText: "Search transactions...",
                  hintStyle: TextStyle(
                    color: Colors.grey,           
                    fontSize: 14,                 
                  ),
                  prefixIcon: const Icon(Icons.search ,color: Colors.teal,),

                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
                ),
                const SizedBox(width: 2),

                
                Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                color: Colors.white,
                shape:BoxShape.circle,
                ),
                child: Icon(Icons.add, color: Colors.teal),
                ),
                   
              ],
            ),
           ),


            SizedBox(height:25),

            Padding(
           padding: const EdgeInsets.symmetric(horizontal: 23),
           
           child: Container(
            
            decoration: BoxDecoration(
             color: Colors.white,
             borderRadius: BorderRadius.circular(16),
            ),
            child: SizedBox(
             height: 255,
           child: ListView(
            scrollDirection: Axis.vertical,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.local_taxi, color: Colors.teal),
                title: Text("Test User 1"),
                subtitle: Text("Completed on 2024-05-15"),
                trailing: Icon(Icons.check_circle, color: Colors.green),
              ),
              ListTile(
                leading: Icon(Icons.card_membership, color: Colors.teal),
                title: Text("Test User 2"),
                subtitle: Text("Pending since 2024-06-01"),
                trailing: Icon(Icons.hourglass_empty, color: Colors.orange),
              ),
              ListTile(
                leading: Icon(Icons.lock_open, color: Colors.teal),
                title: Text("Test User 3"),
                subtitle: Text("Completed on 2024-04-20"),
                trailing: Icon(Icons.check_circle, color: Colors.green),
              ),
              ListTile(
                leading: Icon(Icons.directions_car, color: Colors.teal),
                title: Text("Test User 4"),
                subtitle: Text("Pending since 2024-05-30"),
                trailing: Icon(Icons.hourglass_empty, color: Colors.orange),
              ),
              ListTile(
                leading: Icon(Icons.swap_horiz, color: Colors.teal),
                title: Text("Test User 5"),
                subtitle: Text("Pending since 2024-05-30"),
                trailing: Icon(Icons.hourglass_empty, color: Colors.orange),
              ),
           ]
           )
           )
           )
            ),
        ],
        
      ),
       

    );
  }
}


