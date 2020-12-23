---
layout: post
lang: en
ref: "managing-dotfiles-with-ansible"
title: "Managing Dotfiles with Ansible"
description: "A small tutorial on how to use Ansible to manage your dotfiles."
image: dots.jpg
image_link: "https://unsplash.com/photos/flRN6KYpl1A"
image_author: "Josh Riemer"
handle: alex
---

When developers get tired of configuring again and again our machines, we tend to create a dotfiles repository.

## A Dotfiles Repository

> **Dotfiles** are commonly used for storing user preferences or preserving the state of a utility, and are frequently created implicitly by using various utilities.

It all starts with a small repository that contains configuration files for common tools e.g. `.zshrc`, `.vimrc`, etc. However, every time we configure a new machine, we need to copy those files _by hand_.

We pride ourselves with our ability to automate any task. Therefore, the next logical step for a dotfiles repository is to create a "small" shell script for automating tool installation and machine configuration.

All is well at first, but that "small" script ends up being hundreds of lines long and hard to maintain.

![This is madness](https://media.giphy.com/media/S0KRynVEROiOs/giphy.gif)

## Ansible to the Rescue

> [Ansible](https://www.ansible.com/) is an configuration management tool. It provides its own language to describe system configuration.

This is not a new idea, but it feels like one: configure your own machine the same way you configure your servers... With Ansible.

> **Note**: I'm using Debian throughout this tutorial, though the same can be accomplished with any architecture and operative system as long as Ansible is available for it.

![Where's Ansible's supersuit?](https://media.giphy.com/media/F1YaFvtJ7VlwA/giphy.gif)

### Bootstrapping Ansible

For installing and configuring stuff with Ansible, we need to first install Ansible. We can use a small shell script to accomplish this. Some of the variables like `$HOSTS` and `$PLAYBOOK` will make sense in the next sections:

```bash
#!/usr/bin/env bash

set -e

# Dotfiles' project root directory
ROOTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Host file location
HOSTS="$ROOTDIR/hosts"
# Main playbook
PLAYBOOK="$ROOTDIR/dotfiles.yml"

# Installs ansible
apt-get update && apt-get install -y ansible

# Runs Ansible playbook using our user.
ansible-playbook -i "$HOSTS" "$PLAYBOOK" --ask-become-pass

exit 0
```

Running the previous script as our sudoer user will effectively install Ansible and run our main _playbook_ with all our _roles_.

> **Playbook**: A file that defines several tasks to be executed in a target machine.
> **Role**: Organizes multiple, related tasks with the data needed to run those tasks (variables, files, templates).

### Basic Folder Structure

Once we have our bootstrap script in place, we can start writing Ansible configuration files.

In our dotfiles repository, our target is our own machine. This is very easy to define in our `hosts` file (with local connection so it doesn't require an ssh key):

```yaml
# file: hosts
[local]
localhost

[local:vars]
ansible_connection=local
```

> **Note**: In our `bootstrap.sh` script, this file is found in the variable `$HOSTS`.

Then we need a _playbook_ that lists every _role_ we want to deploy and configure in our machine.

```yaml
# file: dotfiles.yml
- name: Set up local workstation
  hosts: local
  roles:
    - role: zsh
      tags:
        - zsh
```

In our example, we'll install `zsh` role.

> **Note**: In our `bootstrap.sh` script, this files is found in the variable `$PLAYBOOK`.

In general, our folder structure would look something like:

```bash
└ dotfiles
  - bootstrap.sh
  - dotfiles.yml
  - hosts
  └ roles
    └ zsh
      └ files
        - zshrc.link
      └ tasks
        - main.yml
```

### ZSh role

The following would be our `zsh` role tasks for:

- Installing `zsh`.
- Setting it up as our default shell.
- Installing Oh-My-ZSH.
- Linking our `.zshrc` configuration file to our home folder.

{% highlight yaml %}
{% raw %}
---
# file: roles/zsh/tasks/main.yml

- name: Installs zsh | apt
  become: yes
  become_user: root
  apt:
    name: zsh
    state: present

- name: Installs curl | apt
  become: yes
  become_user: root
  apt:
    name: curl
    state: present

- name: Sets zsh as default shell for my user | command
  become: yes
  become_user: root
  command: chsh -s /bin/zsh {{ lookup('env' 'USER') }}
  register: zsh_for_user
  failed_when: zsh_for_user.rc >= 1
  changed_when: zsh_for_user.rc == 0

- name: Checks for oh-my-zsh installation | stat
  stat:
    path: "{{ lookup('env', 'HOME') }}/.oh-my-zsh"
  register: oh_my_zsh_stat

- name: Installs oh-my-zsh | raw
  raw: 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"'
  when: not oh_my_zsh_stat.stat.exists

- name: Links .zshrc file | file
  file:
    src: "{{ lookup('env', 'ROOTDIR') }}/roles/zsh/files/zshrc.link"
    dest: "{{ lookup('env', 'HOME') }}/.zshrc"
    state: link
    force: yes
{% endraw %}
{% endhighlight %}

### Running Our Bootstrap Script

Finally, we can run our script:

```bash
~/dotfiles $ chmod +x bootstrap.sh
~/dotfiles $ sudo bootstrap.sh
```

This script will:

- Install Ansible.
- Run our playbook, which means installing and configuring `zsh`.

![Unlimited power](https://media.giphy.com/media/3o84sq21TxDH6PyYms/giphy.gif)

### Conclusion

There are more cool features you can use to customize your system using Ansible. You can check my [dotfiles](https://github.com/alexdesousa/dotfiles) repository if you want to see a fully working example.

Additionally, if you want to know more about Ansible, you can check [this amazing tutorial](https://serversforhackers.com/c/an-ansible2-tutorial).

I hope you find this useful :)

![Installation](https://media.giphy.com/media/kdiLau77NE9Z8vxGSO/giphy.gif)

Happy coding!
