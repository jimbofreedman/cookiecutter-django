#!/bin/bash

mkvirtualenv -p /usr/bin/python3.4 {{cookiecutter.project_name}}
sudo ./install_os_dependencies.sh install && \
pip install -r requirements/local.txt && \
sudo npm install -g grunt-cli && \
python manage.py makemigrations && \
python manage.py migrate && \
python manage.py createsuperuser && \
npm install && \
sudo docker run -d -p 1025:1025 -p 8025:8025 mailhog/mailhog && \
#grunt serve
git init && \

echo 'Heroku name?' && \
read heroku_name && \


echo 'Heroku region?' && \
read heroku_region && \

heroku create --region $heroku_region --buildpack https://github.com/heroku/heroku-buildpack-python $heroku_name && \

echo 'Daily DB backup hour (UTC)?' && \
read heroku_db_backup_time && \

heroku addons:create heroku-postgresql:hobby-dev && \
heroku pg:backups schedule --at "$heroku_db_backup_time:00 UTC" DATABASE_URL && \
heroku pg:promote DATABASE_URL && \

heroku addons:create heroku-redis:hobby-dev && \
heroku addons:create mailgun && \

heroku config:set DJANGO_ADMIN_URL=`openssl rand -base64 32` && \
heroku config:set DJANGO_SECRET_KEY=`openssl rand -base64 64` && \
heroku config:set DJANGO_SETTINGS_MODULE='config.settings.production' && \
heroku config:set DJANGO_ALLOWED_HOSTS='.herokuapp.com' && \

echo 'AWS access key?' && \
read aws_access_key && \
echo 'AWS secret access key?' && \
read aws_secret_access_key && \
echo 'AWS S3 bucket name?' && \
read aws_s3_bucket_name && \

heroku config:set DJANGO_AWS_ACCESS_KEY_ID=$aws_access_key && \
heroku config:set DJANGO_AWS_SECRET_ACCESS_KEY=$aws_secret_access_key && \
heroku config:set DJANGO_AWS_STORAGE_BUCKET_NAME=$aws_s3_bucket_name && \

echo 'Mailgun Server Name?' && \
read django_mailgun_server_name && \
echo 'Mailgun API Key?' && \
read django_mailgun_api_key && \

heroku config:set DJANGO_MAILGUN_SERVER_NAME=$django_mailgun_api_key && \
heroku config:set DJANGO_MAILGUN_API_KEY=$django_mailgun_api_key && \

echo 'Opbeat App id?' && \
read opbeat_app_id && \
echo 'Opbeat Organization id?' && \
read opbeat_organization_id && \
echo 'Opbeat Secret Token?' && \
read opbeat_secret_token && \
echo 'Opbeat Webhook URL?' && \
read opbeat_webhook_url && \

heroku config:set DJANGO_OPBEAT_APP_ID=$opbeat_app_id && \
heroku config:set DJANGO_OPBEAT_ORGANIZATION_ID=$opbeat_organization_id && \
heroku config:set DJANGO_OPBEAT_SECRET_TOKEN=$opbeat_secret_token && \
heroku addons:create deployhooks:http --url=$opbeat_webhook_url && \

heroku config:set PYTHONHASHSEED=random && \
#heroku config:set DJANGO_ADMIN_URL=\^admin/ && \

git add --all && \
git commit -m "Initial commit (from cookiecutter)" && \
echo 'Git repo URL?' && \
read git_repo_url && \
git remote add origin $git_repo_url
git push -u origin master && \
git push heroku master && \
heroku run python manage.py migrate && \
heroku run python manage.py check --deploy && \
heroku run python manage.py createsuperuser && \
heroku open