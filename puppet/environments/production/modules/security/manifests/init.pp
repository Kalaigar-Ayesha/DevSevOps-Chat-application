class security {
  include security::ssh
  include security::firewall
  include security::fail2ban
}
