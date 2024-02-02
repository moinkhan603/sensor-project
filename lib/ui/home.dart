import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:stacked/stacked.dart';
import '../controller/home_controller.dart';

class SensorTrackingScreen extends StatefulWidget {
  const SensorTrackingScreen({super.key});

  @override
  _SensorTrackingScreenState createState() => _SensorTrackingScreenState();
}

class _SensorTrackingScreenState extends State<SensorTrackingScreen> {
  final HomeScreenViewModel _screenViewModel = HomeScreenViewModel();

  @override
  void initState() {
    super.initState();

    FlutterCompass.events?.listen((event) {
      setState(() {
        _screenViewModel.heading = event.heading;
        // print('foreground data collection');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeScreenViewModel>.reactive(
      viewModelBuilder: () => _screenViewModel,
      onViewModelReady: (model) {
        model.initialize(context);
      },
      builder: (builderContext, model, child) => Scaffold(
        backgroundColor: Colors.grey,
        appBar: AppBar(
          title: const Text('Sensor Tracking App'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Switch(

                value: model.isDataCollectionEnabled,
                onChanged: (value) {
                  setState(() {
                    model.isDataCollectionEnabled = value;
                    if (model.isDataCollectionEnabled) {
                      // saveDataToStorage();
                      model.startSensorDataCollection();
                    }
                  });
                },
              ),
            ),
            Text(model.heading?.ceil().toString() ?? '',style: TextStyle(color: Colors.white),),
            SizedBox(height: 22,),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset('assets/images/cadrant.png'),
                  Transform.rotate(
                    angle: (model.heading ?? 0) * (pi / 180) - 1,
                    child: Image.asset('assets/images/compass.png'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
