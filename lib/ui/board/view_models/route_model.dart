import 'package:board_app/ui/board/widgets/hold.dart';
import 'package:flutter/material.dart';

class RouteModel {
  final Map<HoldType, List<int>> _holdStates;

  RouteModel(this._holdStates);

  factory RouteModel.fromJson(Map<String, dynamic> json) {

    final Map<HoldType, List<int>> holdStates = {};
    const Map<String, HoldType> holdTypeNames = {
      'all': HoldType.all,
      'feet': HoldType.feet,
      'start': HoldType.start,
      'end': HoldType.end,
    };

    for(var key in json.keys){
      if(holdTypeNames.keys.contains(key)){
        HoldType holdType = holdTypeNames[key]!;
        if(json[key] != null){
          holdStates[holdType] = List<int>.from(json[key]);
        }
      }
    }

    return RouteModel(holdStates);
  }

  HoldType getHoldType(int idx){
    HoldType currentHoldType = HoldType.none;
    for(var holdType in _holdStates.keys){
      if(_holdStates[holdType] != null && _holdStates[holdType]!.contains(idx)){
        return holdType;
      }
    }
    return currentHoldType;
  }

  Color getHoldTypeColor(HoldType holdType){
    return switch (holdType) {
      HoldType.all => Colors.blue,
      HoldType.feet => Colors.yellow,
      HoldType.start => Colors.green,
      HoldType.end => Colors.pinkAccent,
      HoldType.none => Colors.transparent
    };
  }

  void changeHoldType(int idx){
    HoldType currentHoldType = getHoldType(idx);
    HoldType nextHoldType = HoldType.values[(currentHoldType.index + 1) % HoldType.values.length];
    if(currentHoldType != HoldType.none){
      _holdStates[currentHoldType]!.remove(idx);
    }
    if(nextHoldType != HoldType.none){
      if(_holdStates[nextHoldType] is !List<int>){
        _holdStates[nextHoldType] = [];
      }
      _holdStates[nextHoldType]!.add(idx);
    }
  }

  List<int> getRouteLayoutBytes(){
    List<int> routeLayoutBytes = List.filled(8*8, 48);
    for(HoldType type in _holdStates.keys){
      if(_holdStates[type] != null){
        List<int>? coords = _holdStates[type];
        if(coords != null){
          for(int coord in coords){
            routeLayoutBytes[coord] = type.index + 48;
          }
        }
      }
    }
    return routeLayoutBytes;
  }

  Map<HoldType, List<int>> getRoute(){
    return _holdStates;
  }
}
