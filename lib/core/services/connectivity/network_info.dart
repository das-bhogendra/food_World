import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Interface
abstract interface class INetworkInfo {
  Future<bool> get isConnected;
}

/// Provider
final networkInfoProvider = Provider<INetworkInfo>((ref) {
  return NetworkInfo(Connectivity());
});

/// Implementation
class NetworkInfo implements INetworkInfo {
  final Connectivity _connectivity;

  NetworkInfo(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final  result =await _connectivity.checkConnectivity();
    if (result.contains(ConnectivityResult.none)){
      return false;
    }

    return await _sacchaikaiInternetChakiNai();
  }
}

Future<bool> _sacchaikaiInternetChakiNai()async{
  if (kIsWeb) {
    // On web, assume internet is available since DNS lookup is not supported
    return true;
  }
  try{
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch(e){
    return false;
  } on UnsupportedError catch(e){
    // If DNS lookup is not supported, assume connected
    return true;
  }
}
