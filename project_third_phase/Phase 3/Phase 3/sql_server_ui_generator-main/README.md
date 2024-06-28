# Database Lab UI

This project provides a simple graphical user interface (GUI) for interacting with any SQL Server database. It's designed for educational purposes in a database lab setting. The GUI is built using Tkinter and allows users to perform basic CRUD (Create, Read, Update, Delete) operations on tables and views in a SQL Server database.

## Getting Started

1. **Clone the Repository and Install Requirements:**
   ```bash
   git clone https://github.com/MohammadmahdiAhmadi/sql_server_ui_generator.git
   cd sql_server_ui_generator

   pip install -r requirements.txt
   ```

2. **Configure Database Connection:**
Edit the `config.py` file to set the `conn_str` variable with the appropriate connection string for your SQL Server database. If needed, you can also set `db_info` for specific table and view configurations.

3. **Running the Application**
    ```bash
   python app.py
   ```

## Project Structure

- **app.py:** Main script to launch the Tkinter GUI.
- **config.py:** Configuration file containing database connection information and table/view details.
- **dbhelper.py:** Helper class for interacting with the SQL Server database.
- **gui.py:** GUI implementation using Tkinter. Handles the layout, tabs, and user interactions.

## Note

- The application uses the `pyodbc` library to connect to the SQL Server database. Ensure that the library is installed (see `requirements.txt`).
- Modify the `conn_str` variable in `config.py` to match the connection details of your SQL Server database.

# ToDo
- Multiple primary key in delete, update
