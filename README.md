# Git Changed Notifier

A lightweight Docker-based script that checks for changes in a Git repository and sends email notifications when changes are detected. Designed for CI pipelines or scheduled tasks.

---

## What It Does

- Checks a specific file in a Git repo by comparing hashes
- Loads environment variables from a `.env` file
- Sends email alerts using `msmtp`
- Logs all output (stdout and stderr) to a file inside the container

---

## How to Run It

Copy the `.env.example` file to `.env` and modify it as needed. Alternatively,
create the file from scratch using the following template:

```bash
REPO_URL=https://github.com/mtak/gitchanged.git
WATCH_FILE=README.md

RECIPIENT=yourmail@example.com
SMTP_SERVER=smtp.example.com
SMTP_PORT=587
SMTP_USER=your-smtp-user@example.com
SMTP_PASS=your-smtp-password
```

Create a `data/` directory to keep logging and state in

```bash
mkdir data
```

Run the script as many times as needed using:

```
docker run --rm \
  --env-file .env \
  -v $PWD/data:/app/data/ \
  --user $UID \
  merijntjetak/gitchanged:latest
```

You can have multiple `.env` files for multiple files you want to monitor. Just invoke the
container for each `.env` file.

Log output is available in the `data/` directory.

