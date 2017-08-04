#!/bin/sh

# ENV
export DOMAIN

DOMAIN=${DOMAIN:-$(hostname --domain)}

# Create smarty cache folder
mkdir -p /postfixadmin/templates_c

if [ ! -f "/postfixadmin/conf/config.local.php" ]; then

  if [ -z "$DBPASS" ]; then
    echo "Mariadb database password must be set !"
    exit 1
  fi

  # Local postfixadmin configuration file
  cat > /postfixadmin/conf/config.local.php <<EOF
<?php

\$CONF['configured'] = true;

\$CONF['database_type'] = 'mysqli';
\$CONF['database_host'] = '${DBHOST}';
\$CONF['database_user'] = '${DBUSER}';
\$CONF['database_password'] = '${DBPASS}';
\$CONF['database_name'] = '${DBNAME}';

\$CONF['encrypt'] = 'dovecot:SHA512-CRYPT';
\$CONF['dovecotpw'] = "/usr/bin/doveadm pw";

\$CONF['smtp_server'] = '${SMTPHOST}';
\$CONF['domain_path'] = 'YES';
\$CONF['domain_in_mailbox'] = 'NO';
\$CONF['fetchmail'] = 'YES';
\$CONF['sendmail'] = 'NO';

\$CONF['admin_email'] = 'admin@${DOMAIN}';
\$CONF['footer_text'] = 'Return to ${DOMAIN}';
\$CONF['footer_link'] = 'http://${DOMAIN}';
\$CONF['default_aliases'] = array (
  'abuse'      => 'abuse@${DOMAIN}',
  'hostmaster' => 'hostmaster@${DOMAIN}',
  'postmaster' => 'postmaster@${DOMAIN}',
  'webmaster'  => 'webmaster@${DOMAIN}'
);

\$CONF['quota'] = 'YES';
\$CONF['domain_quota'] = 'YES';
\$CONF['quota_multiplier'] = '1024000';
\$CONF['used_quotas'] = 'YES';
\$CONF['new_quota_table'] = 'YES';

\$CONF['aliases'] = '0';
\$CONF['mailboxes'] = '0';
\$CONF['maxquota'] = '0';
\$CONF['domain_quota_default'] = '0';
?>
EOF

fi

# Set permissions
chown -R $UID:$GID /postfixadmin /etc/nginx /etc/php7 /var/log /var/lib/nginx /tmp /etc/s6.d


# RUN !
exec su-exec $UID:$GID /bin/s6-svscan /etc/s6.d
