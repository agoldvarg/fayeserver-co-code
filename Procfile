web:  bundle exec rackup private_pub.ru -s thin -p $PORT -E production
resque: env TERM_CHILD=1 QUEUE='*' bundle exec rake resque:work