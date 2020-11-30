import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:consultacnpj/src/dbprovider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Consulta CNPJ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Consulta CNPJ'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _counter, _cnpjEscaneado, _razaoApi, _cnpjApi = "";
  var _ultimoRegistro = [];

  Future _consultaCnpj() async {
    _counter = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", "Cancelar", true, ScanMode.DEFAULT);

    setState(() {
      _cnpjEscaneado = _counter;
    });

    try {
      var response = await http.get(Uri.encodeFull(
          "https://www.receitaws.com.br/v1/cnpj/${_cnpjEscaneado}"));
      if (response.statusCode == 200) {
        Map<String, dynamic> retornoApi = jsonDecode(response.body);
        setState(() {
          _razaoApi = retornoApi["nome"];
          _cnpjApi = retornoApi["cnpj"];
        });
        await DBProvider.db.newEmpresa('$_razaoApi', '$_cnpjApi');
        _ultimoRegistro = await DBProvider.db.getLastEmpresa();
        print(_ultimoRegistro);
      } else {
        print('Erro! A API não retornou status de sucesso.');
      }
    } catch (e) {
      print('Erro! Problema ao conectar-se com a API.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "CNPJ Escaneado: " + (_cnpjEscaneado ?? ''),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.normal),
            ),
            Text(
              (_ultimoRegistro.toString() ?? ' '),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.normal),
            ),
            RaisedButton(
              child: Text(" Consultar CNPJ "),
              onPressed: _consultaCnpj,
              color: Colors.blue,
              textColor: Colors.white,
              splashColor: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
