import 'package:cloud_firestore/cloud_firestore.dart';

class OrderTrackingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ສ້າງອອເດີໃໝ່
  Future<String> createOrder({
    required String orderId,
    required double total,
    required String deliveryAddress,
    required String deliveryMethod,
    required String phoneNumber,
    required String note,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final orderData = {
        'orderId': orderId,
        'total': total,
        'deliveryAddress': deliveryAddress,
        'deliveryMethod': deliveryMethod,
        'phoneNumber': phoneNumber,
        'note': note,
        'items': items,
        'status': 'pending',
        'statusHistory': ['pending'],
        'createdAt': FieldValue.serverTimestamp(),
        'estimatedDeliveryTime': FieldValue.serverTimestamp(),
        'driverName': null,
        'driverPhone': null,
        'driverLatitude': null,
        'driverLongitude': null,
      };

      await _firestore.collection('orders').doc(orderId).set(orderData);
      return orderId;
    } catch (e) {
      throw Exception('ບໍ່ສາມາດສ້າງອອເດີໄດ້: $e');
    }
  }

  // ດຶງຂໍ້ມູນການຕິດຕາມອອເດີ
  Future<Map<String, dynamic>?> getOrderTracking(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();

      if (doc.exists) {
        final data = doc.data()!;
        return {
          'orderId': data['orderId'],
          'total': data['total'],
          'deliveryAddress': data['deliveryAddress'],
          'deliveryMethod': data['deliveryMethod'],
          'phoneNumber': data['phoneNumber'],
          'note': data['note'],
          'items': data['items'],
          'status': data['status'],
          'statusHistory': List<String>.from(data['statusHistory'] ?? []),
          'createdAt': data['createdAt'],
          'estimatedDeliveryTime': data['estimatedDeliveryTime'],
          'driverName': data['driverName'],
          'driverPhone': data['driverPhone'],
          'driverLatitude': data['driverLatitude'],
          'driverLongitude': data['driverLongitude'],
        };
      }
      return null;
    } catch (e) {
      throw Exception('ບໍ່ສາມາດດຶງຂໍ້ມູນການຕິດຕາມໄດ້: $e');
    }
  }

  // ອັບເດດສະຖານະອອເດີ
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      final docRef = _firestore.collection('orders').doc(orderId);

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        if (doc.exists) {
          final data = doc.data()!;
          final statusHistory = List<String>.from(data['statusHistory'] ?? []);

          if (!statusHistory.contains(status)) {
            statusHistory.add(status);
          }

          transaction.update(docRef, {
            'status': status,
            'statusHistory': statusHistory,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      throw Exception('ບໍ່ສາມາດອັບເດດສະຖານະໄດ້: $e');
    }
  }

  // ອັບເດດຂໍ້ມູນຄົນຂັບ
  Future<void> updateDriverInfo({
    required String orderId,
    required String driverName,
    required String driverPhone,
    double? latitude,
    double? longitude,
  }) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'driverName': driverName,
        'driverPhone': driverPhone,
        'driverLatitude': latitude,
        'driverLongitude': longitude,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('ບໍ່ສາມາດອັບເດດຂໍ້ມູນຄົນຂັບໄດ້: $e');
    }
  }

  // ດຶງລາຍການອອເດີທັງໝົດ
  Stream<List<Map<String, dynamic>>> getOrdersStream() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList());
  }

  // ດຶງຂໍ້ມູນການຕິດຕາມແບບ Real-time
  Stream<Map<String, dynamic>?> getOrderTrackingStream(String orderId) {
    return _firestore.collection('orders').doc(orderId).snapshots().map((doc) {
      if (doc.exists) {
        final data = doc.data()!;
        return {
          'orderId': data['orderId'],
          'total': data['total'],
          'deliveryAddress': data['deliveryAddress'],
          'deliveryMethod': data['deliveryMethod'],
          'phoneNumber': data['phoneNumber'],
          'note': data['note'],
          'items': data['items'],
          'status': data['status'],
          'statusHistory': List<String>.from(data['statusHistory'] ?? []),
          'createdAt': data['createdAt'],
          'estimatedDeliveryTime': data['estimatedDeliveryTime'],
          'driverName': data['driverName'],
          'driverPhone': data['driverPhone'],
          'driverLatitude': data['driverLatitude'],
          'driverLongitude': data['driverLongitude'],
        };
      }
      return null;
    });
  }
}
