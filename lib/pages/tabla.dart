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
import 'package:charts_flutter/flutter.dart' as charts;

class Tabla extends StatefulWidget {
  String nombre;
  String invernadero;
  String planta;
  Colors color;
  String cm;

  Tabla(this.nombre, this.invernadero, this.planta, this.cm);
  @override
  _TablaState createState() => _TablaState(nombre, invernadero, planta, cm);
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
  List<charts.Series> charproduc;
  String cm;
  String tipo = "ls";

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

  _TablaState(this.nombre, this.invernadero, this.planta, this.cm);
  @override
  void initState() {
    obtener();
    setState(() {
      if (!listaproduc.isEmpty) carga = false;
    });
    super.initState();
  }

  Future<Null> createchart() async {
    for (var i in listaproduc) {
      // charproduc.add(Sales(i.producto, i.total));
    }
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
        'tabla': cm,
        'tipo': tipo
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

  all() {
    return Container(
      child: Column(
        children: <Widget>[
          Center(
              child: Row(
            children: <Widget>[
              RaisedButton(
                child: Text("Liquidos"),
                color: Colors.green,
                splashColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                onPressed: () {
                  setState(() {
                    tipo = "Liquido";
                    obtener();
                  });
                },
              ),
              RaisedButton(
                child: Text("Solidos"),
                color: Colors.green,
                splashColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                onPressed: () {
                  setState(() {
                    tipo = "Solido";
                    obtener();
                  });
                },
              ),
              RaisedButton(
                child: Text("Ambos"),
                color: Colors.green,
                splashColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                onPressed: () {
                  setState(() {
                    tipo = "ls";
                    obtener();
                  });
                },
              ),
            ],
          )),
          table()
        ],
      ),
    );
  }

  table() {
    return Container(
        margin: EdgeInsets.all(25),
        width: MediaQuery.of(context).size.width * 2,
        height: MediaQuery.of(context).size.height * .75,
        // padding: EdgeInsets.only(top: 5, left: 5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 5,
              ),
            ]),
        child: Container(
            margin: EdgeInsets.all(6),
            color: Colors.black45,
            //width: MediaQuery.of(context).size.width * 2,
            //height: MediaQuery.of(context).size.height * .75,

            child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                        dividerThickness: 2,
                        dataRowHeight: 25,
                        columnSpacing: 10,
                        headingRowHeight: 45,
                        horizontalMargin: 5,
                        columns: const <DataColumn>[
                          DataColumn(
                            label: Text(
                              'Id_producto',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          DataColumn(
                            tooltip: "go",
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
                            (index) => _getDataRow(listaproduc[index])))))));
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
          child: carga ? Center(child: CircularProgressIndicator()) : all(),
        ));
    // child: Text("data"),
  }
}
