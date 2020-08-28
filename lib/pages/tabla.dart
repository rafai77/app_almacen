import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:app_almacen/Constantes/Constantesback.dart';
import 'package:app_almacen/Constantes/EndPoints.dart';
import 'package:app_almacen/Model/Productos.dart';
import 'package:app_almacen/pages/LoginPage.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Tabla extends StatefulWidget {
  String nombre;
  String invernadero;
  String planta;
  Colors color;

  Tabla(
    this.nombre,
    this.invernadero,
    this.planta,
  );
  @override
  _TablaState createState() => _TablaState(
        nombre,
        invernadero,
        planta,
      );
}

class _TablaState extends State<Tabla> {
  String nombre;
  String invernadero;
  String planta;
  Colors color;
  String mensaje = "";
  List<Productos> listaproduc = List<Productos>();
  bool conexion = false;
  bool carga = true;
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

  _TablaState(this.nombre, this.invernadero, this.planta);
  @override
  void initState() {
    obtener();
    setState(() {
      if (!listaproduc.isEmpty) carga = false;
    });
    super.initState();
  }

  Future<Null> obtener() async {
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
      carga = false;
      setState(() {
        if (!listaproduc.isEmpty) carga = false;
      });
      print(listaproduc);
    } // tiene conexion :)
    else // no tiene conexion
    {
      conexion = false;
    }
  }

  table() {
    return Container(
        width: MediaQuery.of(context).size.width * .9,
        height: MediaQuery.of(context).size.height * .5,
        child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                    columns: const <DataColumn>[
                      DataColumn(
                        label: Text(
                          'Id_producto',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Producto',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Total',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'tipo',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Unidad',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                    rows: List.generate(listaproduc.length,
                        (index) => _getDataRow(listaproduc[index]))))));
  }

  DataRow _getDataRow(result) {
    //print(result.toString());
    return DataRow(
      cells: <DataCell>[
        DataCell(Text(result.id_producto)),
        DataCell(Text(result.producto)),
        DataCell(Text(result.total.toString())),
        DataCell(Text(result.tipo)),
        DataCell(Text(result.unidad)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.indigo,
          title: Center(child: Text(this.nombre)),
          actions: <Widget>[],
        ),
        body: Form(
          child: carga ? Center(child: CircularProgressIndicator()) : table(),
        ));
    // child: Text("data"),
  }
}
