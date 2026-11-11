-- the tests run as the writer role; the reader role exists and can select but not write
SELECT current_user = current_schema() || '_rw'
   AND EXISTS (SELECT 1 FROM pg_roles WHERE rolname = current_schema() || '_ro')
   AND has_table_privilege(current_schema() || '_ro', 'units', 'SELECT')
   AND NOT has_table_privilege(current_schema() || '_ro', 'units', 'INSERT')
   AND NOT has_table_privilege(current_schema() || '_ro', 'akn_documents', 'UPDATE')
   AND has_table_privilege(current_schema() || '_rw', 'units', 'INSERT') AS ok
