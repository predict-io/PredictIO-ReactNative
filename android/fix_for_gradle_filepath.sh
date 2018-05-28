# This is necessary sicne NPM namespaces the predict.io React Native plugin
# under a `@predict.io` directory inside `node_modules`.
# When the plugin is then linked in Android, Gradle does not like having
# a directory name such as `@predict.io/react-native-predict-io` and
# therefore have to remove traces of the `@predict.io`
find ./ -name "*.gradle" -exec sed -i '' 's/:@predict.io\/react-native-predict-io/:react-native-predict-io/' {} \;
