import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_almacen/Constantes/Constantesback.dart';
import 'package:app_almacen/pages/Homepage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usert = TextEditingController();
  TextEditingController passt = TextEditingController();
  String mensaje = "";
  String usuario = "";
  bool loggin = false;

  login() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    print("entra a login");
    var response;
    print(Constant.DOMAIN + "/log");
    if (vefificarT()) {
      print("Datos completos");

      var body = {"user": usert.text, "pass": passt.text};

      try {
        response = await http
            .post(Constant.DOMAIN + "/log/", body: body)
            .timeout(const Duration(seconds: 5));
      } on TimeoutException catch (_) {
        loggin = false;
        setState(() {
          mensaje = 'Sin conexion al servidor';
          loggin = false;
          _showMyDialog();
        });
        throw ('Sin conexion al servidor');
      } on SocketException {
        setState(() {
          loggin = false;
          throw ('Sin internet  o falla de servidor ');
        });
      } on HttpException {
        throw ("No se encontro esa peticion");
      } on FormatException {
        throw ("Formato erroneo ");
      }
      //se pudo iniciar
      var data = json.decode(response.body);
      print(data['log']);
      if (data['log'] == true) {
        print("Ingreso");
        sharedPreferences.setInt("id", data['user']['id_user']);
        sharedPreferences.setString("rol", data['user']['rol']);
        sharedPreferences.setString("rol", data['user']['nombre']);
        sharedPreferences.setString("tk", data['user']['token']);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext contex) => Homepage()),
            (Route<dynamic> router) => false);
      } else {
        setState(() {
          loggin = false;
        });
      }
      setState(() {
        mensaje = "Usuario o contraseña mal";
        _showMyDialog();
        loggin = false;
      });
      print(data);
    } else {
      print("datos mal ");
      setState(() {
        mensaje = "Error en los datos";
        _showMyDialog();
        loggin = false;
      });
    }
  }

  vefificarT() {
    if (usert.text == "" || passt.text == "") {
      mensaje = "Introducir los datos";
      return false;
    }
    return true;
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

  all() {
    return Column(
      children: <Widget>[
        Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * .25,
              decoration: BoxDecoration(
                  image: DecorationImage(
                image: AssetImage("assets/images/Cimarron.png"),
              )),
              child: Stack(),
            ),
          ],
        ),
        Container(
            // para las cajas de texto
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width / 1.2,
            padding: EdgeInsets.only(top: 5),
            child: Column(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width / 1.2,
                  padding:
                      EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 5,
                        ),
                      ]),
                  child: TextFormField(
                    controller: usert,
                    decoration: InputDecoration(
                        labelText: "Usuario",
                        hintText: "Usuario",
                        icon: Icon(
                          Icons.account_circle,
                        )),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 60),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1.2,
                    padding:
                        EdgeInsets.only(top: 4, left: 14, right: 16, bottom: 4),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 5,
                          ),
                        ]),
                    child: TextFormField(
                      controller: passt,
                      obscureText: true,
                      decoration: InputDecoration(
                          labelText: "Contraseña",
                          hintText: "Contraseña",
                          suffixIcon: Icon(Icons.visibility),
                          icon: Icon(Icons.vpn_key)),
                    ),
                  ),
                ),
                Container(
                    padding: EdgeInsets.only(top: 50),
                    width: MediaQuery.of(context).size.width / 1.2,
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(left: 42),
                          child: Container(
                            width: MediaQuery.of(context).size.width * .3,
                            height: 50,
                            child: RaisedButton(
                              child: Text("Ingresar"),
                              color: Colors.green,
                              splashColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              onPressed: () {
                                setState(() {
                                  loggin = true;
                                  login();
                                });

                                //login();
                              },
                            ),
                          ),
                        ),
                      ],
                    )),
              ],
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Center(
          child: Text("Autenticarse "),
        ),
      ),
      body: Form(
        child: Container(
          color: Colors.white,
          child: loggin ? Center(child: CircularProgressIndicator()) : all(),
        ),
      ),
    );
  }
}
