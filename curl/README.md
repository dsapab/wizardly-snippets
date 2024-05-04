# Wizardly Snippets - Curl

## Standard curl
curl -vko /dev/null https://leadlabs-gateway.eu-west-1.elasticbeanstalk.com

## Cert validation
openssl s_client -connect curl-tooling.eba-ji3emggu.eu-west-1.elasticbeanstalk.com/:443 </dev/null 2>/dev/null | openssl x509 -noout -text | grep DNS:

## Performance monitoring

# Single Run
curl -kw "time_namelookup:  %{time_namelookup}\ntime_connect:  %{time_connect}\ntime_appconnect:  %{time_appconnect}\ntime_pretransfer:  %{time_pretransfer}\ntime_redirect:  %{time_redirect}\ntime_starttransfer:  %{time_starttransfer}\n----------\ntime_total:  %{time_total}\n" -o /dev/null -s "http://github.com/"

# Monitoring
watch -d -c -n 2 'curl -kw "time_namelookup:  %{time_namelookup}\ntime_connect:  %{time_connect}\ntime_appconnect:  %{time_appconnect}\ntime_pretransfer:  %{time_pretransfer}\ntime_redirect:  %{time_redirect}\ntime_starttransfer:  %{time_starttransfer}\n----------\ntime_total:  %{time_total}\n" -o /dev/null -s "http://github.com/"'
