# Mutt
Docker based command line mail sender. The mailer can append a mark to the topic based on email contents

# Installation
* Copy `config/msmtprc.*.*` to config/msmtprc and fill with your email, user and password 

# Usage
Send current directory list to my-email@gmail.com
```
ls | ./app.sh -s "directory list" my-email@gmail.com
```
Send current directory list to my-email@gmail.com and append mark/error sign in the mail subject if the mail body contains `README.md`
```
ls | ./app.sh -s "directory list" my-email@gmail.com --success "README.md"
```

For more syntax see [mutt manual](https://linux.die.net/man/1/mutt).
