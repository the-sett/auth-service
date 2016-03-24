
    create table account (
        id int8 not null,
        username text,
        password text,
        primary key (id)
    );

    create table account_role (
        account_id int8 not null,
        role_id int8 not null,
        primary key (role_id, account_id)
    );

    create table external_id (
        id char(32),
        resource varchar(255),
        primary key (id)
    );

    create table role (
        id int8 not null,
        name text,
        primary key (id)
    );

    create table role_permissions (
        permissions_id int8 not null,
        permissions varchar(255)
    );

    alter table account_role 
        add constraint FK_p2jpuvn8yll7x96rae4hvw3sj 
        foreign key (role_id) 
        references role;

    alter table account_role 
        add constraint FK_ibmw1g5w37bmuh5fc0db7wn10 
        foreign key (account_id) 
        references account;

    alter table role_permissions 
        add constraint FK_a4fq53k4nkqxrx269khks3764 
        foreign key (permissions_id) 
        references role;

    create sequence hibernate_sequence;
