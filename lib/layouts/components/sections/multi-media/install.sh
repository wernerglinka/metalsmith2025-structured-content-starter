#!/bin/bash

# Installation script for multi-media v1.4.0
# Content Hash: a155ccdf09b845ca

set -e

# Base URL for component downloads
DOWNLOAD_BASE_URL="https://nunjucks-components.com/downloads"

echo "🔧 Installing multi-media v1.4.0..."

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
if [ "section" = "section" ]; then
  TARGET_DIR="$COMPONENTS_BASE/$SECTIONS_DIR/multi-media"
else
  TARGET_DIR="$COMPONENTS_BASE/$PARTIALS_DIR/multi-media"
fi
mkdir -p "$TARGET_DIR"

# Check for existing installation
if [ -f "$TARGET_DIR/manifest.json" ]; then
  EXISTING_HASH=$(grep -o '"contentHash": "[^"]*"' "$TARGET_DIR/manifest.json" | cut -d'"' -f4)
  if [ "$EXISTING_HASH" = "a155ccdf09b845ca" ]; then
    echo "✓ multi-media v1.4.0 already installed (no changes)"
    exit 0
  else
    echo "📦 Upgrading multi-media (content changed)"
  fi
fi

# Check and auto-install dependencies
echo "Checking dependencies..."
AUTO_INSTALLED_DEPS=""
FAILED_DEPS=""

# Check for ctas
if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/ctas/manifest.json" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/ctas/manifest.json" ]; then
  # Try to auto-install (most dependencies are partials)
  if ! install_dependency "ctas" "partial"; then
    # Try as section if partial fails
    if ! install_dependency "ctas" "section"; then
      FAILED_DEPS="$FAILED_DEPS ctas"
    fi
  fi
else
  echo "  ✓ ctas (already installed)"
fi
# Check for text
if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/text/manifest.json" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/text/manifest.json" ]; then
  # Try to auto-install (most dependencies are partials)
  if ! install_dependency "text" "partial"; then
    # Try as section if partial fails
    if ! install_dependency "text" "section"; then
      FAILED_DEPS="$FAILED_DEPS text"
    fi
  fi
else
  echo "  ✓ text (already installed)"
fi
# Check for image
if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/image/manifest.json" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/image/manifest.json" ]; then
  # Try to auto-install (most dependencies are partials)
  if ! install_dependency "image" "partial"; then
    # Try as section if partial fails
    if ! install_dependency "image" "section"; then
      FAILED_DEPS="$FAILED_DEPS image"
    fi
  fi
else
  echo "  ✓ image (already installed)"
fi
# Check for video
if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/video/manifest.json" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/video/manifest.json" ]; then
  # Try to auto-install (most dependencies are partials)
  if ! install_dependency "video" "partial"; then
    # Try as section if partial fails
    if ! install_dependency "video" "section"; then
      FAILED_DEPS="$FAILED_DEPS video"
    fi
  fi
else
  echo "  ✓ video (already installed)"
fi
# Check for audio
if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/audio/manifest.json" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/audio/manifest.json" ]; then
  # Try to auto-install (most dependencies are partials)
  if ! install_dependency "audio" "partial"; then
    # Try as section if partial fails
    if ! install_dependency "audio" "section"; then
      FAILED_DEPS="$FAILED_DEPS audio"
    fi
  fi
else
  echo "  ✓ audio (already installed)"
fi
# Check for icon
if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/icon/manifest.json" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/icon/manifest.json" ]; then
  # Try to auto-install (most dependencies are partials)
  if ! install_dependency "icon" "partial"; then
    # Try as section if partial fails
    if ! install_dependency "icon" "section"; then
      FAILED_DEPS="$FAILED_DEPS icon"
    fi
  fi
else
  echo "  ✓ icon (already installed)"
fi
# Check for lottie
if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/lottie/manifest.json" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/lottie/manifest.json" ]; then
  # Try to auto-install (most dependencies are partials)
  if ! install_dependency "lottie" "partial"; then
    # Try as section if partial fails
    if ! install_dependency "lottie" "section"; then
      FAILED_DEPS="$FAILED_DEPS lottie"
    fi
  fi
else
  echo "  ✓ lottie (already installed)"
fi
# Check for iframe
if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/iframe/manifest.json" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/iframe/manifest.json" ]; then
  # Try to auto-install (most dependencies are partials)
  if ! install_dependency "iframe" "partial"; then
    # Try as section if partial fails
    if ! install_dependency "iframe" "section"; then
      FAILED_DEPS="$FAILED_DEPS iframe"
    fi
  fi
else
  echo "  ✓ iframe (already installed)"
fi
# Check for disclosure
if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/disclosure/manifest.json" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/disclosure/manifest.json" ]; then
  # Try to auto-install (most dependencies are partials)
  if ! install_dependency "disclosure" "partial"; then
    # Try as section if partial fails
    if ! install_dependency "disclosure" "section"; then
      FAILED_DEPS="$FAILED_DEPS disclosure"
    fi
  fi
else
  echo "  ✓ disclosure (already installed)"
fi
# Check for commons
if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/commons/manifest.json" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/commons/manifest.json" ]; then
  # Try to auto-install (most dependencies are partials)
  if ! install_dependency "commons" "partial"; then
    # Try as section if partial fails
    if ! install_dependency "commons" "section"; then
      FAILED_DEPS="$FAILED_DEPS commons"
    fi
  fi
else
  echo "  ✓ commons (already installed)"
fi

# Check if any dependencies failed
if [ -n "$FAILED_DEPS" ]; then
  echo ""
  echo "⚠ Warning: Could not install some dependencies:$FAILED_DEPS"
  echo ""
  echo "You may need to download them manually from:"
  echo "  https://nunjucks-components.com/downloads/"
  echo ""
  # Skip interactive prompt if called from bundle installer or auto-install mode
  if [ -n "$BUNDLE_INSTALL" ] || [ -n "$AUTO_INSTALL" ]; then
    echo "  (Auto-continuing)"
    echo ""
  else
    read -p "Continue installation anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      exit 1
    fi
  fi
fi

# Copy files
echo "Copying files..."
cp "$COMPONENT_DIR/multi-media.njk" "$TARGET_DIR/"
cp "$COMPONENT_DIR/multi-media.css" "$TARGET_DIR/"
cp "$COMPONENT_DIR/manifest.json" "$TARGET_DIR/"
if [ -f "$COMPONENT_DIR/README.md" ]; then
  cp "$COMPONENT_DIR/README.md" "$TARGET_DIR/"
fi

echo ""
echo "✓ Installation complete"
echo ""
echo "Files installed to: $TARGET_DIR"
if [ -n "$AUTO_INSTALLED_DEPS" ]; then
  echo "Dependencies installed:$AUTO_INSTALLED_DEPS"
fi
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
