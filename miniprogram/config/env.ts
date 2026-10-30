export type Environment = 'dev' | 'prod';

const environment: Environment = 'dev';

const environments = {
  dev: {
    apiBaseUrl: 'https://dev-api.example.invalid',
    socketUrl: 'wss://dev-api.example.invalid/events'
  },
  prod: {
    apiBaseUrl: 'https://api.example.invalid',
    socketUrl: 'wss://api.example.invalid/events'
  }
} as const;

export const config = {
  environment,
  appId: 'YOUR_WECHAT_APP_ID',
  ...environments[environment]
};
