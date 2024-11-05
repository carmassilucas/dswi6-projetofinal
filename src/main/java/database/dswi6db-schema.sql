create table if not exists tb_user_type (
    id bigserial primary key,
    description character varying not null unique
);

create table if not exists tb_user (
    id uuid primary key,
    name character varying not null,
    username character varying not null unique,
    password character varying not null,
    user_type bigint not null,
    birth_date date not null,
    created_at timestamptz not null,
    updated_at timestamptz not null
);

alter table tb_user
add constraint fk_user_type
foreign key (user_type) references tb_user_type (id);

create table if not exists tb_rent_type (
    id bigserial primary key,
    description character varying not null unique
);

create table if not exists tb_rent (
    id uuid primary key,
    name character varying not null,
    address character varying not null,
    rent_type bigint not null,
    initial_datetime timestamptz not null,
    final_datetime timestamptz not null,
    description text not null,
    created_at timestamptz not null,
    updated_at timestamptz not null
);

alter table tb_rent
add constraint fk_rent_type
foreign key (rent_type) references tb_rent_type (id);

create table if not exists tb_rent_status (
    id bigserial primary key,
    description character varying not null unique
);

create table if not exists tb_user_rent (
    id bigserial primary key,
    user_id uuid not null,
    rent_id uuid not null,
    rent_status bigint not null,
    created_at timestamptz not null,
    updated_at timestamptz not null
);

create table if not exists tb_rent_occurrence (
    id bigserial primary key,
    user_rent_id bigint not null,
    description text not null,
    created_at timestamptz not null
);

alter table tb_user_rent
add constraint fk_user_rent_user
foreign key (user_id) references tb_user (id);

alter table tb_user_rent
add constraint fk_user_rent_rent
foreign key (rent_id) references tb_rent (id);

alter table tb_user_rent
add constraint fk_user_rent_status
foreign key (rent_status) references tb_rent_status (id);

alter table tb_rent_occurrence
add constraint fk_rent_occurrence_user_rent
foreign key (user_rent_id) references tb_user_rent (id);

alter table tb_user add column actived boolean default true not null;

alter table tb_rent_occurrence add column unblock_user boolean default false not null;

alter table tb_rent_occurrence add column updated_at timestamptz default now() not null;
