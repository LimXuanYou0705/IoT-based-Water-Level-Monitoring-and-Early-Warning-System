import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String formatTimestamp(Timestamp timestamp) {
  final dateTime = timestamp.toDate();
  final formatter = DateFormat('d MMMM, yyyy, h:mm a');
  return formatter.format(dateTime);
}