# Mutt
Docker based command line mail sender. For more syntax see mutt manual.
# Installation
* Rename .env.gmail to .env
* Fill user, password and email in .env
# Usage
Send current directory list to my-email@gmail.com
```
ls | ./app.sh -s "Subject" my-email@gmail.com
```
