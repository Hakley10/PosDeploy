import { config } from 'dotenv';
import { EnvironmentPlugin } from 'webpack';

config();

module.exports = {
    plugins: [
        new EnvironmentPlugin({
            API_BASE_URL: 'https://api.198-199-91-11.sslip.io/api',
            FILE_BASE_URL: 'https://file.198-199-91-11.sslip.io',
            WEB_BASE_URL: 'https://posdeploy1.pages.dev/',
            SOCKET_URL: 'https://api.198-199-91-11.sslip.io',
        })
    ]
};
