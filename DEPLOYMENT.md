# POS Deployment

This setup deploys:

- `web-v4` to Cloudflare Pages.
- `api-v4`, `file-v3`, and `jsreport` to a DigitalOcean droplet using Docker Compose.

## 1. DigitalOcean droplet

Install Docker and the Compose plugin on the droplet, then create `/opt/pos/.env`.

Example `/opt/pos/.env`:

```dotenv
DO_REGISTRY_NAME=your-docr-registry
API_PUBLIC_PORT=8990
FILE_PUBLIC_PORT=8080
REPORT_PUBLIC_PORT=5488

DB_CONNECTION=postgres
DB_HOST=your-db-host
DB_PORT=5432
DB_USERNAME=your-db-user
DB_PASSWORD=your-db-password
DB_DATABASE=pos

JWT_SECRET=replace-me
JWT_EXPIRES=1w

FILE_BASE_URL=http://pos_file:8080
JS_BASE_URL=http://pos_report:5488
JS_USERNAME=admin
JS_PASSWORD=replace-me
JS_SESSION_SECRET=replace-me
JSREPORT_IMAGE=jsreport/jsreport:latest

JS_TEMPLATE=/Invoice/main
JS_TEMPLATE_POS=/report_sale/pdf/main
JS_TEMPLATE_CASHIER=/report_cashier/main
JS_TEMPLATE_PRODUCT=/report_product/pdf/main
JS_TEMPLATE_SALE_EXCEL=/report_sale/excel/sale-excel
JS_TEMPLATE_PRODUCT_EXCEL=/report_product/excel/product-excel

TELEGRAM_BOT_TOKEN=
TELEGRAM_CHAT_ID=
SMTP_HOST=
SMTP_PORT=
SMTP_USER=
SMTP_PASS=
```

## 2. GitLab variables

Add these variables to `api-v4` and `file-v3`:

- `DO_ACCESS_TOKEN`
- `DO_REGISTRY_NAME`
- `DO_HOST`
- `DO_SSH_USER`
- `DO_SSH_PRIVATE_KEY`

Add these variables to `web-v4`:

- `CLOUDFLARE_API_TOKEN`
- `CLOUDFLARE_ACCOUNT_ID`
- `CLOUDFLARE_PAGES_PROJECT`
- `API_BASE_URL`, for example `https://api.example.com/api`
- `FILE_BASE_URL`, for example `https://file.example.com/`
- `WEB_BASE_URL`, usually the public web URL

## 3. DNS

Recommended DNS:

- `app.example.com` -> Cloudflare Pages custom domain.
- `api.example.com` -> DigitalOcean droplet, reverse proxy to port `8990`.
- `file.example.com` -> DigitalOcean droplet, reverse proxy to port `8080`.
- `report.example.com` -> DigitalOcean droplet, reverse proxy to port `5488`.

Use HTTPS in front of the DigitalOcean services with Nginx, Caddy, Traefik, or a DigitalOcean Load Balancer.

## 4. Important security cleanup

Rotate any secrets that were previously committed to the repository, especially bot tokens, report credentials, and database passwords. Keep production values only in GitLab CI/CD variables or `/opt/pos/.env`.
