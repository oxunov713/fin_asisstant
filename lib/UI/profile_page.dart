import 'package:flutter/material.dart';
import 'package:my_fin_asisstant/UI/cards_page.dart';

import 'biometric_auth.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profil')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20),
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(
                'https://upload.wikimedia.org/wikipedia/commons/thumb/9/92/BillieEilishO2160622_%2819_of_45%29_%2852153214339%29_%28cropped_3%29.jpg/1200px-BillieEilishO2160622_%2819_of_45%29_%2852153214339%29_%28cropped_3%29.jpg',
              ), // Foydalanuvchi avatari
            ),
            SizedBox(height: 10),
            Text(
              'Azizbek Oxunov',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),

            // Asosiy funksiyalar - Bankka xos
            Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: <Widget>[

                  _buildListTile(
                    context,
                    Icons.credit_card_outlined,
                    'Kartalarim',
                        () {
                     Navigator.push(context, MaterialPageRoute(builder: (context) => CardsPage(),));
                    },
                  ),
                  Divider(height: 1),

                ],
              ),
            ),

            // Xavfsizlik sozlamalari - Bank uchun muhim
            Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Xavfsizlik',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Divider(height: 1),
                  _buildListTile(
                    context,
                    Icons.fingerprint_outlined,
                    'Biometrik Kirish',
                        () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => BiometricAuthScreen(),));
                    },
                  ),
                  Divider(height: 1),
                  _buildListTile(
                    context,
                    Icons.lock_outline,
                    'Parolni O\'zgartirish',
                        () {
                      // Parolni o'zgartirish sahifasiga o'tish
                      print('Parolni O\'zgartirish bo\'limi bosildi');
                    },
                  ),
                  Divider(height: 1),
                  _buildListTile(
                    context,
                    Icons.security_outlined,
                    'Xavfsizlik Sozlamalari',
                        () {
                      // Umumiy xavfsizlik sozlamalariga o'tish
                      print('Xavfsizlik Sozlamalari bo\'limi bosildi');
                    },
                  ),
                ],
              ),
            ),



            // Yordam
            Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: _buildListTile(context, Icons.help_outline, 'Yordam', () {
                // Yordam sahifasiga o'tish
                print('Yordam bo\'limi bosildi');
              }),
            ),

            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                // Chiqish logikasi
                print('Chiqish tugmasi bosildi');
              },
              child: Text('Chiqish', style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context,
      IconData icon,
      String title,
      VoidCallback onTap,) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue[700]),
      title: Text(title),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }
}
