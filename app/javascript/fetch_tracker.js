// Track pending fetch requests for testing purposes
// This allows the test helper wait_for_ajax to detect ongoing fetch requests
// Only enabled in test environment to avoid production overhead

function setupFetchTracking() {
  if (typeof window === 'undefined') return;

  // Check if we're in test environment
  const isTest = document.body?.dataset.env === 'test' ||
                 document.documentElement?.dataset.env === 'test';

  if (!isTest) return;

  window.pendingFetchCount = 0;

  // Store the original fetch
  const originalFetch = window.fetch;

  // Helper to wrap response methods that consume the body
  function wrapResponse(response) {
    const bodyMethods = ['json', 'text', 'blob', 'arrayBuffer', 'formData'];

    bodyMethods.forEach(method => {
      const original = response[method];
      if (original) {
        response[method] = function(...args) {
          const promise = original.apply(this, args);
          // Keep counter incremented until body is consumed
          window.pendingFetchCount++;
          return promise.finally(() => {
            window.pendingFetchCount--;
          });
        };
      }
    });

    return response;
  }

  // Override fetch to track pending requests
  window.fetch = function(...args) {
    window.pendingFetchCount++;

    return originalFetch.apply(this, args)
      .then((response) => {
        window.pendingFetchCount--;
        return wrapResponse(response);
      })
      .catch((error) => {
        window.pendingFetchCount--;
        throw error;
      });
  };
}

// Setup after page is fully loaded (including all scripts and modules)
if (typeof document !== 'undefined') {
  // Wait for page to fully load, including ES6 modules (like Stimulus controllers)
  if (document.readyState === 'complete') {
    // Already loaded
    setupFetchTracking();
  } else {
    // Wait for everything to load
    window.addEventListener('load', setupFetchTracking);
  }
}

export {};
