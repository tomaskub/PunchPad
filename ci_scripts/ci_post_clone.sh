#!/bin/sh

set -e 
set -o pipefail

print_step() {
  echo ""
  echo "================================================"
  echo ">>> $1"
}

install_dependecy() {
  echo "Installing $1 with brew..."
  HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_INSTALL_CLEANUP=1 HOMEBREW_NO_ENV_HINTS=1 brew install --quiet $1
  echo "$1 installed successfully"
}

print_step "Starting $CI_XCODE_PROJECT"

print_step "Checking xcodegen availablity"

if ! command -v xcodegen &> /dev/null; then 
  echo "XcodeGen not found"
  install_dependecy "xcodegen"
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

# print_step "Resolving swift package dependencies"
# xcodebuild -resolvePackageDependencies \
  # -project "PunchPad.xcodeproj" \
  # -scheme "PunchPad" \
  # -derivedDataPath "$CI_DERIVED_DATA_PATH" \
  # -clonedSourcePackagesDirPath "./SourcePackages" \
  # -disableAutomaticPackageResolution \
  # -verbose 
