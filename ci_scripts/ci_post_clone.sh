#!/bin/sh

set -e 
set -0 pipefail
print_step() {
  echo ""
  echo "================================================"
  echo ">>> $1"
  echo "================================================"
}

print_step "Starting $CI_XCODE_PROJECT"

print_step "Checking xcodegen availablity"

if ! command -v xcodegen &> /dev/null; then 
  echo "XcodeGen not found, installing with brew..."
  brew install xcodegen
else 
  echo "XcodeGen avaliable"
fi

print_step "Generate xcode project file"
# Change directory to main project
cd ..
xcodegen --quiet

if [ ! -d "PunchPad.xcodeproj" ]; then 
  echo "Error: Failed to generate Xcode project"
  exit 1
fi

echo "Project generated successfully"

print_step "Resolving swift package dependencies"
xcodebuild -resolvePackageDependencies \
  -project "PunchPad.xcodeproj" \ 
  -scheme "PunchPad" \ 
  -derivedDataPath "$CI_DERIVED_DATA_PATH" \
  -clonedSourcePackagesDirPath "./SourcePackages" \
  -disableAutomaticPackageResolution \
  -verbose 
