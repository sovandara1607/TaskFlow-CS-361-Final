# TaskFlow API

Laravel backend for the TaskFlow app.

## Setup

1. Make sure these are installed:
	- PHP 8.2+
	- Composer
	- Node.js + npm

2. From this folder, run the one-step setup:

	```bash
	composer run setup
	```

	This installs dependencies, creates `.env` if missing, generates the app key, runs migrations, installs npm packages, and builds assets.

3. Start the API:

	```bash
	php artisan serve
	```

## Configuration

1. Open `.env` and set your base app values:

	```env
	APP_NAME=TaskFlow
	APP_ENV=local
	APP_DEBUG=true
	APP_URL=http://127.0.0.1:8000
	```

2. Choose your database.

	SQLite (default):

	```env
	DB_CONNECTION=sqlite
	```

	Make sure `database/database.sqlite` exists, then run:

	```bash
	php artisan migrate
	```

	MySQL (optional):

	```env
	DB_CONNECTION=mysql
	DB_HOST=127.0.0.1
	DB_PORT=3306
	DB_DATABASE=taskflow
	DB_USERNAME=
	DB_PASSWORD=
	```

	Then run:

	```bash
	php artisan migrate
	```

3. If you use GitHub login, add:

	```env
	GITHUB_CLIENT_ID=
	GITHUB_CLIENT_SECRET=
	GITHUB_REDIRECT_URI=
	```

4. Quick API check:

	- `GET /api/up` should return a success message.
