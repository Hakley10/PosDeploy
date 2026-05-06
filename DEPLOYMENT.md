# POS Deployment

Frontend:

- Cloudflare Pages: `https://posdeploy1.pages.dev/`

Backend on the DigitalOcean droplet:

- API public URL: `https://api.198-199-91-11.sslip.io/api`
- File public URL: `https://file.198-199-91-11.sslip.io/`
- jsreport public URL: `https://report.198-199-91-11.sslip.io/`

The droplet shown in DigitalOcean is:

- Public IPv4: `198.199.91.11`
- Ubuntu: `24.04 LTS`

## 1. Create production environment

On the droplet, create `/opt/pos/.env`. A template is included at `deploy/digitalocean/pos.env.example`.

Example:

```dotenv
API_DOMAIN=api.198-199-91-11.sslip.io
FILE_DOMAIN=file.198-199-91-11.sslip.io
REPORT_DOMAIN=report.198-199-91-11.sslip.io
HTTP_PUBLIC_PORT=80
HTTPS_PUBLIC_PORT=443
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

Use the real values from your local `api-v4/.env` and `file-v3/.env`. Do not commit production `.env` files.

## 2. Deploy from source

Because the droplet is only `512 MB`, add swap before building. Run this once in the DigitalOcean Web Console:

```sh
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

Then deploy or update the backend services:

```sh
curl -fsSL https://raw.githubusercontent.com/Hakley10/PosDeploy/main/deploy/digitalocean/deploy-api-file-from-source.sh | sudo sh
```

The script clones/pulls `https://github.com/Hakley10/PosDeploy.git`, installs Docker if needed, builds `api-v4` and `file-v3`, starts `jsreport`, and puts Caddy in front for HTTPS.

```sh
docker compose --env-file /opt/pos/.env -f docker-compose.api-file.yml up -d --build pos_file pos_report pos_api pos_proxy
```

## 3. Check services

```sh
docker ps
curl https://api.198-199-91-11.sslip.io/api
curl https://file.198-199-91-11.sslip.io/
curl http://127.0.0.1:8080/
```

## 4. Frontend settings

The frontend build defaults are configured for:

- `API_BASE_URL=https://api.198-199-91-11.sslip.io/api`
- `FILE_BASE_URL=https://file.198-199-91-11.sslip.io/`
- `WEB_BASE_URL=https://posdeploy1.pages.dev/`
- `SOCKET_URL=https://api.198-199-91-11.sslip.io`

Cloudflare Pages must redeploy `web-v4` after these changes are pushed.

## 5. Important security cleanup

Rotate any secrets that were previously committed to the repository, especially bot tokens, report credentials, and database passwords. Keep production values only in GitLab CI/CD variables or `/opt/pos/.env`.
