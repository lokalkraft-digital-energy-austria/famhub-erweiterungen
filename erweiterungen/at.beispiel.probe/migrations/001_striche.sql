-- Die Striche liegen im eigenen Schema der Erweiterung; mehr sieht sie ohnehin nicht.
create table if not exists striche (
  id bigserial primary key,
  tag date not null default current_date
);
create index if not exists striche_tag on striche (tag);
