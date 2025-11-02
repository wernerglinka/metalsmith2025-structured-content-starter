#!/bin/bash

# Metalsmith Components Bundle Installation Script

set -e

echo "🔧 Installing Metalsmith Components Bundle..."
echo ""

# Check if this is a Metalsmith project
if [ ! -f "metalsmith.js" ] && [ ! -f "package.json" ]; then
  echo "❌ Error: Not a Metalsmith project directory"
  echo "Please run this script from your Metalsmith project root"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(pwd)"
export PROJECT_ROOT
export BUNDLE_INSTALL=1

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

# Check installation mode
MODE="all"
if [ "$1" = "--update-only" ] || [ "$1" = "-u" ]; then
  MODE="update"
  echo "📦 Update mode: Only updating existing components"
  echo ""
elif [ -d "$COMPONENTS_BASE" ]; then
  echo "Existing components directory found."
  echo ""
  echo "Choose installation mode:"
  echo "  1) Install all components (default)"
  echo "  2) Update existing components only"
  echo ""
  read -p "Select [1-2]: " -n 1 -r
  echo
  echo ""
  if [[ $REPLY == "2" ]]; then
    MODE="update"
    echo "📦 Update mode: Only updating existing components"
  else
    echo "📦 Full install mode: Installing all components"
  fi
  echo ""
fi

# Install partials (dependencies first)
echo "📦 Installing partials..."
echo ""

INSTALLED_COUNT=0
SKIPPED_COUNT=0
REQUIRED_DEPS=()

# Build list of components to install/update
COMPONENTS_TO_INSTALL=()

