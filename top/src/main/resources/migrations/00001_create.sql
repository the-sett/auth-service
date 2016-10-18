
    create table account (
        id int8 not null,
        username text,
        password text,
        root boolean,
        primary key (id)
    );

    create table account_role (
        account_id int8 not null,
        role_id int8 not null,
        primary key (account_id, role_id)
    );

    create table external_id (
        id char(32),
        resource varchar(255),
        primary key (id)
    );

    create table permission (
        id int8 not null,
        name text,
        primary key (id)
    );

    create table role (
        id int8 not null,
        name text,
        primary key (id)
    );

    create table role_permission (
        role_id int8 not null,
        permission_id int8 not null,
        primary key (role_id, permission_id)
    );

    alter table account_role 
        add constraint FK_p2jpuvn8yll7x96rae4hvw3sj 
        foreign key (role_id) 
        references role;

    alter table account_role 
        add constraint FK_ibmw1g5w37bmuh5fc0db7wn10 
        foreign key (account_id) 
        references account;

    alter table role_permission 
        add constraint FK_fn4pldu982p9u158rpk6nho5k 
        foreign key (permission_id) 
        references permission;

    alter table role_permission 
        add constraint FK_j89g87bvih4d6jbxjcssrybks 
        foreign key (role_id) 
        references role;

    create sequence hibernate_sequence;
