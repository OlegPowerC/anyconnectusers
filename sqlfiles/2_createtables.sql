create table if not exists anyconnect
(
 id serial not null
  constraint anyconnect_pk
   primary key,
 starttime timestamp not null,
 endtime timestamp not null,
 username varchar(50) default 'None'::character varying not null,
 connectionstate integer default 2 not null,
 sensorip varchar(15) default '0.0.0.0'::character varying not null,
 realipaddr varchar(15) default '0.0.0.0'::character varying not null,
 assignedipv4 varchar(15) default '0.0.0.0'::character varying not null,
 country varchar(50) default ''::character varying not null,
 city varchar(50) default ''::character varying not null,
 coords varchar(50) default ''::character varying not null,
 sessionid varchar(28) default '0000000000000000000000000000'::character varying not null,
 sessionfullid varchar(28) default '0000000000000000000000000000'::character varying not null
);

CREATE OR REPLACE FUNCTION anyconnect_create_time()
    RETURNS trigger AS $anyconnect_create_time$
BEGIN
    NEW.starttime := current_timestamp;
    NEW.endtime := current_timestamp;
    RETURN NEW;
END;
$anyconnect_create_time$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION anyconnect_end_time()
    RETURNS trigger AS $anyconnect_end_time$
BEGIN
    IF (NEW.connectionstate = 3) THEN
        NEW.endtime := current_timestamp;
    end if;
    RETURN NEW;
END;
$anyconnect_end_time$ LANGUAGE 'plpgsql';

create unique index if not exists anyconnect_id_uindex
 on anyconnect (id);

create trigger anyconnect_before_insert
 before insert
 on anyconnect
 for each row
 execute procedure anyconnect_create_time();

create trigger anyconnect_before_update
 before update
 on anyconnect
 for each row
 execute procedure anyconnect_end_time();
 
alter table anyconnect owner to netflow;

