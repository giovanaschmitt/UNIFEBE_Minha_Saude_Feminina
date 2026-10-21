-- Sintomas que o app oferece e ainda não estão no catálogo SINTOMA (Oracle 19c).
-- Executar uma vez no schema APP_SAUDE_FEMININA. O MERGE não duplica se já existirem.

MERGE INTO SINTOMA s
USING (
    SELECT 'Cólica' AS nome, '⚡' AS emoji, 'físico' AS grupo, 8 AS ordem FROM dual UNION ALL
    SELECT 'Corrimento', '💧', 'físico', 9 FROM dual UNION ALL
    SELECT 'Sangramento fora do período', '🩸', 'físico', 10 FROM dual UNION ALL
    SELECT 'Inchaço', '🎈', 'físico', 11 FROM dual
) n
ON (LOWER(s.nome) = LOWER(n.nome))
WHEN NOT MATCHED THEN
    INSERT (nome, emoji, grupo, ordem, ativo) VALUES (n.nome, n.emoji, n.grupo, n.ordem, 1);

COMMIT;
