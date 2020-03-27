docker build -t anyconnectusers .
initialize db:
    ./initdb.sh

version: '3.1'

networks:
  netflow_network:
    driver: bridge
services:
  db:
    image: postgres
    networks:
      netflow_network:
    restart: always
    environment:
      POSTGRES_PASSWORD: example
      POSTGRES_DB: netflow
    volumes:
      - ./data/db:/var/lib/postgresql/data
      - ./init:/docker-entrypoint-initdb.d
    ports:
      - 5442:5432
  anyconnectuses:
    image: ciscoliveru/anyconnectusers:latest
    depends_on:
      - db
    networks:
      netflow_network:
    restart: always
    environment:
      PSQLIP: db
      PSQLPORT: 5432
      PSQLUSER: netflow
      PSQLPASSWORD: netflow
      DEBUGMODE: 0 <----------- Debug mode, from 0 (disabled) to 255
      PSQLDBNAME: netflow
      TABLENAME: anyconnect
    ports:
      - 7002:7002
  
Config on ASA

event manager applet StartSession
 event syslog id 722051 occurs 1
 action 0 cli command "call-home send alert-group snapshot profile VPNSH"
 output none
event manager applet EndSession
 event syslog id 113019 occurs 1
 action 0 cli command "call-home send alert-group snapshot profile VPNSH"
 output none
 
call-home
 alert-group-config snapshot
  add-command "show vpn-sessiondb anyconnect"
 profile VPNSH
   destination address http http://<Your server IP address>:7002/vpnsession msg-format xml