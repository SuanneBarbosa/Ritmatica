import 'package:flutter/material.dart';

class ThankYouScreen extends StatelessWidget {
  const ThankYouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agradecimentos"),
        backgroundColor: Colors.blue, 
         titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20), 
        iconTheme: const IconThemeData(color: Colors.white), 
      ),
      body: Container(

        padding: const EdgeInsets.all(16.0),
         color: const Color.fromRGBO(220, 247, 255, 1.0),
        child: Center(
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            color: Colors.blueAccent,
            child: const SizedBox(
              height: 300,
              child: Scrollbar(
                thumbVisibility: false,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      
                      Text(
                        "Versão Original",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Lulu Healy\nNathalie Sinclair\nRonaldo Carrilho",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Versão Atualizada (2025)",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Luis Fernando Pacheco Pereira\n"
                        "Solange Hassan Ahmad Ali Fernandes\n"
                        "Suanne Almeida Barbosa",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
