import 'package:app_almacen/pages/Homepage.dart';
import 'package:app_almacen/pages/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(Almacenapp());
}

class Almacenapp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  SharedPreferences sharedPreferences;
  String mensaje = "";

  logg() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("tk") == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext contex) => LoginPage()),
          (Route<dynamic> router) => false);
    }
  }

  @override
  void initState() {
    logg();
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("ERROR"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('ERROR.'),
                Text(mensaje),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Almacen H-Cimarron'), backgroundColor: Colors.indigo),
      body: Homepage(),
    );
  }
}
//(title: 'Almacen H-Cimarron'
