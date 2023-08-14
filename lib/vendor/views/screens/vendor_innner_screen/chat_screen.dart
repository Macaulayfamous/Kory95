import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../vendor_chat_screen.dart';

class VendorHomeChatScreen extends StatelessWidget {
  const VendorHomeChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
        .collection('chats')
        .where('sellerId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        // Add orderBy clause
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Messages',
          style: TextStyle(
            color: Colors.black,
            letterSpacing: 6,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No Messages',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 5,
                ),
              ),
            );
          }
          Map<String, String> lastProductByBuyerId = {};

          return ListView.builder(
            padding: EdgeInsets.all(8.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot document = snapshot.data!.docs[index];
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              String message = data['message'].toString();
              String senderId = data['senderId'].toString();
              String productId = data['productId'].toString();

              // Check if the message is from the seller
              bool isSellerMessage =
                  senderId == FirebaseAuth.instance.currentUser!.uid;

              if (!isSellerMessage) {
                String key = senderId + '_' + productId;
                if (!lastProductByBuyerId.containsKey(key)) {
                  lastProductByBuyerId[key] = productId;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VendorChatPage(
                            sellerId: FirebaseAuth.instance.currentUser!.uid,
                            buyerId: senderId,
                            productId: productId,
                            data: data,
                          ),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(data['buyerPhoto']),
                      ),
                      title: Text(message),
                      subtitle: Text('Sent by Buyer'),
                    ),
                  );
                }
              }

              return SizedBox
                  .shrink(); // Hide duplicate or non-matching messages
            },
          );
        },
      ),
    );
  }
}
