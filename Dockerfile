# Utilisez une image de base Node.js
FROM node:18-alpine

# Installer MariaDB et MariaDB Client
RUN apk add --no-cache mariadb mariadb-client openrc

# Définir les variables d'environnement pour la base de données
ENV DB_HOST=localhost
ENV DB_USER=root
ENV DB_PASSWORD=password
ENV DB_NAME=database

# Configurer le répertoire de travail
WORKDIR /app

# Copier les fichiers de l'application
COPY . .

# Installer les dépendances de l'application
RUN yarn install --production

# Exposer le port 3000 pour l'application Node.js
EXPOSE 3000

# Exposer le port 3306 pour la base de données MariaDB
EXPOSE 3306

# Autoriser MariaDB à écouter sur toutes les interfaces
RUN sed -i 's/^bind-address\s*=.*/bind-address=0.0.0.0/' /etc/my.cnf.d/mariadb-server.cnf

# Configurer MariaDB pour le démarrage
RUN mkdir -p /run/mysqld && \
    chown -R mysql:mysql /run/mysqld /var/lib/mysql && \
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

# Démarrer MariaDB en arrière-plan, puis l'application Node.js
CMD ["/bin/sh", "-c", "mysqld_safe --datadir='/var/lib/mysql' & \
    sleep 5 && \
    echo \"CREATE DATABASE IF NOT EXISTS ${DB_NAME};\" | mysql -u root && \
    echo \"GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';\" | mysql -u root && \
    node src/index.js"]
