// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:brasil_fields/brasil_fields.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

TextEditingController txtcep = new TextEditingController();
String resultado = "";

class _HomeState extends State<Home> {
  bool _loading = false;
  bool _enableField = true;
  final _formKey = GlobalKey<FormState>();

  //Pegar o Cep digitado no campo de texto.

  _consultarCep() async {
    String cep = txtcep.text;

    // Retirando a mask do cep.
    String cepnullmaskcep = cep.replaceAll("-", "").replaceAll(".", "");

    // Configurando url API CEP.
    String url = "https://viacep.com.br/ws/$cepnullmaskcep/json";

    http.Response response;

    response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> retorno = json.decode(response.body);

      String logradouro = retorno["logradouro"];
      String bairro = retorno["bairro"];
      String cidade = retorno["localidade"];
      String uf = retorno["uf"];

      setState(() {
        resultado = "$logradouro, $bairro, $cidade-$uf.";
      });
    } else {
      throw Exception('Requisição inválida!');
    }
  }

  // Pegando a posiçãoa atual e validando permissoes.

  @override
  void dispose() {
    super.dispose();
    txtcep.clear();
  }

// Corpo do aplicativo
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.yellowAccent,
        title: Text(
          "Consultar CEP",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildSearchCepTextField(),
            _buildResultForm(),
            _buildSearchCepButton(),
          ],
        ),
      ),
    );
  }

// Criação campo input cep.
  Widget _buildSearchCepTextField() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: txtcep,
            enabled: _enableField,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CepInputFormatter(),
            ],
            cursorColor: Colors.black,
            style: TextStyle(color: Colors.black, fontSize: 20),
            autofocus: true,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.number,
            maxLength: 10,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.yellowAccent,
              labelText: "CEP",
              labelStyle: TextStyle(
                color: Colors.black,
                backgroundColor: Colors.yellowAccent,
              ),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                color: Colors.blue,
                width: 3,
              )),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                color: Colors.black,
                width: 2,
              )),
            ),
            validator: (value) {
              if (value == null || value.isEmpty || value.length < 10) {
                return 'Informe um CEP valido.';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

// Criação output do cep pesquisado.
  Widget _buildResultForm() {
    return Container(
      padding: EdgeInsets.only(top: 40.0, bottom: 40),
      child: Text(
        "$resultado",
        style: TextStyle(
          fontSize: 15,
          color: Colors.blue,
        ),
      ),
    );
  }

// Criação do botão consultar.
  Widget _buildSearchCepButton() {
    return Container(
      padding: EdgeInsets.only(top: 40, bottom: 40),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Colors.yellowAccent, // background
                  onPrimary: Colors.black, // foreground
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50))),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _consultarCep();
                }
              },
              child: Text(
                "Consultar",
                style: TextStyle(fontSize: 20),
              ),
            ),
          ]),
    );
  }
}
