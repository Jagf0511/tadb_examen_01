-- ----------------------------------------
-- Creación de base de datos y usuarios
-- ----------------------------------------

grant connect on database postgres to "AdminTadb";

-- privilegios para crear tablas temporales
grant temporary on database postgres to "AdminTadb";

-- Privilegios de uso en el esquema
grant usage on schema public to "AdminTadb";

-- privilegios para crear objetos
grant create on schema public to "AdminTadb";

-- Privilegios sobre tablas existentes
grant select, insert, update, delete, trigger on all tables in schema public to "AdminTadb";

-- privilegios sobre secuencias existentes
grant usage, select on all sequences in schema public to "AdminTadb";

-- privilegios sobre funciones existentes
grant execute on all functions in schema public to "AdminTadb";

-- privilegios sobre procedimientos existentes
grant execute on all procedures in schema public to "AdminTadb";

-- privilegios sobre futuras tablas y secuencias
alter default privileges in schema public grant select, insert, update, delete, trigger on tables to "AdminTadb";

alter default privileges in schema public grant select, usage on sequences to "AdminTadb";

-- privilegios sobre futuras funciones y procedimientos
alter default privileges in schema public grant execute on routines to "AdminTadb";

--Privilegios de consulta sobre el esquema information_schema
grant usage on schema information_schema to "AdminTadb";

----------------------------------------------------------------
-- Tabla: Actividades
create table Actividades (
    Id_actividad integer primary key,
    Actividad varchar not null
);

comment on table Actividades is 'Actividades PI';
comment on column Actividades.Id_actividad is 'Id de la actividad';
comment on column Actividades.Actividad is 'Descripción de la actividad';

-- Tabla: ProgramIncrement
create table ProgramIncrement (
    Id_pi integer primary key,
    Id_actividad integer not null references Actividades(Id_actividad)
);

comment on table ProgramIncrement is 'Tabla que almacena los incrementos de programa';
comment on column ProgramIncrement.Id_pi is 'Identificador único del incremento de programa';
comment on column ProgramIncrement.Id_actividad is 'Referencia a la actividad asociada';

-- Tabla: Sprints
create table Sprints (
    Id_sprint integer primary key,
    Id_pi integer references ProgramIncrement(Id_pi)
);

comment on table Sprints is 'Tabla que almacena los sprints';
comment on column Sprints.Id_sprint is 'Identificador único del sprint';
comment on column Sprints.Id_pi is 'Referencia al incremento de programa asociado';

-- Tabla: Departamentos
create table Departamentos (
    Id_Departamento integer primary key,
    Departamento varchar not null
);

comment on table Departamentos is 'Tabla que almacena los departamentos';
comment on column Departamentos.Id_Departamento is 'Identificador único del departamento';
comment on column Departamentos.Departamento is 'Nombre del departamento';

-- Tabla: Cargos
create table Cargos (
    Id_cargo integer primary key,
    Cargo varchar not null,
    Id_Departamento integer not null references Departamentos(Id_Departamento),
    Salario decimal not null
);

comment on table Cargos is 'Tabla que almacena los cargos de los empleados';
comment on column Cargos.Id_cargo is 'Identificador único del cargo';
comment on column Cargos.Cargo is 'Nombre del cargo';
comment on column Cargos.Id_Departamento is 'Referencia al departamento asociado';
comment on column Cargos.Salario is 'Salario asociado al cargo';

-- Tabla: Equipos
create table Equipos (
    Id_equipo integer primary key,
    Equipo varchar not null,
    Id_Departamento integer not null references Departamentos(Id_Departamento)
);

comment on table Equipos is 'Tabla que almacena los equipos de trabajo';
comment on column Equipos.Id_equipo is 'Identificador único del equipo';
comment on column Equipos.Equipo is 'Nombre del equipo';
comment on column Equipos.Id_Departamento is 'Referencia al departamento asociado';


-- Tabla: Empleados
create table Empleados (
    Id_Empleado integer primary key,
    Id_cargo integer not null references Cargos(Id_cargo),
    Id_equipo integer not null references Equipos(Id_equipo),
    Nombres varchar not null,
    Apellidos varchar not null
);

comment on table Empleados is 'Tabla que almacena los empleados';
comment on column Empleados.Id_Empleado is 'Identificador único del empleado';
comment on column Empleados.Id_cargo is 'Referencia al cargo asociado';
comment on column Empleados.Id_equipo is 'Referencia al equipo asociado';
comment on column Empleados.Nombres is 'Nombres del empleado';
comment on column Empleados.Apellidos is 'Apellidos del empleado';


-- Tabla: PI_Equipos
create table PI_Equipos (
    Id_pi integer not null references ProgramIncrement(Id_pi),
    Id_equipo integer not null references Equipos(Id_equipo),
    primary key (Id_pi, Id_equipo)
);

comment on table PI_Equipos is 'Tabla de relación entre incrementos de programa y equipos';
comment on column PI_Equipos.Id_pi is 'Referencia al incremento de programa';
comment on column PI_Equipos.Id_equipo is 'Referencia al equipo asociado';

-- Tabla: NOMINA
CREATE TABLE tadb01.NOMINA (
    ID_Quincena INTEGER,
    ID_Departamento INTEGER,
    Total_Empleados_Departamento INTEGER,
    Valor DECIMAL
);