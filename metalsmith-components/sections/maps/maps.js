/**
 * Unified Mapping Component
 * Supports both Leaflet and OpenLayers providers with modular architecture
 */

import { initLeafletMaps } from './modules/providers/leaflet.js';
import { initOpenLayersMaps } from './modules/providers/openlayers.js';

/**
 * Provider factory
 */
const providers = {
  leaflet: initLeafletMaps,
  openlayers: initOpenLayersMaps
};

/**
 * Initialize maps component
 */
const initMapsComponent = () => {
  /**
   * Initialize all maps based on provider
   */
  const initAllMaps = async () => {
    const leafletMaps = document.querySelectorAll('.js-leaflet-map');
    const openLayersMaps = document.querySelectorAll('.js-openlayers-map');

    const promises = [];

    if (leafletMaps.length > 0) {
      promises.push(providers.leaflet());
    }

    if (openLayersMaps.length > 0) {
      promises.push(providers.openlayers());
    }

    try {
      const results = await Promise.all(promises);
      const allInstances = results.flat();
      // console.log(`Initialized ${allInstances.length} map instances`);
      return allInstances;
    } catch (error) {
      console.error('Failed to initialize maps components:', error);
      return [];
    }
  };

  // Initialize on DOM ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initAllMaps);
  } else {
    initAllMaps();
  }
};

// Auto-initialize
initMapsComponent();