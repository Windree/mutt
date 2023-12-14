# Mutt
Docker based command line mail sender.
# Installation
* Rename .env.gmail to .env
* Fill user, password and email in .env
# Usage
Send current directory list to my-email@gmail.com
```
ls | ./app.sh -s "Subject" my-email@gmail.com
```
For more syntax see [mutt manual](https://linux.die.net/man/1/mutt).
