#!/bin/bash

# Installation script for text-only v0.0.1
# Content Hash: 6bacdfa4cd8c5606

set -e

echo "🔧 Installing text-only v0.0.1..."

# Detect Metalsmith project directory and component source
COMPONENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if PROJECT_ROOT was set by bundle installer
if [ -n "$PROJECT_ROOT" ]; then
  # Called from bundle installer, PROJECT_ROOT already set
  cd "$PROJECT_ROOT"
# Check if we're in a component package directory (has x-metalsmith-component marker)
elif [ -f "package.json" ] && grep -q "\"x-metalsmith-component\"" package.json; then
  # In a component directory, look up for project root
  if [ -f "../metalsmith.js" ]; then
    PROJECT_ROOT="$(cd .. && pwd)"
    cd "$PROJECT_ROOT"
  elif [ -f "../../metalsmith.js" ]; then
    # Two levels up (e.g., bundle/partials/component/)
    PROJECT_ROOT="$(cd ../.. && pwd)"
    cd "$PROJECT_ROOT"
  else
    echo "❌ Error: Component directory not in a Metalsmith project"
    echo "Please extract components in your Metalsmith project root directory"
    exit 1
  fi
elif [ -f "metalsmith.js" ]; then
  # Already in project root
  PROJECT_ROOT="$(pwd)"
else
  echo "❌ Error: Not a Metalsmith project directory"
  echo "Please run this script from your Metalsmith project root or from within the extracted component directory"
  exit 1
fi

# Load component paths from config or use defaults
if [ -f "metalsmith-components.config.json" ]; then
  COMPONENTS_BASE=$(node -p "try { require('./metalsmith-components.config.json').componentsBasePath } catch(e) { 'lib/layouts/components' }")
  SECTIONS_DIR=$(node -p "try { require('./metalsmith-components.config.json').sectionsDir } catch(e) { 'sections' }")
  PARTIALS_DIR=$(node -p "try { require('./metalsmith-components.config.json').partialsDir } catch(e) { '_partials' }")
else
  COMPONENTS_BASE="lib/layouts/components"
  SECTIONS_DIR="sections"
  PARTIALS_DIR="_partials"
fi

# Create target directory
if [ "section" = "section" ]; then
  TARGET_DIR="$COMPONENTS_BASE/$SECTIONS_DIR/text-only"
else
  TARGET_DIR="$COMPONENTS_BASE/$PARTIALS_DIR/text-only"
fi
mkdir -p "$TARGET_DIR"

# Check for existing installation
if [ -f "$TARGET_DIR/manifest.json" ]; then
  EXISTING_HASH=$(grep -o '"contentHash": "[^"]*"' "$TARGET_DIR/manifest.json" | cut -d'"' -f4)
  if [ "$EXISTING_HASH" = "6bacdfa4cd8c5606" ]; then
    echo "✓ text-only v0.0.1 already installed (no changes)"
    exit 0
  else
    echo "📦 Upgrading text-only (content changed)"
  fi
fi

# Check dependencies
echo "Checking dependencies..."
MISSING_DEPS=()

# Check for ctas in both partials and sections
if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/ctas/manifest.json" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/ctas/manifest.json" ]; then
  MISSING_DEPS+=("ctas")
fi
# Check for text in both partials and sections
if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/text/manifest.json" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/text/manifest.json" ]; then
  MISSING_DEPS+=("text")
fi
# Check for commons in both partials and sections
if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/commons/manifest.json" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/commons/manifest.json" ]; then
  MISSING_DEPS+=("commons")
fi

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
  echo "⚠ Warning: Missing required components:"
  for dep in "${MISSING_DEPS[@]}"; do
    echo "  • $dep"
  done
  echo ""
  echo "Download from: https://metalsmith-components.netlify.app/downloads/"
  echo ""
  # Skip interactive prompt if called from bundle installer
  if [ -n "$PROJECT_ROOT" ]; then
    echo "  (Auto-continuing from bundle installer)"
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
cp "$COMPONENT_DIR/text-only.njk" "$TARGET_DIR/"
cp "$COMPONENT_DIR/text-only.css" "$TARGET_DIR/"
cp "$COMPONENT_DIR/manifest.json" "$TARGET_DIR/"

echo ""
echo "✓ Installation complete"
echo ""
echo "Files installed to: $TARGET_DIR"
echo ""
# Cleanup extracted component directory if not called from bundle
if [ -z "$BUNDLE_INSTALL" ] && [ -f "$COMPONENT_DIR/package.json" ] && grep -q "\"x-metalsmith-component\"" "$COMPONENT_DIR/package.json" 2>/dev/null; then
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
