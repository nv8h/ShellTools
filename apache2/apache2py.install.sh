#!/bin/sh

# Url: https://library.linode.com/frameworks/django-apache-mod-wsgi/ubuntu-10.04-lucid

sudo apt-get install apache2 phpmyadmin mysql-server libapache2-mod-python
sudo apt-get install python python-mysqldb python-xml python-setuptools libapache2-mod-wsgi
sudo apt-get install python-pip
sudo apt-get install sqlite3 python-sqlite python-django

#pip install django