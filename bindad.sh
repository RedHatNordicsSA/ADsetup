#!/bin/bash

DC="192.168.56.130"

yum install sssd-ad sssd sssd-client krb5-workstation samba openldap-clients policycoreutils-python oddjob oddjob-mkhomedir pam_krb5 ntp authconfig -y

/bin/cat > /etc/resolv.conf <<EOF
search hger.org
nameserver $DC
EOF

service messagebus start
chkconfig oddjobd on
chkconfig messagebus on
chkconfig sssd on

#krb5 config

/bin/cat > /etc/krb5.conf <<EOF
[logging]
 default = FILE:/var/log/krb5libs.log

[libdefaults]
 default_realm = HGER.ORG
 dns_lookup_realm = true
 dns_lookup_kdc = true
 ticket_lifetime = 24h
 renew_lifetime = 7d
 rdns = false
 forwardable = yes

EOF

/bin/cat > /etc/krb5.conf <<EOF
[logging]
 default = FILE:/var/log/krb5libs.log

[libdefaults]
 default_realm = HGER.ORG
 dns_lookup_realm = false
 dns_lookup_kdc = false
 ticket_lifetime = 24h
 renew_lifetime = 7d
 forwardable = yes

[realms]
 HGER.ORG = {
   kdc = dc.hger.org:88
   master_kdc = dc.hger.org:88
   kpasswd = dc.hger.org:464
   kpasswd_server = dc.hger.org:464
 }
EOF


#Samba config
/bin/cat > /etc/samba/smb.conf <<EOF
[global]
 workgroup = HGER
 client signing = yes
 client use spnego = yes
 kerberos method = secrets and keytab
 log file = /var/log/samba/%m.log
 password server = dc.hger.org
 realm = HGER.ORG
 security = ads
EOF

#Config for System Security Services Daemon
/bin/cat > /etc/sssd/sssd.conf <<EOF
[domain/hger.org]
id_provider = ad
auth_provider = ad
chpass_provider = ad
access_provider = ad
cache_credentials = True
use_fully_qualified_names = False
fallback_homedir = /home/%u
ad_server = dc.hger.org
ad_domain = hger.org
override_shell = /bin/bash

[sssd]
domains = hger.org
services = nss, pam, pac

[nss]

[pam]

[sudo]

[autofs]

[ssh]

[pac]

EOF
chmod 0600 /etc/sssd/sssd.conf

authconfig --update --enablesssd --enablesssdauth --enablemkhomedir

net ads join -U wsadder%Password1
net ads keytab create -U wsadder%Password1
systemctl restart sssd
