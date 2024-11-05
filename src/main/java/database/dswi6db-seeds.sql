create extension if not exists "uuid-ossp";
create extension if not exists "btree_gist";

insert into tb_user_type (description) values ('Usuário');
insert into tb_user_type (description) values ('Administrador');

insert into tb_rent_type (description) values ('Auditório');
insert into tb_rent_type (description) values ('Salão de Festas');

insert into
    tb_user (id, name, username, password, user_type, birth_date, created_at, updated_at, actived)
values
    (uuid_generate_v4(), 'Natureza Viva', 'admin', '123456', 2, '2000-01-01', now(), now(), false);

insert into tb_rent_status (description) values ('Disponível');
insert into tb_rent_status (description) values ('Solicitado');
insert into tb_rent_status (description) values ('Alugado');
insert into tb_rent_status (description) values ('Fechamento');
insert into tb_rent_status (description) values ('Finalizado');