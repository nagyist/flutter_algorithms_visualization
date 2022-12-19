import 'dart:async';

import 'package:path_finding/common/models/node.dart';
import 'package:path_finding/data/astar_algorithm.dart';
import 'package:path_finding/data/breadth_first_search.dart';
import 'package:path_finding/data/depth_first_search.dart';
import 'package:path_finding/data/dijkstras_algorithm.dart';
import 'package:path_finding/data/drunk_algorithm.dart';
import 'package:path_finding/data/visualizable_algorithm.dart';
import 'package:path_finding/notifiers/slected_shortest_path_algorithm_state_notifier.dart';
import 'package:riverpod/riverpod.dart';
import 'package:rxdart/subjects.dart';

typedef NodesArray = List<List<Node>>;

final nodesRepositoryProvider =
    Provider<NodesRepository>((ref) => NodesRepositoryImpl());

abstract class NodesRepository {
  static const numberOfNodesInRow = 60;
  static const numberOfNodesInColumn = 40;

  NodesArray get allNodes;
  Stream<NodesArray> get nodesArrayUpdateStream;
  void startAlgorithmAt(int x, int y);
  void setGoalAt(int x, int y);
  void setWallAt(int x, int y);
  void resetAt(int x, int y);
  void resetAll();
  void resetAlgorithmToStart();
  void setDiagonalPathCostTo({required double cost});
  void setHorizontalAndVerticalPathCostTo({required double cost});
  void setCurrentlySelectedAlgotihmTo(
      {required PathFindingAlgorihmType pathFindingAlgorihmType});
}

class NodesRepositoryImpl implements NodesRepository {
  late VisualizableAlgorithm _pathFindingAlgorithm =
      DijkstraAlgorithm(onStepUpdate: (e) => _onStepUpdate(e));
  final PublishSubject<NodesArray> _subject = PublishSubject<NodesArray>();

  @override
  NodesArray get allNodes => _pathFindingAlgorithm.allNodes;

  @override
  Stream<NodesArray> get nodesArrayUpdateStream => _subject.stream;

  @override
  void startAlgorithmAt(int x, int y) async {
    _pathFindingAlgorithm.runAlgorithm(Node(x: x, y: y));
  }

  @override
  void setGoalAt(int x, int y) async {
    _pathFindingAlgorithm.resetAt(x, y);
    _pathFindingAlgorithm.setGoalAt(x, y);
  }

  @override
  void setWallAt(int x, int y) async {
    _pathFindingAlgorithm.resetAt(x, y);
    _pathFindingAlgorithm.setWallAt(x, y);
  }

  @override
  void resetAt(int x, int y) async => _pathFindingAlgorithm.resetAt(x, y);

  @override
  void resetAll() async => _pathFindingAlgorithm.resetAll();

  @override
  void resetAlgorithmToStart() async =>
      _pathFindingAlgorithm.resetAlgorithmToStart();

  @override
  void setDiagonalPathCostTo({required double cost}) =>
      _pathFindingAlgorithm.setDiagonalPathCostTo(cost: cost);

  @override
  void setHorizontalAndVerticalPathCostTo({required double cost}) =>
      _pathFindingAlgorithm.setHorizontalAndVerticalPathCostTo(cost: cost);

  void _onStepUpdate(NodesArray updatedArray) {
    _subject.add(updatedArray);
  }

  @override
  void setCurrentlySelectedAlgotihmTo(
      {required PathFindingAlgorihmType pathFindingAlgorihmType}) {
    final goalNode = _pathFindingAlgorithm.goalNode;
    switch (pathFindingAlgorihmType) {
      case PathFindingAlgorihmType.dijkstras:
        _pathFindingAlgorithm = DijkstraAlgorithm(
          onStepUpdate: _onStepUpdate,
          nodesToStartWith: _pathFindingAlgorithm.allNodes,
        );
        break;

      case PathFindingAlgorihmType.astar:
        _pathFindingAlgorithm = AstarAlgorithm(
          onStepUpdate: _onStepUpdate,
          nodesToStartWith: _pathFindingAlgorithm.allNodes,
        );
        break;

      case PathFindingAlgorihmType.drunk:
        _pathFindingAlgorithm = DrunkAlgorithm(
          onStepUpdate: _onStepUpdate,
          nodesToStartWith: _pathFindingAlgorithm.allNodes,
        );
        break;

      case PathFindingAlgorihmType.dfs:
        _pathFindingAlgorithm = DepthFirstSearch(
          onStepUpdate: _onStepUpdate,
          nodesToStartWith: _pathFindingAlgorithm.allNodes,
        );
        break;
      case PathFindingAlgorihmType.bfs:
        _pathFindingAlgorithm = BreadthFirstSearch(
          onStepUpdate: _onStepUpdate,
          nodesToStartWith: _pathFindingAlgorithm.allNodes,
        );
        break;
    }

    _pathFindingAlgorithm.goalNode = goalNode;
  }
}
