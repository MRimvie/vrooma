import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:get/get.dart';
import '../helpers/constant/app_constant.dart';

class SocketService extends GetxService {
  late IO.Socket socket;
  final RxBool isConnected = false.obs;

  void connect(String userId, String role) {
    socket = IO.io(
      AppConstant.baseAPI,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders({'userId': userId, 'role': role})
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      print('Socket connecté');
      isConnected.value = true;
      socket.emit('user:online', {'userId': userId, 'role': role});
    });

    socket.onDisconnect((_) {
      print('Socket déconnecté');
      isConnected.value = false;
    });

    socket.onError((error) {
      print('Erreur socket: $error');
    });
  }

  void disconnect() {
    if (socket.connected) {
      socket.disconnect();
    }
  }

  void emitDriverLocation(String driverId, double lat, double lng, double? heading) {
    if (socket.connected) {
      socket.emit('driver:location', {
        'driverId': driverId,
        'latitude': lat,
        'longitude': lng,
        'heading': heading,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  void listenToDriverLocation(Function(Map<String, dynamic>) callback) {
    socket.on('driver:location:update', (data) {
      callback(data);
    });
  }

  void emitRideRequest(Map<String, dynamic> rideData) {
    if (socket.connected) {
      socket.emit('ride:request', rideData);
    }
  }

  void listenToRideRequests(Function(Map<String, dynamic>) callback) {
    socket.on('ride:new', (data) {
      callback(data);
    });
  }

  void emitRideAccepted(String rideId, String driverId) {
    if (socket.connected) {
      socket.emit('ride:accepted', {
        'rideId': rideId,
        'driverId': driverId,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  void listenToRideAccepted(Function(Map<String, dynamic>) callback) {
    socket.on('ride:accepted:update', (data) {
      callback(data);
    });
  }

  void emitRideStatusUpdate(String rideId, String status) {
    if (socket.connected) {
      socket.emit('ride:status', {
        'rideId': rideId,
        'status': status,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  void listenToRideStatusUpdate(Function(Map<String, dynamic>) callback) {
    socket.on('ride:status:update', (data) {
      callback(data);
    });
  }

  void removeAllListeners() {
    socket.off('driver:location:update');
    socket.off('ride:new');
    socket.off('ride:accepted:update');
    socket.off('ride:status:update');
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
