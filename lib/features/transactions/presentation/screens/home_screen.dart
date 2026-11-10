import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../auth/presentation/auth_providers.dart';
import '../formatters.dart';
import '../load_error_message.dart';
import '../transaction_icons.dart';
import '../transaction_providers.dart';
import '../../domain/transaction_status.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionListProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F7),
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.teal),
            tooltip: 'Sign out',
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
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
                      context.push(
                        AppRoutes.gallery("Identification Documents"),
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
                            Icon(Icons.badge, size: 32, color: Colors.teal),
                            const SizedBox(height: 8),
                            Text(
                              "Identification Documents",
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
                      context.push(AppRoutes.gallery("Vehicle Sale Deeds"));
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
                            Text(
                              "Vehicle Sale Deeds",
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
                      context.push(AppRoutes.gallery("Sale Power of Attorney"));
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
                            Icon(Icons.draw, size: 32, color: Colors.teal),
                            const SizedBox(height: 8),
                            Text(
                              "Sale Power of Attorney",
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
                      context.push(
                        AppRoutes.gallery("Special/General Power of Attorney"),
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
                            Icon(Icons.gavel, size: 30, color: Colors.teal),
                            const SizedBox(height: 8),

                            Text(
                              "Special/General Power of Attorney",
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
                      context.push(AppRoutes.gallery("Police Reports"));
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
                            Text(
                              "Police Reports",
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
                      context.push(
                        AppRoutes.gallery("Inheritance Certificates"),
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

                            Text(
                              "Inheritance Certificates",
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
                      context.push(AppRoutes.gallery("Lien Release"));
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
                            Icon(Icons.lock_open, size: 32, color: Colors.teal),
                            const SizedBox(height: 8),

                            Text(
                              "Lien Release",
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
                      context.push(
                        AppRoutes.gallery("Vehicle Scrap Certificate"),
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
                            const SizedBox(height: 8),
                            Icon(
                              Icons.delete_forever,
                              size: 32,
                              color: Colors.teal,
                            ),
                            const SizedBox(height: 8),

                            Text(
                              "Vehicle Scrap Certificate",
                              style: TextStyle(fontSize: 11),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      context.push(AppRoutes.gallery("Other"));
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
                            Text(
                              "Other",
                              style: TextStyle(fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search transactions...",
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: Colors.teal),

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
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add, color: Colors.teal),
                ),
              ],
            ),
          ),

          SizedBox(height: 5),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 16),

              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),

                child: transactions.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        loadErrorMessage(
                          error,
                          fallback: 'Could not load transactions',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  data: (transactions) => transactions.isEmpty
                      ? Center(
                          child: Text(
                            'No transactions yet',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        )
                      : ListView.builder(
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            final t = transactions[index];
                            final isCompleted =
                                t.status == TransactionStatus.completed;

                            return ListTile(
                              onTap: () {
                                context.push(AppRoutes.transaction(t.id));
                              },
                              leading: Icon(t.type.icon, color: Colors.teal),
                              title: Text(t.clientName),
                              subtitle: Text(
                                isCompleted && t.dateCompleted != null
                                    ? 'Completed on ${formatDate(t.dateCompleted!)}'
                                    : 'Pending since ${formatDate(t.dateReceived)}',
                              ),
                              trailing: Icon(
                                isCompleted
                                    ? Icons.check_circle
                                    : Icons.hourglass_empty,
                                color: isCompleted
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
