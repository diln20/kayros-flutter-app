import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kayros/screens/description.dart';
import 'package:intl/intl.dart';
class Paquetes extends StatefulWidget {
  

  @override
  State<Paquetes> createState() => _PaquetesState();
}

class _PaquetesState extends State<Paquetes> {
   String uid = '';
  @override
  void initState() {
    getuid();
    super.initState();
  }

  getuid() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;
    setState(() {
      uid = user.uid;
    });
  }
  @override
  Widget build(BuildContext context) {
    return   Scaffold(
      body: Container(
        padding: EdgeInsets.all(10),
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('paquetes')
              .doc(uid)
              .collection('mispaquetes')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              final docs = snapshot.data.documents;

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  var time = (docs[index]['timestamp'] as Timestamp).toDate();

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Description(
                                    title: docs[index]['title'],
                                    description: docs[index]['description'],
                                  )));
                    },
                    child: Container(
                    //  color: Colors.white,
                      margin: EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                          color: Color( 0xffff4e4e),
                          borderRadius: BorderRadius.circular(10)),
                      height: 90,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                    margin: EdgeInsets.only(left: 20),
                                    child: Text(docs[index]['title'],
                                        style:
                                            GoogleFonts.roboto(fontSize: 20))),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                    margin: EdgeInsets.only(left: 20),
                                    child: Text(
                                        DateFormat.yMd().add_jm().format(time)))
                              ]),
                          Container(
                              
                              child: IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                  ),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('paquetes')
                                        .doc(uid)
                                        .collection('mispaquetes')
                                        .doc(docs[index]['time'])
                                        .delete();
                                  }))
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
        // color: Colors.red,
      ),
    );
  }
}
