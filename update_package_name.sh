#!/bin/bash

# Find all Dart files and update the package imports
find . -name "*.dart" -type f -exec sed -i 's/import '\''package:mlritpool\//import '\''package:commutify\//g' {} \;

# Update Windows app name
find ./windows -type f -name "*.cpp" -o -name "*.rc" -o -name "CMakeLists.txt" -exec sed -i 's/mlritpool/commutify/g' {} \;

# Update Linux app name
find ./linux -type f -name "*.cc" -o -name "CMakeLists.txt" -exec sed -i 's/mlritpool/commutify/g' {} \;
find ./linux -type f -name "CMakeLists.txt" -exec sed -i 's/com.example.mlritpool/com.example.commutify/g' {} \;

# Update web app name
find ./web -type f -name "*.html" -o -name "*.json" -exec sed -i 's/mlritpool/commutify/g' {} \;

# Update iOS bundle identifiers
find ./ios -type f -name "*.plist" -o -name "*.pbxproj" -exec sed -i 's/com.example.mlritpool/com.example.commutify/g' {} \;

# Update macOS bundle identifiers
find ./macos -type f -name "*.plist" -o -name "*.pbxproj" -o -name "*.xcconfig" -exec sed -i 's/com.example.mlritpool/com.example.commutify/g' {} \;
find ./macos -type f -name "*.xcconfig" -o -name "*.xcscheme" -exec sed -i 's/mlritpool/commutify/g' {} \;

# Update Google Services file
find . -name "google-services.json" -exec sed -i 's/"package_name": "com.example.mlritpool"/"package_name": "com.example.commutify"/g' {} \;

echo "Package rename from mlritpool to commutify completed!" 