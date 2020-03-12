---
layout: article
title: "Oath: Don't Loose Your Keys!"
description: A ZSH plugin for handling your keys.
handle: alex
image: keys.png
author: Alex de Sousa
---

Recently, I needed to reset my phone. I spent some time backing up my pictures and documents. Everything was going great. But then, I hit a roadblock.

## The problem

One-time passwords have become very handy for logging into several sites from Twitter to Coinbase. This passwords are 6 digit tokens generated using the current time and a private key. I was using Google Authenticator for getting my one-time passwords. Sadly, this app does not provide a way to backup the private keys.

The damage was done. I couldn't retrieve the private keys, so I needed to regenerate all of them in every site individually. I thought about my future self dealing with the same issue and I knew I needed a sustainable solution.

![Let's change the lightbulb](https://media.giphy.com/media/llbEoVMhkLngWlzVVa/giphy.gif)

## The research

I wanted a one-time password solution that:

- Didn't rely on my phone or any app.
- Could also be used in my computer.
- Was offline (no private keys stored in the cloud).

That's when I discovered `oathtool`: a command line tool for generating 6 digit tokens given a private key.

> I installed it using `sudo apt install oathtool`

Generating a 6 digit token with `oathtool` is as easy as doing the following:

```bash
$ oathtool -b --totp 'MyPrivateKey'
798946
```

Discovering this tool was a good start, but I needed a good way of dealing with the private keys. Then I stumbled upon [this article](https://www.cyberciti.biz/faq/use-oathtool-linux-command-line-for-2-step-verification-2fa/). The author created two scripts:

- One for encrypting the private key into a file using `gpg2`.
- One for decrypting the private key and retrieving the 6 digit token using `oathtool`.

Additionally, the 6 digit token was automatically copied to the clipboard using `xclip`.

> I installed both tools by running `sudo apt install gnupg2 xclip`

I loved the solution! Though it had some flaws like storing temporarily an unencrypted file with the private key, it was a great idea :)

![Great idea](https://media.giphy.com/media/Mjq9vmDuJlBKw/giphy.gif)

## The plugin

I wrote [Oath ZSH plugin](https://github.com/alexdesousa/oath) by gathering the best ideas from that article. I ended up with the following commands:

- Adding a private key:

   ```bash
   $ oath add twitter.com
   Private key:
   [SUCCESS]  Key created for twitter.com
   ```

- Showing a 6 digit token (it'll ask for the gpg password):

   ```bash
   $ oath twitter.com
   123456
   [SUCCESS]  Code copied to clipboard
   ```

- Deleting a private key (it'll ask for the gpg password):

   ```bash
   $ oath delete twitter.com
   [WARN]     Deleting /home/user/.oath/twitter.com/B743BC73B5F90E2305142D226BBCD02E89ABBC79.gpg.gpg
   [WARN]     Deleting /home/user/.oath/twitter.com
   [SUCCESS]  Key deleted for twitter.com
   ```

The same private keys I added to `oath`, I also added them to my phone's Google Authenticator app. That way both, my computer and phone, generate the same 6 digit token at a given time.

The only difference is that now I can backup everything. I just need to copy the following folders:

- `$HOME/.gnupg/`: GPG folder with all the gpg keys.
- `$HOME/.oath/`: Oath folder where all the private keys are stored.

> For more info, visit [Oath Github repository](https://github.com/alexdesousa/oath).

![Safety](https://media.giphy.com/media/Xd1EhywNhOjq5EPn5t/giphy.gif)

## Conclusion

Though this solution might not be for everyone, it solves the problem I had. Now I can reset my phone at any time and not worrying about my private keys, because they're safely backed up.

![The keys](https://media.giphy.com/media/de0AlLgV7XTRhEudoL/giphy.gif)

Happy hacking!
