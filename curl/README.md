# Curl

# Index
- [Standard curl](#standard-curl)
- [Certificate validation](#certificate-validation)
- [Performance monitoring with curl](#performance-monitoring-with-curl)

## Standard curl
```
curl -vko /dev/null https://github.com
```

## Certificate validation
```
openssl s_client -connect https://github.com </dev/null 2>/dev/null | openssl x509 -noout -text | grep DNS:
```

## Performance monitoring with curl

#### Single run
```
curl -kw "time_namelookup:  %{time_namelookup} \
            \ntime_connect:  %{time_connect} \
            \ntime_appconnect:  %{time_appconnect} \
            \ntime_pretransfer:  %{time_pretransfer} \
            \ntime_redirect:  %{time_redirect} \
            \ntime_starttransfer:  %{time_starttransfer} \
            \n----------\ntime_total:  %{time_total} \
            \n" -o /dev/null -s "https://github.com/"
```

#### Continuos monitoring with [watch](https://linux.die.net/man/1/watch)
```
watch -d -c -n 2 'curl -kw "time_namelookup:  %{time_namelookup}\ntime_connect:  %{time_connect}\ntime_appconnect:  %{time_appconnect}\ntime_pretransfer:  %{time_pretransfer}\ntime_redirect:  %{time_redirect}\ntime_starttransfer:  %{time_starttransfer}\n----------\ntime_total:  %{time_total}\n" -o /dev/null -s "https://github.com/"'
```
