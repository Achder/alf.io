--
-- This file is part of alf.io.
--
-- alf.io is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- alf.io is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with alf.io.  If not, see <http://www.gnu.org/licenses/>.
--


create type SUBSCRIPTION_AVAILABILITY as enum ('ONCE_PER_EVENT', 'UNLIMITED');
create type ALLOCATION_STATUS as enum ('FREE', 'PRE_RESERVED', 'PENDING', 'TO_BE_PAID', 'ACQUIRED', 'CANCELLED',
                                        'CHECKED_IN', 'EXPIRED',
                                        'INVALIDATED', 'RELEASED');

create table subscription_descriptor (
    id bigserial primary key not null,
    title jsonb not null,
    description jsonb,
    max_entries int not null default 0,
    creation_ts timestamp with time zone not null default now(),
    valid_from timestamp with time zone not null,
    valid_to timestamp with time zone,
    price_cts integer not null,
    currency text,
    availability SUBSCRIPTION_AVAILABILITY not null default 'ONCE_PER_EVENT',
    is_public boolean not null default false,
    organization_id_fk int not null constraint subscription_descriptor_organization_id_fk references organization(id)
);

alter table subscription_descriptor enable row level security;
alter table subscription_descriptor force row level security;
create policy subscription_descriptor_access_policy on subscription_descriptor to public
    using (alfio_check_row_access(organization_id_fk))
    with check (alfio_check_row_access(organization_id_fk));

create table subscription (
    id uuid primary key not null,
    first_name text not null,
    last_name text not null,
    email_address text not null,
    code text not null constraint subscription_code_unique unique,
    subscription_descriptor_fk bigint not null constraint subscription_subscription_descriptor_fk references subscription_descriptor(id),
    reservation_id_fk character(36) not null constraint subscription_reservation_id_fk references tickets_reservation(id),
    usage_count integer not null,
    organization_id_fk int not null constraint subscription_organization_id_fk references organization(id),
    creation_ts timestamp with time zone not null default now(),
    update_ts timestamp with time zone,
    status ALLOCATION_STATUS not null default 'FREE'
);

alter table subscription enable row level security;
alter table subscription force row level security;
create policy subscription_access_policy on subscription to public
    using (alfio_check_row_access(organization_id_fk))
    with check (alfio_check_row_access((organization_id_fk)));

create table subscription_event (
    id bigserial primary key not null,
    event_id_fk int not null references event(id),
    subscription_id_fk uuid not null constraint subscription_event_subscription_id_fk references subscription(id),
    price_per_ticket integer not null default 0,
    organization_id_fk int not null constraint subscription_event_organization_id_fk references organization(id)
);

alter table subscription_event enable row level security;
alter table subscription_event force row level security;
create policy subscription_event_access_policy on subscription to public
    using (alfio_check_row_access(organization_id_fk))
    with check (alfio_check_row_access((organization_id_fk)));

alter table event add column tags text array not null default array[]::text[];
alter table ticket add column subscription_id_fk uuid constraint ticket_subscription_id_fk references subscription(id);