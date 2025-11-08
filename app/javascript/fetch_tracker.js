// Track pending fetch requests for testing purposes
// This allows the test helper wait_for_ajax to detect ongoing fetch requests

if (typeof window !== 'undefined') {
  window.pendingFetchCount = 0;

  // Store the original fetch
  const originalFetch = window.fetch;

  // Override fetch to track pending requests
  window.fetch = function(...args) {
    window.pendingFetchCount++;

    return originalFetch.apply(this, args)
      .then((response) => {
        window.pendingFetchCount--;
        return response;
      })
      .catch((error) => {
        window.pendingFetchCount--;
        throw error;
      });
  };
}

export {};
