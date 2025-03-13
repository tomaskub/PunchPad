#!/bin/sh

if ! command -v xcodegen &> /dev/null; then 
  echo "XcodeGen not found, installing with brew..."
  brew install xcodegen
fi

# Change directory to main project
cd ..
echo "Generate xcode project file"
xcodegen

