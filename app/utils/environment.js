import config from 'frontend/config/environment';

export const isTesting = config.environment === 'test';
export const isDevelopment = config.environment === 'development';
export const isProduction = config.environment === 'production';
