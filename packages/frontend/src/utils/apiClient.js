import axios from 'axios';

// Get API URL with production environment detection
const getApiBaseUrl = () => {
  // Check if we're in production (deployed)
  const isProduction = window.location.hostname !== 'localhost' &&
                       window.location.hostname !== '127.0.0.1';

  if (isProduction) {
    // In production, use nginx proxy (no port - goes through nginx)
    // Don't include /api here - it's added by the service methods
    return `http://${window.location.hostname}`;
  }

  // For local development
  // Try Vite variable first (for Vite builds)
  if (import.meta.env.VITE_API_URL) {
    return import.meta.env.VITE_API_URL;
  }

  // Default fallback for development
  return 'http://localhost:3002';
};

const API_URL = getApiBaseUrl();

console.log('🔧 API Client initialized with base URL:', API_URL);

// Create axios instance with API base URL
const apiClient = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  // Add a reasonable timeout
  timeout: 15000, // 15 seconds
});

// Request interceptor for adding auth token
apiClient.interceptors.request.use(
  (config) => {
    // You can add authorization headers here if needed
    const token = localStorage.getItem('auth_token');
    if (token) {
      config.headers['Authorization'] = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Response interceptor for error handling
apiClient.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    // Handle common errors
    if (error.response) {
      // Server responded with an error status code
      console.error('API Error:', error.response.status, error.response.data);
      
      // Handle 401 Unauthorized - redirect to login
      if (error.response.status === 401) {
        // Redirect to login page or refresh token
        console.warn('Session expired or unauthorized. Redirecting to login...');
        localStorage.removeItem('auth_token');
        localStorage.removeItem('auth_user');
        
        // Only redirect if not already on the login page
        if (!window.location.pathname.includes('/login')) {
          window.location.href = '/login';
        }
      }
    } else if (error.request) {
      // Request was made but no response was received
      console.error('No response received:', error.request);
    } else {
      // Something else caused the error
      console.error('Error setting up request:', error.message);
    }
    
    return Promise.reject(error);
  }
);

export default apiClient;