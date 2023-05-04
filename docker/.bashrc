alias s='/manage.py shell_plus --quiet-load'
alias packages='cd /usr/local/lib/python3.10/site-packages/'
alias cs='python /manage.py collectstatic --noinput -i node_modules -v 3'
alias psql='PGPASSWORD=postgres psql -h db -d sis -U postgres'
PS1='\[\033[0;36m\]tracking (${ENVIRONMENT}) \033[0;33m\]\w \[\033[m\]$';