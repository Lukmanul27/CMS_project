import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cmsapp/widget/widget_admin/sidebar_admin.dart';
import 'package:cmsapp/widget/widget_admin/custom_appbar.dart';

class ReservasiScreen extends StatefulWidget {
  const ReservasiScreen({Key? key}) : super(key: key);

  @override
  State<ReservasiScreen> createState() => _ReservasiScreenState();
}

class _ReservasiScreenState extends State<ReservasiScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to fetch reservations from Firestore
  Stream<QuerySnapshot> _fetchReservations() {
    return _firestore
        .collection('penyewaan')
        .orderBy('timestamp', descending: true) // Sort by timestamp field
        .snapshots();
  }

  // Function to update reservation status
  Future<void> _updateStatus(String id, String status) async {
    try {
      await _firestore.collection('penyewaan').doc(id).update({
        'status': status,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to $status')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e')),
      );
    }
  }

  // Function to view payment proof
  Future<void> _viewProof(String fileUrl) async {
    if (await canLaunch(fileUrl)) {
      await launch(fileUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open payment proof')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: CustomDrawer(),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4CAF50), // Green shade for soccer field
              Color(0xFF388E3C), // Darker green shade for contrast
              Color(0xFF1B5E20), // Even darker green shade for depth
            ],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _fetchReservations(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No reservations found'));
            }

            // Group reservations by status
            Map<String, List<DocumentSnapshot>> groupedReservations = {};
            snapshot.data!.docs.forEach((doc) {
              var data = doc.data() as Map<String, dynamic>;
              String status = data['status'] ?? 'Unknown';

              if (!groupedReservations.containsKey(status)) {
                groupedReservations[status] = [];
              }
              groupedReservations[status]!.add(doc);
            });

            return ListView.builder(
              itemCount: groupedReservations.length,
              itemBuilder: (context, index) {
                var status = groupedReservations.keys.elementAt(index);
                var reservations = groupedReservations[status]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        'Status: $status',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: reservations.length,
                      itemBuilder: (context, idx) {
                        var data =
                            reservations[idx].data() as Map<String, dynamic>;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(
                              data['nama'] ?? 'No name',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Status: ${data['status'] ?? 'No status'}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.check_circle,
                                      color: Colors.green),
                                  onPressed: () => _updateStatus(
                                      reservations[idx].id, 'Accepted'),
                                ),
                                IconButton(
                                  icon: Icon(Icons.cancel, color: Colors.red),
                                  onPressed: () => _updateStatus(
                                      reservations[idx].id, 'Rejected'),
                                ),
                              ],
                            ),
                            onTap: () => _showDetailDialog(data),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Function to show reservation details in a dialog
  void _showDetailDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reservation Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Name', data['nama'] ?? 'No name'),
                _buildDetailRow('Address', data['alamat'] ?? 'No address'),
                _buildDetailRow('Time', data['waktu'] ?? 'No time'),
                _buildDetailRow('Start Time', data['mulai'] ?? 'No start time'),
                _buildDetailRow('End Time', data['berakhir'] ?? 'No end time'),
                _buildDetailRow('Price', 'Rp. ${data['harga'] ?? 'No price'}'),
                _buildDetailRow('Status', data['status'] ?? 'No status'),
                if (data['file_url'] != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      onPressed: () => _viewProof(data['file_url']),
                      child: Text('View Payment Proof'),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
