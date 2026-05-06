import { config } from 'dotenv';
import { EnvironmentPlugin } from 'webpack';

config();

module.exports = {
    plugins: [
        new EnvironmentPlugin({
            API_BASE_URL: 'https://api.henghakley.com/api',
            FILE_BASE_URL: 'http://localhost:3000/files',
        })
    ]
};