if [ -f "$SCRIPT_DIR/partials/audio/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/audio/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    COMPONENTS_TO_INSTALL+=("partial:audio")
    REQUIRED_DEPS+=("image")
    REQUIRED_DEPS+=("icon")
  fi
fi

if [ -f "$SCRIPT_DIR/partials/author-date/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/author-date/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    COMPONENTS_TO_INSTALL+=("partial:author-date")
  fi
fi

if [ -f "$SCRIPT_DIR/partials/branding/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/branding/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    COMPONENTS_TO_INSTALL+=("partial:branding")
  fi
fi

if [ -f "$SCRIPT_DIR/partials/breadcrumbs/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/breadcrumbs/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    COMPONENTS_TO_INSTALL+=("partial:breadcrumbs")
  fi
fi

if [ -f "$SCRIPT_DIR/partials/button/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/button/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    COMPONENTS_TO_INSTALL+=("partial:button")
  fi
fi

if [ -f "$SCRIPT_DIR/partials/collection-card/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/collection-card/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    COMPONENTS_TO_INSTALL+=("partial:collection-card")
    REQUIRED_DEPS+=("icon")
    REQUIRED_DEPS+=("text")
    REQUIRED_DEPS+=("author-date")
  fi
fi

if [ -f "$SCRIPT_DIR/partials/collection-pagination/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/collection-pagination/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    COMPONENTS_TO_INSTALL+=("partial:collection-pagination")
  fi
fi

if [ -f "$SCRIPT_DIR/partials/ctas/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/ctas/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    COMPONENTS_TO_INSTALL+=("partial:ctas")
    REQUIRED_DEPS+=("button")
    REQUIRED_DEPS+=("text-link")
  fi
fi

if [ -f "$SCRIPT_DIR/partials/dark-light-theme-switcher/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/dark-light-theme-switcher/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    COMPONENTS_TO_INSTALL+=("partial:dark-light-theme-switcher")
    REQUIRED_DEPS+=("icon")
  fi
fi

if [ -f "$SCRIPT_DIR/partials/flip-card/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/flip-card/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    COMPONENTS_TO_INSTALL+=("partial:flip-card")
    REQUIRED_DEPS+=("ctas")
    REQUIRED_DEPS+=("text")
    REQUIRED_DEPS+=("icon")
    REQUIRED_DEPS+=("commons")
  fi
fi

if [ -f "$SCRIPT_DIR/partials/icon/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/icon/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    COMPONENTS_TO_INSTALL+=("partial:icon")
  fi
fi

if [ -f "$SCRIPT_DIR/partials/image/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/image/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    COMPONENTS_TO_INSTALL+=("partial:image")
  fi
fi

if [ -f "$SCRIPT_DIR/partials/lottie/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/lottie/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    COMPONENTS_TO_INSTALL+=("partial:lottie")
  fi
fi

if [ -f "$SCRIPT_DIR/partials/manual-card/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/manual-card/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    COMPONENTS_TO_INSTALL+=("partial:manual-card")
    REQUIRED_DEPS+=("text")
    REQUIRED_DEPS+=("ctas")
    REQUIRED_DEPS+=("image")
    REQUIRED_DEPS+=("icon")
  fi
fi

if [ -f "$SCRIPT_DIR/partials/navigation/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/navigation/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    COMPONENTS_TO_INSTALL+=("partial:navigation")
  fi
fi

if [ -f "$SCRIPT_DIR/partials/overlay/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/overlay/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    COMPONENTS_TO_INSTALL+=("partial:overlay")
  fi
fi

if [ -f "$SCRIPT_DIR/partials/search/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/search/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    COMPONENTS_TO_INSTALL+=("partial:search")
  fi
fi

if [ -f "$SCRIPT_DIR/partials/slider-pagination/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/slider-pagination/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    COMPONENTS_TO_INSTALL+=("partial:slider-pagination")
  fi
fi

if [ -f "$SCRIPT_DIR/partials/text/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/text/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    COMPONENTS_TO_INSTALL+=("partial:text")
  fi
fi

if [ -f "$SCRIPT_DIR/partials/text-link/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/text-link/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    COMPONENTS_TO_INSTALL+=("partial:text-link")
  fi
fi

if [ -f "$SCRIPT_DIR/partials/video/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/video/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    COMPONENTS_TO_INSTALL+=("partial:video")
    REQUIRED_DEPS+=("overlay")
    REQUIRED_DEPS+=("image")
    REQUIRED_DEPS+=("icon")
  fi
fi

# Install required dependencies
if [ ${#REQUIRED_DEPS[@]} -gt 0 ]; then
  UNIQUE_DEPS=($(printf "%s\n" "${REQUIRED_DEPS[@]}" | sort -u))
  for dep in "${UNIQUE_DEPS[@]}"; do
    if [ -f "$SCRIPT_DIR/partials/$dep/install.sh" ]; then
      if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/$dep/manifest.json" ]; then
        echo "Installing required dependency: $dep"
        cd "$PROJECT_ROOT"
        (cd "$SCRIPT_DIR/partials/$dep" && ./install.sh)
        INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
        echo ""
      fi
    fi
  done
fi

if [ -f "$SCRIPT_DIR/partials/audio/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/audio/manifest.json" ]; then
    echo "⊘ Skipping audio (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing audio..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/partials/audio" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/partials/author-date/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/author-date/manifest.json" ]; then
    echo "⊘ Skipping author-date (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing author-date..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/partials/author-date" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/partials/branding/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/branding/manifest.json" ]; then
    echo "⊘ Skipping branding (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing branding..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/partials/branding" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/partials/breadcrumbs/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/breadcrumbs/manifest.json" ]; then
    echo "⊘ Skipping breadcrumbs (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing breadcrumbs..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/partials/breadcrumbs" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/partials/button/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/button/manifest.json" ]; then
    echo "⊘ Skipping button (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing button..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/partials/button" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/partials/collection-card/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/collection-card/manifest.json" ]; then
    echo "⊘ Skipping collection-card (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing collection-card..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/partials/collection-card" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/partials/collection-pagination/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/collection-pagination/manifest.json" ]; then
    echo "⊘ Skipping collection-pagination (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing collection-pagination..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/partials/collection-pagination" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/partials/ctas/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/ctas/manifest.json" ]; then
    echo "⊘ Skipping ctas (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing ctas..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/partials/ctas" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/partials/dark-light-theme-switcher/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/dark-light-theme-switcher/manifest.json" ]; then
    echo "⊘ Skipping dark-light-theme-switcher (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing dark-light-theme-switcher..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/partials/dark-light-theme-switcher" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/partials/flip-card/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/flip-card/manifest.json" ]; then
    echo "⊘ Skipping flip-card (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing flip-card..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/partials/flip-card" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/partials/icon/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/icon/manifest.json" ]; then
    echo "⊘ Skipping icon (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing icon..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/partials/icon" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/partials/image/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/image/manifest.json" ]; then
    echo "⊘ Skipping image (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing image..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/partials/image" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/partials/lottie/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/lottie/manifest.json" ]; then
    echo "⊘ Skipping lottie (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing lottie..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/partials/lottie" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/partials/manual-card/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/manual-card/manifest.json" ]; then
    echo "⊘ Skipping manual-card (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing manual-card..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/partials/manual-card" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/partials/navigation/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/navigation/manifest.json" ]; then
    echo "⊘ Skipping navigation (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing navigation..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/partials/navigation" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/partials/overlay/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/overlay/manifest.json" ]; then
    echo "⊘ Skipping overlay (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing overlay..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/partials/overlay" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/partials/search/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/search/manifest.json" ]; then
    echo "⊘ Skipping search (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing search..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/partials/search" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/partials/slider-pagination/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/slider-pagination/manifest.json" ]; then
    echo "⊘ Skipping slider-pagination (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing slider-pagination..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/partials/slider-pagination" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/partials/text/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/text/manifest.json" ]; then
    echo "⊘ Skipping text (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing text..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/partials/text" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/partials/text-link/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/text-link/manifest.json" ]; then
    echo "⊘ Skipping text-link (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing text-link..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/partials/text-link" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/partials/video/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/video/manifest.json" ]; then
    echo "⊘ Skipping video (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing video..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/partials/video" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

# Install sections
echo "📦 Installing sections..."
echo ""

if [ -f "$SCRIPT_DIR/sections/audio-only/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/audio-only/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    # Install dependency if needed: ctas
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/ctas/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/ctas/install.sh" ]; then
      echo "Installing required dependency: ctas"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/ctas" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: audio
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/audio/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/audio/install.sh" ]; then
      echo "Installing required dependency: audio"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/audio" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: commons
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/commons/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/commons/install.sh" ]; then
      echo "Installing required dependency: commons"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/commons" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
  fi
fi
if [ -f "$SCRIPT_DIR/sections/banner/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/banner/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    # Install dependency if needed: ctas
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/ctas/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/ctas/install.sh" ]; then
      echo "Installing required dependency: ctas"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/ctas" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: text
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/text/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/text/install.sh" ]; then
      echo "Installing required dependency: text"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/text" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: image
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/image/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/image/install.sh" ]; then
      echo "Installing required dependency: image"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/image" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: commons
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/commons/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/commons/install.sh" ]; then
      echo "Installing required dependency: commons"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/commons" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
  fi
fi
if [ -f "$SCRIPT_DIR/sections/blog-author/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/blog-author/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    # Install dependency if needed: text
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/text/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/text/install.sh" ]; then
      echo "Installing required dependency: text"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/text" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: image
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/image/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/image/install.sh" ]; then
      echo "Installing required dependency: image"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/image" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: commons
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/commons/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/commons/install.sh" ]; then
      echo "Installing required dependency: commons"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/commons" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
  fi
fi
if [ -f "$SCRIPT_DIR/sections/blurbs/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/blurbs/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    # Install dependency if needed: ctas
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/ctas/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/ctas/install.sh" ]; then
      echo "Installing required dependency: ctas"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/ctas" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: text
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/text/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/text/install.sh" ]; then
      echo "Installing required dependency: text"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/text" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: image
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/image/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/image/install.sh" ]; then
      echo "Installing required dependency: image"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/image" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: icon
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/icon/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/icon/install.sh" ]; then
      echo "Installing required dependency: icon"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/icon" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: commons
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/commons/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/commons/install.sh" ]; then
      echo "Installing required dependency: commons"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/commons" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
  fi
fi
if [ -f "$SCRIPT_DIR/sections/calendar/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/calendar/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    # Install dependency if needed: text
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/text/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/text/install.sh" ]; then
      echo "Installing required dependency: text"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/text" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: commons
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/commons/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/commons/install.sh" ]; then
      echo "Installing required dependency: commons"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/commons" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
  fi
fi
if [ -f "$SCRIPT_DIR/sections/cards-list/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/cards-list/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    # Install dependency if needed: text
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/text/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/text/install.sh" ]; then
      echo "Installing required dependency: text"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/text" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: manual-card
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/manual-card/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/manual-card/install.sh" ]; then
      echo "Installing required dependency: manual-card"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/manual-card" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
  fi
fi
if [ -f "$SCRIPT_DIR/sections/code/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/code/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    # Install dependency if needed: commons
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/commons/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/commons/install.sh" ]; then
      echo "Installing required dependency: commons"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/commons" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
  fi
fi
if [ -f "$SCRIPT_DIR/sections/columns/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/columns/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    # Install dependency if needed: commons
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/commons/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/commons/install.sh" ]; then
      echo "Installing required dependency: commons"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/commons" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
  fi
fi
if [ -f "$SCRIPT_DIR/sections/compound/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/compound/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    # Install dependency if needed: commons
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/commons/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/commons/install.sh" ]; then
      echo "Installing required dependency: commons"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/commons" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: text
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/text/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/text/install.sh" ]; then
      echo "Installing required dependency: text"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/text" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: ctas
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/ctas/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/ctas/install.sh" ]; then
      echo "Installing required dependency: ctas"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/ctas" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
  fi
fi
if [ -f "$SCRIPT_DIR/sections/flip-cards/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/flip-cards/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    # Install dependency if needed: ctas
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/ctas/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/ctas/install.sh" ]; then
      echo "Installing required dependency: ctas"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/ctas" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: text
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/text/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/text/install.sh" ]; then
      echo "Installing required dependency: text"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/text" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: image
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/image/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/image/install.sh" ]; then
      echo "Installing required dependency: image"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/image" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: commons
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/commons/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/commons/install.sh" ]; then
      echo "Installing required dependency: commons"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/commons" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
  fi
fi
if [ -f "$SCRIPT_DIR/sections/header/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/header/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    # Install dependency if needed: branding
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/branding/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/branding/install.sh" ]; then
      echo "Installing required dependency: branding"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/branding" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: navigation
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/navigation/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/navigation/install.sh" ]; then
      echo "Installing required dependency: navigation"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/navigation" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
  fi
fi
if [ -f "$SCRIPT_DIR/sections/hero/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/hero/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    # Install dependency if needed: ctas
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/ctas/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/ctas/install.sh" ]; then
      echo "Installing required dependency: ctas"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/ctas" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: text
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/text/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/text/install.sh" ]; then
      echo "Installing required dependency: text"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/text" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: image
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/image/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/image/install.sh" ]; then
      echo "Installing required dependency: image"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/image" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: commons
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/commons/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/commons/install.sh" ]; then
      echo "Installing required dependency: commons"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/commons" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
  fi
fi
if [ -f "$SCRIPT_DIR/sections/hero-slider/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/hero-slider/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    # Install dependency if needed: ctas
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/ctas/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/ctas/install.sh" ]; then
      echo "Installing required dependency: ctas"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/ctas" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: text
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/text/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/text/install.sh" ]; then
      echo "Installing required dependency: text"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/text" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: image
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/image/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/image/install.sh" ]; then
      echo "Installing required dependency: image"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/image" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: video
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/video/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/video/install.sh" ]; then
      echo "Installing required dependency: video"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/video" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: commons
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/commons/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/commons/install.sh" ]; then
      echo "Installing required dependency: commons"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/commons" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
  fi
fi
if [ -f "$SCRIPT_DIR/sections/icon-only/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/icon-only/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    # Install dependency if needed: ctas
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/ctas/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/ctas/install.sh" ]; then
      echo "Installing required dependency: ctas"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/ctas" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: icon
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/icon/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/icon/install.sh" ]; then
      echo "Installing required dependency: icon"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/icon" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: commons
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/commons/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/commons/install.sh" ]; then
      echo "Installing required dependency: commons"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/commons" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
  fi
fi
if [ -f "$SCRIPT_DIR/sections/image-compare/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/image-compare/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    # Install dependency if needed: image
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/image/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/image/install.sh" ]; then
      echo "Installing required dependency: image"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/image" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: icon
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/icon/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/icon/install.sh" ]; then
      echo "Installing required dependency: icon"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/icon" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: commons
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/commons/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/commons/install.sh" ]; then
      echo "Installing required dependency: commons"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/commons" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
  fi
fi
if [ -f "$SCRIPT_DIR/sections/image-only/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/image-only/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    # Install dependency if needed: ctas
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/ctas/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/ctas/install.sh" ]; then
      echo "Installing required dependency: ctas"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/ctas" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: image
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/image/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/image/install.sh" ]; then
      echo "Installing required dependency: image"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/image" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: commons
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/commons/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/commons/install.sh" ]; then
      echo "Installing required dependency: commons"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/commons" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
  fi
fi
if [ -f "$SCRIPT_DIR/sections/logos-list/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/logos-list/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    # Install dependency if needed: commons
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/commons/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/commons/install.sh" ]; then
      echo "Installing required dependency: commons"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/commons" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: image
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/image/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/image/install.sh" ]; then
      echo "Installing required dependency: image"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/image" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: icon
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/icon/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/icon/install.sh" ]; then
      echo "Installing required dependency: icon"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/icon" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: text
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/text/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/text/install.sh" ]; then
      echo "Installing required dependency: text"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/text" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: ctas
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/ctas/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/ctas/install.sh" ]; then
      echo "Installing required dependency: ctas"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/ctas" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
  fi
fi
if [ -f "$SCRIPT_DIR/sections/lottie-only/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/lottie-only/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    # Install dependency if needed: ctas
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/ctas/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/ctas/install.sh" ]; then
      echo "Installing required dependency: ctas"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/ctas" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: lottie
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/lottie/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/lottie/install.sh" ]; then
      echo "Installing required dependency: lottie"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/lottie" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: commons
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/commons/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/commons/install.sh" ]; then
      echo "Installing required dependency: commons"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/commons" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
  fi
fi
if [ -f "$SCRIPT_DIR/sections/maps/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/maps/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    # Install dependency if needed: ctas
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/ctas/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/ctas/install.sh" ]; then
      echo "Installing required dependency: ctas"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/ctas" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: text
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/text/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/text/install.sh" ]; then
      echo "Installing required dependency: text"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/text" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: commons
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/commons/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/commons/install.sh" ]; then
      echo "Installing required dependency: commons"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/commons" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
  fi
fi
if [ -f "$SCRIPT_DIR/sections/multi-media/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/multi-media/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    # Install dependency if needed: ctas
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/ctas/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/ctas/install.sh" ]; then
      echo "Installing required dependency: ctas"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/ctas" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: text
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/text/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/text/install.sh" ]; then
      echo "Installing required dependency: text"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/text" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: image
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/image/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/image/install.sh" ]; then
      echo "Installing required dependency: image"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/image" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: video
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/video/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/video/install.sh" ]; then
      echo "Installing required dependency: video"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/video" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: audio
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/audio/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/audio/install.sh" ]; then
      echo "Installing required dependency: audio"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/audio" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: icon
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/icon/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/icon/install.sh" ]; then
      echo "Installing required dependency: icon"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/icon" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: lottie
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/lottie/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/lottie/install.sh" ]; then
      echo "Installing required dependency: lottie"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/lottie" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: commons
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/commons/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/commons/install.sh" ]; then
      echo "Installing required dependency: commons"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/commons" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
  fi
fi
if [ -f "$SCRIPT_DIR/sections/podcast/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/podcast/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    # Install dependency if needed: ctas
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/ctas/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/ctas/install.sh" ]; then
      echo "Installing required dependency: ctas"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/ctas" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: commons
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/commons/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/commons/install.sh" ]; then
      echo "Installing required dependency: commons"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/commons" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
  fi
fi
if [ -f "$SCRIPT_DIR/sections/search-only/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/search-only/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    # Install dependency if needed: search
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/search/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/search/install.sh" ]; then
      echo "Installing required dependency: search"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/search" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: text
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/text/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/text/install.sh" ]; then
      echo "Installing required dependency: text"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/text" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: commons
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/commons/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/commons/install.sh" ]; then
      echo "Installing required dependency: commons"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/commons" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
  fi
fi
if [ -f "$SCRIPT_DIR/sections/simple-accordion/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/simple-accordion/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    # Install dependency if needed: text
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/text/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/text/install.sh" ]; then
      echo "Installing required dependency: text"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/text" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: ctas
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/ctas/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/ctas/install.sh" ]; then
      echo "Installing required dependency: ctas"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/ctas" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: commons
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/commons/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/commons/install.sh" ]; then
      echo "Installing required dependency: commons"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/commons" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
  fi
fi
if [ -f "$SCRIPT_DIR/sections/slider/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/slider/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    # Install dependency if needed: ctas
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/ctas/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/ctas/install.sh" ]; then
      echo "Installing required dependency: ctas"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/ctas" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: text
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/text/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/text/install.sh" ]; then
      echo "Installing required dependency: text"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/text" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: image
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/image/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/image/install.sh" ]; then
      echo "Installing required dependency: image"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/image" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: commons
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/commons/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/commons/install.sh" ]; then
      echo "Installing required dependency: commons"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/commons" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: slider-pagination
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/slider-pagination/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/slider-pagination/install.sh" ]; then
      echo "Installing required dependency: slider-pagination"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/slider-pagination" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
  fi
fi
if [ -f "$SCRIPT_DIR/sections/testimonial/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/testimonial/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    # Install dependency if needed: ctas
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/ctas/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/ctas/install.sh" ]; then
      echo "Installing required dependency: ctas"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/ctas" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: text
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/text/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/text/install.sh" ]; then
      echo "Installing required dependency: text"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/text" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: image
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/image/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/image/install.sh" ]; then
      echo "Installing required dependency: image"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/image" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: commons
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/commons/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/commons/install.sh" ]; then
      echo "Installing required dependency: commons"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/commons" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
  fi
fi
if [ -f "$SCRIPT_DIR/sections/text-only/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/text-only/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    # Install dependency if needed: ctas
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/ctas/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/ctas/install.sh" ]; then
      echo "Installing required dependency: ctas"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/ctas" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: text
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/text/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/text/install.sh" ]; then
      echo "Installing required dependency: text"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/text" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: commons
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/commons/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/commons/install.sh" ]; then
      echo "Installing required dependency: commons"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/commons" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
  fi
fi
if [ -f "$SCRIPT_DIR/sections/video-only/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/video-only/manifest.json" ]; then
    # Component not installed, skip in update mode
    true
  else
    # Install dependency if needed: ctas
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/ctas/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/ctas/install.sh" ]; then
      echo "Installing required dependency: ctas"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/ctas" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: video
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/video/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/video/install.sh" ]; then
      echo "Installing required dependency: video"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/video" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
    # Install dependency if needed: commons
    if [ ! -f "$COMPONENTS_BASE/$PARTIALS_DIR/commons/manifest.json" ] && [ -f "$SCRIPT_DIR/partials/commons/install.sh" ]; then
      echo "Installing required dependency: commons"
      cd "$PROJECT_ROOT"
      (cd "$SCRIPT_DIR/partials/commons" && ./install.sh)
      INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
      echo ""
    fi
  fi
fi

if [ -f "$SCRIPT_DIR/sections/audio-only/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/audio-only/manifest.json" ]; then
    echo "⊘ Skipping audio-only (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing audio-only..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/sections/audio-only" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/sections/banner/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/banner/manifest.json" ]; then
    echo "⊘ Skipping banner (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing banner..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/sections/banner" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/sections/blog-author/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/blog-author/manifest.json" ]; then
    echo "⊘ Skipping blog-author (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing blog-author..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/sections/blog-author" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/sections/blog-navigation/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/blog-navigation/manifest.json" ]; then
    echo "⊘ Skipping blog-navigation (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing blog-navigation..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/sections/blog-navigation" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/sections/blurbs/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/blurbs/manifest.json" ]; then
    echo "⊘ Skipping blurbs (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing blurbs..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/sections/blurbs" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/sections/calendar/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/calendar/manifest.json" ]; then
    echo "⊘ Skipping calendar (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing calendar..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/sections/calendar" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/sections/cards-list/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/cards-list/manifest.json" ]; then
    echo "⊘ Skipping cards-list (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing cards-list..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/sections/cards-list" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/sections/code/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/code/manifest.json" ]; then
    echo "⊘ Skipping code (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing code..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/sections/code" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/sections/collection-list/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/collection-list/manifest.json" ]; then
    echo "⊘ Skipping collection-list (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing collection-list..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/sections/collection-list" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/sections/columns/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/columns/manifest.json" ]; then
    echo "⊘ Skipping columns (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing columns..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/sections/columns" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/sections/commons/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/commons/manifest.json" ]; then
    echo "⊘ Skipping commons (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing commons..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/sections/commons" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/sections/compound/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/compound/manifest.json" ]; then
    echo "⊘ Skipping compound (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing compound..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/sections/compound" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/sections/flip-cards/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/flip-cards/manifest.json" ]; then
    echo "⊘ Skipping flip-cards (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing flip-cards..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/sections/flip-cards" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/sections/footer/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/footer/manifest.json" ]; then
    echo "⊘ Skipping footer (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing footer..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/sections/footer" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/sections/header/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/header/manifest.json" ]; then
    echo "⊘ Skipping header (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing header..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/sections/header" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/sections/hero/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/hero/manifest.json" ]; then
    echo "⊘ Skipping hero (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing hero..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/sections/hero" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/sections/hero-slider/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/hero-slider/manifest.json" ]; then
    echo "⊘ Skipping hero-slider (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing hero-slider..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/sections/hero-slider" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/sections/icon-only/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/icon-only/manifest.json" ]; then
    echo "⊘ Skipping icon-only (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing icon-only..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/sections/icon-only" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/sections/image-compare/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/image-compare/manifest.json" ]; then
    echo "⊘ Skipping image-compare (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing image-compare..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/sections/image-compare" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/sections/image-only/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/image-only/manifest.json" ]; then
    echo "⊘ Skipping image-only (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing image-only..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/sections/image-only" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/sections/logos-list/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/logos-list/manifest.json" ]; then
    echo "⊘ Skipping logos-list (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing logos-list..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/sections/logos-list" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/sections/lottie-only/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/lottie-only/manifest.json" ]; then
    echo "⊘ Skipping lottie-only (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing lottie-only..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/sections/lottie-only" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/sections/maps/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/maps/manifest.json" ]; then
    echo "⊘ Skipping maps (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing maps..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/sections/maps" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/sections/multi-media/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/multi-media/manifest.json" ]; then
    echo "⊘ Skipping multi-media (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing multi-media..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/sections/multi-media" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/sections/podcast/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/podcast/manifest.json" ]; then
    echo "⊘ Skipping podcast (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing podcast..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/sections/podcast" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/sections/search-only/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/search-only/manifest.json" ]; then
    echo "⊘ Skipping search-only (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing search-only..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/sections/search-only" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/sections/simple-accordion/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/simple-accordion/manifest.json" ]; then
    echo "⊘ Skipping simple-accordion (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing simple-accordion..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/sections/simple-accordion" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/sections/slider/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/slider/manifest.json" ]; then
    echo "⊘ Skipping slider (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing slider..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/sections/slider" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/sections/testimonial/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/testimonial/manifest.json" ]; then
    echo "⊘ Skipping testimonial (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing testimonial..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/sections/testimonial" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/sections/text-only/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/text-only/manifest.json" ]; then
    echo "⊘ Skipping text-only (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing text-only..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/sections/text-only" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

if [ -f "$SCRIPT_DIR/sections/video-only/install.sh" ]; then
  if [ "$MODE" = "update" ] && [ ! -f "$COMPONENTS_BASE/$SECTIONS_DIR/video-only/manifest.json" ]; then
    echo "⊘ Skipping video-only (not currently installed)"
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
  else
    echo "Installing video-only..."
    cd "$PROJECT_ROOT"
    (cd "$SCRIPT_DIR/sections/video-only" && ./install.sh)
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    echo ""
  fi
fi

echo ""
echo "✓ Bundle installation complete"
echo ""
echo "Installed/Updated: $INSTALLED_COUNT components"
if [ "$MODE" = "update" ] && [ $SKIPPED_COUNT -gt 0 ]; then
  echo "Skipped: $SKIPPED_COUNT components (not previously installed)"
fi
echo ""
echo "See individual README files for usage instructions."
