-- -----------------ETAPA 4------------------------------------------
-- Consulta 1: Total de personas contratadas y total pagado por cargo
-- ------------------------------------------------------------------

WITH EmpleadoSprints AS (
    SELECT 
        e.Id_Empleado,
        c.Cargo,
        c.Salario,
        COUNT(s.Id_sprint) AS Cantidad_Sprints
    FROM 
        tadb01.Empleados e
    JOIN 
        tadb01.Cargos c ON e.Id_cargo = c.Id_cargo
    JOIN 
        tadb01.Equipos eq ON e.Id_equipo = eq.Id_equipo
    JOIN 
        tadb01.PI_Equipos pieq ON eq.Id_equipo = pieq.Id_equipo
    JOIN 
        tadb01.Sprints s ON pieq.Id_pi = s.Id_pi
    GROUP BY 
        e.Id_Empleado, c.Cargo, c.Salario
)
SELECT 
    es.Cargo,
    COUNT(DISTINCT es.Id_Empleado) AS Numero_Contratados,
    SUM(es.Salario * es.Cantidad_Sprints) AS Total_Pagado
FROM 
    EmpleadoSprints es
GROUP BY 
    es.Cargo
ORDER BY 
    es.Cargo;

-- ----------------------------------------
-- Consulta 2: Variación porcentual de pagos por quincena
-- ----------------------------------------

WITH PagosPorQuincena AS (
    SELECT 
        s.Id_sprint AS Quincena,
        SUM(c.Salario) AS Total_Pagado
    FROM 
        tadb01.Empleados e
    JOIN 
        tadb01.Cargos c ON e.Id_cargo = c.Id_cargo
    JOIN 
        tadb01.Equipos eq ON e.Id_equipo = eq.Id_equipo
    JOIN 
        tadb01.PI_Equipos pieq ON eq.Id_equipo = pieq.Id_equipo
    JOIN 
        tadb01.Sprints s ON pieq.Id_pi = s.Id_pi
    GROUP BY 
        s.Id_sprint
)
SELECT 
    Quincena,
    Total_Pagado,
    COALESCE(
        ROUND(
            ((Total_Pagado - LAG(Total_Pagado) OVER (ORDER BY Quincena)) / NULLIF(LAG(Total_Pagado) OVER (ORDER BY Quincena), 0)) * 100,
        2), 0
    ) AS Variacion_Porcentual
FROM 
    PagosPorQuincena
ORDER BY 
    Quincena;

-- ---------------------ETAPA 5-------------------
-- Función: f_calcula_costo_departamento_quincena
-- ----------------------------------------

CREATE OR REPLACE FUNCTION tadb01.f_calcula_costo_departamento_quincena(
    p_quincena INTEGER,
    p_departamento INTEGER
) 
RETURNS DECIMAL AS $$
DECLARE 
    v_total_salario DECIMAL;
BEGIN
    SELECT 
        COALESCE(SUM(c.Salario), 0) INTO v_total_salario
    FROM 
        tadb01.Empleados e
    JOIN 
        tadb01.Cargos c ON e.Id_cargo = c.Id_cargo
    JOIN 
        tadb01.Departamentos d ON c.Id_Departamento = d.Id_Departamento
    JOIN 
        tadb01.Equipos eq ON e.Id_equipo = eq.Id_equipo
    JOIN 
        tadb01.PI_Equipos pieq ON eq.Id_equipo = pieq.Id_equipo
    JOIN 
        tadb01.Sprints s ON pieq.Id_pi = s.Id_pi
    WHERE 
        s.Id_sprint = p_quincena
        AND d.Id_Departamento = p_departamento;

    RETURN v_total_salario;
END;
$$ LANGUAGE plpgsql;

-- ----------------------------------------
-- Procedimiento: p_calcula_nomina_quincena
-- ----------------------------------------

CREATE OR REPLACE PROCEDURE tadb01.p_calcula_nomina_quincena(
    p_quincena INTEGER
) 
LANGUAGE plpgsql AS $$
DECLARE 
    v_departamento RECORD;
    v_total_empleados INTEGER;
    v_valor_nomina DECIMAL;
BEGIN
    -- Limpiar la tabla NOMINA para la quincena actual
    DELETE FROM tadb01.NOMINA WHERE ID_Quincena = p_quincena;

    -- Recorrer todos los departamentos
    FOR v_departamento IN (SELECT Id_Departamento FROM tadb01.Departamentos) LOOP
        -- Calcular el total de empleados en el departamento
        SELECT COUNT(*) INTO v_total_empleados
        FROM tadb01.Empleados e
        JOIN tadb01.Cargos c ON e.Id_cargo = c.Id_cargo
        WHERE c.Id_Departamento = v_departamento.Id_Departamento;

        -- Calcular el valor de la nómina usando la función f_calcula_costo_departamento_quincena
        v_valor_nomina := tadb01.f_calcula_costo_departamento_quincena(p_quincena, v_departamento.Id_Departamento);

        -- Insertar los datos en la tabla NOMINA
        INSERT INTO tadb01.NOMINA (ID_Quincena, ID_Departamento, Total_Empleados_Departamento, Valor)
        VALUES (p_quincena, v_departamento.Id_Departamento, v_total_empleados, v_valor_nomina);
    END LOOP;
END;
$$;

-- ----------------------------------------
-- Ejecución del procedimiento
-- ----------------------------------------

CALL tadb01.p_calcula_nomina_quincena(1);
SELECT * FROM tadb01.NOMINA;