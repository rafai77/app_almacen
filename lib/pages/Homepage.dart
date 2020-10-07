import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:app_almacen/Constantes/Constantesback.dart';
import 'package:app_almacen/Constantes/EndPoints.dart';
import 'package:app_almacen/Model/Productos.dart';
import 'package:app_almacen/pages/LoginPage.dart';
import 'package:app_almacen/pages/tabla.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String mensaje = "";
  bool conexion = false;
  List<Productos> listaproduc = List<Productos>();
  String result = "Sin datos";

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

  tabla() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var response;
    var conecctionResult = await Connectivity().checkConnectivity();
    if (conecctionResult != ConnectivityResult.none) {
      conexion = true;
      print(sharedPreferences.getString('tk')); // 192.168.1.135
      var hd = {'vefificador': sharedPreferences.getString('tk')};
      var body = {
        // cambiar tabla por algo dinamico
        'tabla': "inventario",
        'tipo': 'ls'
      };
      response = await http.post(EndPoints.datos, headers: hd, body: body);
      // try {
      //   response = await http.post(EndPoints.datos, headers: hd, body: body);
      //   // .timeout(const Duration(seconds: 7));
      // } on TimeoutException catch (_) {
      //   setState(() {
      //     mensaje = 'Sin conexion al servidor\n';
      //     _showMyDialog();
      //   });
      //   throw ('Sin conexion al servidor');
      // } on SocketException {
      //   setState(() {
      //     throw ('Sin internet  o falla de servidor ');
      //   });
      // } on HttpException {
      //   throw ("No se encontro esa peticion");
      // } on FormatException {
      //   throw ("Formato erroneo ");
      // }
      var data = json.decode(response.body);
      listaproduc = [];
      int j = 0;

      //listaproduc = data.cast<List<Productos>>();
      for (var i in data) {
        listaproduc.add(Productos((i['id_producto']), i['producto'], i['total'],
            i['tipo'], i['unidad']));
      }
    } // tiene conexion :)
    else // no tiene conexion
    {
      conexion = false;
    }
  }

  targeta(nombre, invernaderos, planta, color) {
    return Container(
        color: Colors.white,
        padding: EdgeInsets.only(
            top: 10, left: MediaQuery.of(context).size.height * .02),
        child: Container(
          height: MediaQuery.of(context).size.height * .2,
          width: MediaQuery.of(context).size.width * .9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            color: Colors.black87,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.8),
                spreadRadius: 10,
                blurRadius: 5,
                offset: Offset(0, 7),
              )
            ],
          ),
          child: Column(
            children: <Widget>[
              Divider(
                thickness: 3.5,
                indent: 4,
                endIndent: 4,
                color: color,
                height: MediaQuery.of(context).size.height * .05,
              ),
              Center(
                  child: Text(nombre,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ))),
              Icon(
                Icons.insert_chart,
                color: color,
                size: 24.0,
              ),
              Text("Invernaderos: " + invernaderos,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  )),
              Text("Planta: " + planta,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  )),
            ],
          ),
        ));
  }

  targetas() {
    return Row(
      children: <Widget>[
        Column(
          children: <Widget>[
            Center(
              heightFactor: 1.2,
              child: Card(
                child: InkWell(
                  splashColor: Colors.blue.withAlpha(35),
                  child: targeta("Almacen general", "", '', Colors.white),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Tabla(
                                "Almacen general", "", '', "inventario")));
                  },
                ),
              ),
            ),
            Center(
              child: Card(
                child: InkWell(
                  splashColor: Colors.blue.withAlpha(30),
                  child: targeta(
                    "Cuarto de maquinas 1-Pimiento",
                    "(1,2,3,4)",
                    "Pimiento",
                    Colors.green,
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Tabla("Almacen general", "", '', "cm1")));
                  },
                ),
              ),
            ),
            Center(
              child: Card(
                child: InkWell(
                  splashColor: Colors.blue.withAlpha(30),
                  child: targeta("Cuarto de maquinas 2-3-Pimiento", "(5,6,7,8)",
                      "Pimiento", Colors.green),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Tabla("Almacen general", "", '', "cm2")));
                  },
                ),
              ),
            ),
            Center(
              child: Card(
                child: InkWell(
                  splashColor: Colors.blue.withAlpha(30),
                  child: targeta("Cuarto de maquinas 4-Tomate", "(11,12)",
                      "Tomate", Colors.red),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Tabla("Almacen general", "", '', "cm4_t")));
                  },
                ),
              ),
            ),
            Center(
              child: Card(
                child: InkWell(
                  splashColor: Colors.blue.withAlpha(30),
                  child: targeta("Cuarto de maquinas 4-Pmiento", "(11,12)",
                      "Tomate", Colors.green),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Tabla("Almacen general", "", '', "cm4_p")));
                  },
                ),
              ),
            ),
            Center(
              child: Card(
                child: InkWell(
                  splashColor: Colors.blue.withAlpha(30),
                  child: targeta("Cuarto de maquinas 5-Tomate", "(13,14)",
                      "Tomate", Colors.red),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Tabla("Almacen general", "", '', "cm5")));
                  },
                ),
              ),
            ),
            Center(
              child: Card(
                child: InkWell(
                  splashColor: Colors.blue.withAlpha(30),
                  child: targeta("Cuarto de maquinas 6-Pimiento", "(17,18)",
                      "Tomate", Colors.green),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Tabla("Almacen general", "", '', "cm6_p")));
                  },
                ),
              ),
            ),
            Center(
              child: Card(
                child: InkWell(
                  splashColor: Colors.blue.withAlpha(30),
                  child: targeta("Cuarto de maquinas 6-Tomate", "(15,16)",
                      "Tomate", Colors.red),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Tabla("Almacen general", "", '', "cm6_t")));
                  },
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  traspasos() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var response;
    print(sharedPreferences.getString('tk')); // 192.168.1.135
    var hd = {'vefificador': sharedPreferences.getString('tk')};
    var body = {
      // cambiar tabla por algo dinamico
      'datos': result,
    };
    response = await http.post(EndPoints.traspaso, headers: hd, body: body);
    print(response);
  }

  Future<void> scanear() async {
    try {
      ScanResult barcode = (await BarcodeScanner.scan());
      setState(() {
        result = barcode.rawContent;
        print(result);
        traspasos();
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          result = 'El usuario no dio permiso para el uso de la cámara!';
        });
      } else {
        setState(() => result = 'Error desconocido $e');
      }
    } on FormatException {
      setState(() => result =
          'nulo, el usuario presionó el botón de volver antes de escanear algo)');
    } catch (e) {
      setState(() => result = 'Error desconocido : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
          child: Column(
        children: [
          targetas(),
          FloatingActionButton(child: Icon(Icons.camera), onPressed: scanear),
          Text(result),
        ],
      )),
    );
  }
}
