import pyodbc
import config


class DBHelper:
    def __init__(self):
        self.conn_str = config.conn_str
        self.connection = pyodbc.connect(self.conn_str)

    def close_connection(self):
        # Close the database connection if it is open
        try:
            if self.connection:
                self.connection.close()
        except AttributeError:
            pass  # Ignore if the connection attribute is not yet set

    def get_connection(self):
        # Return the existing connection if available
        if self.connection:
            return self.connection

        # Create a new connection and return it
        self.connection = pyodbc.connect(self.conn_str)
        return self.connection
    
    def execute_query(self, query, select_query=False):
        connection = self.get_connection()
        cursor = connection.cursor()

        try:
            cursor.execute(query)
            if not select_query:
                connection.commit()
            return True, cursor, ''
        except Exception as e:
            connection.rollback()
            return False, cursor, f"Error: {e}"

    def get_table_names(self):
        connection = self.get_connection()
        cursor = connection.cursor()
        cursor.execute("SELECT TABLE_SCHEMA, TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'")
        table_names = [f"{row[0]}.{row[1]}" for row in cursor.fetchall()]
        return table_names
    
    def get_views_names(self):
        connection = self.get_connection()
        cursor = connection.cursor()
        cursor.execute("SELECT SCHEMA_NAME(V.schema_id) + '.' + V.name AS ViewName FROM sys.views V")
        view_names = [row[0] for row in cursor.fetchall()]
        return view_names
        
    def get_column_names(self, table_name):
        schema_name, splited_table_name = table_name.split('.')
        connection = self.get_connection()
        cursor = connection.cursor()
        cursor.execute(f"SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'{splited_table_name}' AND TABLE_SCHEMA = N'{schema_name}'")
        columns = [row[0] for row in cursor.fetchall()]
        return columns

    def get_column_names_of_view(self, view_name):
        schema_name, view_name = view_name.split('.')
        connection = self.get_connection()
        cursor = connection.cursor()
        cursor.execute(f"""
            SELECT 
                C.name AS ColumnName
            FROM 
                sys.views V
            JOIN 
                sys.columns C ON V.object_id = C.object_id
            WHERE V.name = '{view_name}' AND SCHEMA_NAME(V.schema_id) = '{schema_name}' 
            ORDER BY 
                V.name, C.column_id;
            """)
        columns = [row[0] for row in cursor.fetchall()]
        return columns

    def get_column_names_except_primary_key_columns(self, table_name):
        schema_name, splited_table_name = table_name.split('.')
        connection = self.get_connection()
        cursor = connection.cursor()
        cursor.execute(f"""
            SELECT COLUMN_NAME
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_NAME = '{splited_table_name}' AND TABLE_SCHEMA = '{schema_name}'
            AND COLUMN_NAME NOT IN (
                SELECT COLUMN_NAME
                FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
                WHERE TABLE_NAME = '{splited_table_name}' AND TABLE_SCHEMA = '{schema_name}'
                AND CONSTRAINT_NAME = (
                    SELECT CONSTRAINT_NAME
                    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
                    WHERE TABLE_NAME = '{splited_table_name}' AND TABLE_SCHEMA = '{schema_name}'
                    AND CONSTRAINT_TYPE = 'PRIMARY KEY'
                )
            );"""
        )
        columns = [row[0] for row in cursor.fetchall()]
        return columns

    def get_primary_key_columns(self, table_name):
        schema_name, splited_table_name = table_name.split('.')
        connection = self.get_connection()
        cursor = connection.cursor()
        cursor.execute(f"SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE OBJECTPROPERTY(OBJECT_ID(CONSTRAINT_NAME), 'IsPrimaryKey') = 1 AND TABLE_NAME = N'{splited_table_name}' AND TABLE_SCHEMA = N'{schema_name}'")
        primary_key_columns = [row[0] for row in cursor.fetchall()]
        return primary_key_columns

    def get_primary_key_condition(self, table_name, selection):
        schema_name, splited_table_name = table_name.split('.')
        connection = self.get_connection()
        cursor = connection.cursor()
        query = f"SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE OBJECTPROPERTY(OBJECT_ID(CONSTRAINT_NAME), 'IsPrimaryKey') = 1 AND TABLE_NAME = N'{splited_table_name}' AND TABLE_SCHEMA = N'{schema_name}'"
        cursor.execute(query)
        rows = cursor.fetchone()
        if rows:
            primary_key_column = rows[0]
            return f"{primary_key_column} = '{selection}'"
        else:
            query = f"SELECT TOP 1 COLUMN_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_NAME = N'{splited_table_name}' AND TABLE_SCHEMA = N'{schema_name}'"
            cursor.execute(query)
            rows = cursor.fetchone()
            if rows:
                primary_key_column = rows[0]
                return f"{primary_key_column} = '{selection}'"
            else:
                return ""

    def get_foreign_keys(self, table_name):
        _, splited_table_name = table_name.split('.')
        connection = self.get_connection()
        cursor = connection.cursor()
        query = f"""
            SELECT
                col.name AS column_name,
                CONCAT(pk_tab.schema_name, '.', pk_tab.name) AS referenced_table,
                pk_col.name AS referenced_column
            FROM sys.tables tab
                INNER JOIN sys.columns col 
                    ON col.object_id = tab.object_id
                LEFT OUTER JOIN sys.foreign_key_columns fk_cols
                    ON fk_cols.parent_object_id = tab.object_id
                    AND fk_cols.parent_column_id = col.column_id
                LEFT OUTER JOIN sys.foreign_keys fk
                    ON fk.object_id = fk_cols.constraint_object_id
                LEFT OUTER JOIN (
                    SELECT
                        tab.object_id,
                        schema_name(tab.schema_id) AS schema_name,
                        tab.name
                    FROM sys.tables tab
                ) AS pk_tab
                    ON pk_tab.object_id = fk_cols.referenced_object_id
                LEFT OUTER JOIN sys.columns pk_col
                    ON pk_col.column_id = fk_cols.referenced_column_id
                    AND pk_col.object_id = fk_cols.referenced_object_id
            WHERE fk.object_id IS NOT NULL AND tab.name = '{splited_table_name}'
            ORDER BY schema_name(tab.schema_id) + '.' + tab.name, col.column_id
        """
        cursor.execute(query)
        foreign_keys = {}
        for row in cursor.fetchall():
            column_name, referenced_table, referenced_column = row
            foreign_keys[column_name] = {
                'referenced_table': referenced_table,
                'referenced_column': referenced_column
            }
        return foreign_keys

    def get_related_table_values(self, table_name, columns_name_list):
        columns = ', '.join(columns_name_list)
        connection = self.get_connection()
        cursor = connection.cursor()
        cursor.execute(f"SELECT {columns} FROM {table_name}")
        rows = cursor.fetchall()
        values = [', '.join(map(str, row)) for row in rows]

        return values
