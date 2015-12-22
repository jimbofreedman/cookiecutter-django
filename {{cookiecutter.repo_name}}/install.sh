mkvirtualenv -p /usr/bin/python3.4 {{cookiecutter.project_name}}
sudo ./install_os_dependencies.sh install && \
pip install -r requirements/local.txt && \
sudo npm install -g grunt-cli && \
python manage.py makemigrations && \
python manage.py migrate && \
python manage.py createsuperuser && \
npm install && \

#grunt serve
git init && \

echo 'Heroku name?' && \
read heroku_name && \


echo 'Heroku region?'
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

#heroku config:set DJANGO_AWS_ACCESS_KEY_ID=YOUR_AWS_ID_HERE
#heroku config:set DJANGO_AWS_SECRET_ACCESS_KEY=YOUR_AWS_SECRET_ACCESS_KEY_HERE
#heroku config:set DJANGO_AWS_STORAGE_BUCKET_NAME=YOUR_AWS_S3_BUCKET_NAME_HERE

echo 'Mailgun Server Name?' && \
read django_mailgun_server_name && \
read 'Mailgun API Key?' && \
read django_mailgun_api_key && \

heroku config:set DJANGO_MAILGUN_SERVER_NAME=django_mailgun_api_key && \
heroku config:set DJANGO_MAILGUN_API_KEY=django_mailgun_api_key && \

heroku config:set PYTHONHASHSEED=random && \
#heroku config:set DJANGO_ADMIN_URL=\^admin/ && \

#git push -u heroku master && \
#heroku run python manage.py migrate && \
#heroku run python manage.py check --deploy && \
#heroku run python manage.py createsuperuser && \
#heroku open