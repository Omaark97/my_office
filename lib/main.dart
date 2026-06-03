import 'package:flutter/material.dart';
import 'document_gallery_page.dart';
import 'transaction_detail_page.dart';

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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {

  List<Map<String, dynamic>> transactions = [
  {
    'icon': Icons.local_taxi,
    'type': 'Public Taxi Registration',
    'client': 'Test User 1',
    'dateReceived': '2024-05-15',
    'dateCompleted': '2024-05-15',
    'status': 'Completed',
  },
  {
    'icon': Icons.card_membership,
    'type': "Driver's License Renewal",
    'client': 'Test User 2',
    'dateReceived': '2024-06-01',
    'dateCompleted': '',
    'status': 'Pending',
  },
  {
    'icon': Icons.lock_open,
    'type': 'Lien Release',
    'client': 'Test User 3',
    'dateReceived': '2024-04-15',
    'dateCompleted': '2024-04-20',
    'status': 'Completed',
  },
  {
    'icon': Icons.directions_car,
    'type': 'Private Car Ownership Transfer',
    'client': 'Test User 4',
    'dateReceived': '2024-05-30',
    'dateCompleted': '',
    'status': 'Pending',
  },
  {
    'icon': Icons.swap_horiz,
    'type': 'Public Taxi Registration',
    'client': 'Test User 5',
    'dateReceived': '2024-05-30',
    'dateCompleted': '',
    'status': 'Pending',
  },
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F7),
        title: Text(widget.title),
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
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DocumentGalleryPage(
                      title: "Identification Documents",
                      imageUrls: [],
                    ),
                  ),
                );
              },
            child: Card(
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
           ),
            //const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DocumentGalleryPage(
                      title: "Vehicle Sale Deeds",
                      imageUrls: [],
                    ),
                  ),
                );
              },
            child: Card(
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
           ),
            //const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DocumentGalleryPage(
                      title: "Sale Power of Attorney",
                      imageUrls: [],
                    ),
                  ),
                );
              },
            child: Card(
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
            ),
            //const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DocumentGalleryPage(
                      title: "Special/General Power of Attorney",
                      imageUrls: [],
                    ),
                  ),
                );
              },
            child: Card(
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
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DocumentGalleryPage(
                      title: "Police Reports",
                      imageUrls: [],
                    ),
                  ),
                );
              },
            child: Card(
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
            ),
             GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DocumentGalleryPage(
                      title: "Inheritance Certificates",
                      imageUrls: [],
                    ),
                  ),
                );
              },
            child: Card(
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
             ),
              GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DocumentGalleryPage(
                      title: "Lien Release",
                      imageUrls: [],
                    ),
                  ),
                );
              },
            child: Card(
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
              ),
              GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DocumentGalleryPage(
                      title: "Vehicle Scrap Certificate",
                      imageUrls: [],
                    ),
                  ),
                );
              },
            child: Card(
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
              ),

              GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DocumentGalleryPage(
                      title: "Other",
                      imageUrls: [],
                    ),
                  ),
                );
              },
    
             child: Card(
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


            SizedBox(height:5),
             Expanded(
            child :Padding(
           padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 16),
           
           child: Container(
            
            decoration: BoxDecoration(
             color: Colors.white,
             borderRadius: BorderRadius.circular(16),
            ),
          
           child: ListView.builder(
  itemCount: transactions.length,
  itemBuilder: (context, index) {
    final t = transactions[index];
    
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionDetailPage(
              clientName: t['client'],
              transactionType: t['type'],
              status: t['status'],
              dateReceived: t['dateReceived'],
              dateCompleted: t['dateCompleted'],
              imageUrls: [],
            ),
          ),
        );
      },
      leading: Icon(t['icon'], color: Colors.teal),
      title: Text(t['client']),
      subtitle: Text(
        t['status'] == 'Completed'
            ? 'Completed on ${t['dateCompleted']}'
            : 'Pending since ${t['dateReceived']}',
      ),
      trailing: Icon(
        t['status'] == 'Completed' ? Icons.check_circle : Icons.hourglass_empty,
        color: t['status'] == 'Completed' ? Colors.green : Colors.orange,
      ),
    );
  },
),
           
           )

            ),
             ),
        ],
        
      ),
       

    );
  }
}
  


