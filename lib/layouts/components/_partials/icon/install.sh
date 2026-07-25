#!/bin/bash

# Installation script for icon v1.3.1
# Content Hash: bd2146562c3c2416

set -e

# Base URL for component downloads
DOWNLOAD_BASE_URL="https://nunjucks-components.com/downloads"

echo "🔧 Installing icon v1.3.1..."

# Detect project directory and component source
COMPONENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to find project root by looking for config file
find_project_root() {
  local dir="$1"
  [ -f "$dir/nunjucks-components.config.json" ]
}

# Check if PROJECT_ROOT was set by bundle installer
if [ -n "$PROJECT_ROOT" ]; then
  # Called from bundle installer, PROJECT_ROOT already set
  cd "$PROJECT_ROOT"
# Check if we're in a component package directory (has x-nunjucks-component marker)
elif [ -f "package.json" ] && grep -q "\"x-nunjucks-component\"" package.json; then
  # In a component directory, look up for project root
  if find_project_root ".."; then
    PROJECT_ROOT="$(cd .. && pwd)"
    export PROJECT_ROOT
    cd "$PROJECT_ROOT"
  elif find_project_root "../.."; then
    # Two levels up (e.g., bundle/partials/component/)
    PROJECT_ROOT="$(cd ../.. && pwd)"
    export PROJECT_ROOT
    cd "$PROJECT_ROOT"
  else
    echo "❌ Error: nunjucks-components.config.json not found"
    echo "Please create this config file in your project root before installing components."
    echo ""
    echo "Example nunjucks-components.config.json:"
    echo '{
  "componentsBasePath": "lib/layouts/components",
  "sectionsDir": "sections",
  "partialsDir": "_partials"
}'
    exit 1
  fi
elif find_project_root "."; then
  # Already in project root
  PROJECT_ROOT="$(pwd)"
  export PROJECT_ROOT
else
  echo "❌ Error: nunjucks-components.config.json not found"
  echo "Please create this config file in your project root before installing components."
  echo ""
  echo "Example nunjucks-components.config.json:"
  echo '{
  "componentsBasePath": "lib/layouts/components",
  "sectionsDir": "sections",
  "partialsDir": "_partials"
}'
  exit 1
fi

# Load component paths from config
COMPONENTS_BASE=$(node -p "require('./nunjucks-components.config.json').componentsBasePath")
SECTIONS_DIR=$(node -p "require('./nunjucks-components.config.json').sectionsDir")
PARTIALS_DIR=$(node -p "require('./nunjucks-components.config.json').partialsDir")

# Track installed dependencies to prevent circular loops
if [ -z "$INSTALLED_DEPS" ]; then
  export INSTALLED_DEPS=""
fi

# Function to download and install a dependency
install_dependency() {
  local dep_name="$1"
  local dep_type="$2"  # "partial" or "section"
  
  # Check if already processed in this session (circular dependency protection)
  if [[ "$INSTALLED_DEPS" == *":$dep_name:"* ]]; then
    return 0
  fi
  
  # Mark as being processed
  export INSTALLED_DEPS="$INSTALLED_DEPS:$dep_name:"
  
  local dep_dir
  local download_url
  
  if [ "$dep_type" = "section" ]; then
    dep_dir="$COMPONENTS_BASE/$SECTIONS_DIR/$dep_name"
    download_url="$DOWNLOAD_BASE_URL/sections/$dep_name.zip"
  else
    dep_dir="$COMPONENTS_BASE/$PARTIALS_DIR/$dep_name"
    download_url="$DOWNLOAD_BASE_URL/partials/$dep_name.zip"
  fi
  
  # Check if already installed
  if [ -f "$dep_dir/manifest.json" ]; then
    echo "  ✓ $dep_name (already installed)"
    return 0
  fi
  
  echo "  ↓ Installing $dep_name..."
  
  # Create temp directory for download
  local temp_dir=$(mktemp -d)
  local zip_file="$temp_dir/$dep_name.zip"
  
  # Download the component
  if ! curl -sL -f "$download_url" -o "$zip_file" 2>/dev/null; then
    echo "    ⚠ Failed to download $dep_name from $download_url"
    rm -rf "$temp_dir"
    return 1
  fi
  
  # Extract and install
  if ! unzip -q "$zip_file" -d "$temp_dir" 2>/dev/null; then
    echo "    ⚠ Failed to extract $dep_name"
    rm -rf "$temp_dir"
    return 1
  fi
  
  # Run the dependency's install script (handles nested dependencies)
  local extracted_dir="$temp_dir/$dep_name"
  if [ -f "$extracted_dir/install.sh" ]; then
    chmod +x "$extracted_dir/install.sh"
    # Run with AUTO_INSTALL to skip prompts
    (cd "$extracted_dir" && AUTO_INSTALL=1 ./install.sh) || {
      echo "    ⚠ Failed to install $dep_name"
      rm -rf "$temp_dir"
      return 1
    }
  fi
  
  # Cleanup
  rm -rf "$temp_dir"
  
  # Track that this was auto-installed
  AUTO_INSTALLED_DEPS="$AUTO_INSTALLED_DEPS $dep_name"
  
  return 0
}

# Create target directory
if [ "partial" = "section" ]; then
  TARGET_DIR="$COMPONENTS_BASE/$SECTIONS_DIR/icon"
else
  TARGET_DIR="$COMPONENTS_BASE/$PARTIALS_DIR/icon"
fi
mkdir -p "$TARGET_DIR"

# Check for existing installation
if [ -f "$TARGET_DIR/manifest.json" ]; then
  EXISTING_HASH=$(grep -o '"contentHash": "[^"]*"' "$TARGET_DIR/manifest.json" | cut -d'"' -f4)
  if [ "$EXISTING_HASH" = "bd2146562c3c2416" ]; then
    echo "✓ icon v1.3.1 already installed (no changes)"
    exit 0
  else
    echo "📦 Upgrading icon (content changed)"
  fi
fi

# Copy files
echo "Copying files..."
cp "$COMPONENT_DIR/icon.njk" "$TARGET_DIR/"
cp "$COMPONENT_DIR/manifest.json" "$TARGET_DIR/"
if [ -f "$COMPONENT_DIR/README.md" ]; then
  cp "$COMPONENT_DIR/README.md" "$TARGET_DIR/"
fi

echo ""
echo "✓ Installation complete"
echo ""
echo "Files installed to: $TARGET_DIR"
echo ""
# Cleanup extracted component directory if not called from bundle or auto-install
if [ -z "$BUNDLE_INSTALL" ] && [ -z "$AUTO_INSTALL" ] && [ -f "$COMPONENT_DIR/package.json" ] && grep -q "\"x-nunjucks-component\"" "$COMPONENT_DIR/package.json" 2>/dev/null; then
  # Check if component directory is in project root (not in a bundle structure)
  COMPONENT_BASENAME="$(basename "$COMPONENT_DIR")"
  if [ "$COMPONENT_DIR" = "$PROJECT_ROOT/$COMPONENT_BASENAME" ]; then
    echo ""
    read -p "Remove extracted component directory $COMPONENT_BASENAME? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      rm -rf "$COMPONENT_DIR"
      echo "✓ Cleaned up $COMPONENT_BASENAME"
    fi
  fi
fi

echo ""
echo "See README.md for usage instructions"
