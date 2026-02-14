import 'package:board_app/ui/board/view_models/route_model.dart';
import 'package:flutter/material.dart';

class BoardProvider extends ChangeNotifier{
  RouteModel _routeModel= RouteModel.fromJson({});

  BoardProvider();

  RouteModel get route => _routeModel;

  void changeRoute(RouteModel newRouteModel){
    _routeModel = newRouteModel;
    notifyListeners();
  }

  void changeHoldType(int idx){
    _routeModel.changeHoldType(idx);
    notifyListeners();
  }

  void clearRoute(){
    _routeModel = RouteModel.fromJson({});
    notifyListeners();
  }


}