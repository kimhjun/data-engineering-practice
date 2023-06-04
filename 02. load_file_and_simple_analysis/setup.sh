# Download data
curl -O https://www.postgresqltutorial.com/wp-content/uploads/2019/05/dvdrental.zip 
unzip dvdrental.zip
pg_restore -U junn -d dvdrental dvdrental.tar
