CREATE USER IF NOT EXISTS 'Server'@'%' IDENTIFIED BY '1234';
GRANT ALL PRIVILEGES ON Admin.* TO 'Server'@'%';
FLUSH PRIVILEGES;