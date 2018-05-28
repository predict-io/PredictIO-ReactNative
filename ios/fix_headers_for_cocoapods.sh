sed -i '' "s/<RCTAnimation\\/RCTValueAnimatedNode.h>/<React\\/RCTValueAnimatedNode.h>/" ./node_modules/react-native/Libraries/NativeAnimation/RCTNativeAnimatedNodesManager.h;
sed -i '' "s/<fishhook\\/fishhook.h>/<React\\/fishhook.h>/" ./node_modules/react-native/Libraries/WebSocket/RCTReconnectingWebSocket.m;
