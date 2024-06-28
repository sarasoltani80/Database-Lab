import tkinter as tk
from tkinter import ttk, messagebox
import config
import dbhelper


class AppGUI:
    def __init__(self, root):
        self.dbhelper = dbhelper.DBHelper()

        self.root = root
        self.root.title("Database App")
        screen_width = root.winfo_screenwidth()
        screen_height = root.winfo_screenheight()
        self.root.geometry(f"{screen_width}x{screen_height}")

        # Dictionary to store ttk.Treeview instances for each table
        self.tree_views = {}
        self.tree_views_for_sql_views = {}

        # Dictionary to store ttk.Frame instances for each table
        self.frame_views = {}
        self.frame_views_for_sql_views = {}

        self.create_tabs()

        # Preload all tabs
        self.preload_all_tabs()

        # Bind the destroy event to the cleanup function
        self.root.protocol("WM_DELETE_WINDOW", self.on_close)

    def on_close(self):
        # Handle cleanup tasks, such as closing the database connection
        self.dbhelper.close_connection()
        self.root.destroy()
    
    def discard_changes(self, entry):
        # Destroy the entry widget
        entry.destroy()

    def get_current_tree(self, table_name):
        return self.tree_views.get(table_name)

    def get_current_tree_views_for_sql_views(self, view_name):
        return self.tree_views_for_sql_views.get(view_name)

    def preload_all_tabs(self):
        # Preload all table tabs
        table_names = self.dbhelper.get_table_names()
        for table in table_names:
            self.show_table_tab(table)

        # Preload all view tabs
        view_names = self.dbhelper.get_views_names()
        for view in view_names:
            self.show_view_tab(view)

    def reload_all_tabs(self):
        table_names = self.dbhelper.get_table_names()
        for table in table_names:
            self.load_table_data(table, self.get_current_tree(table))

        views_names = self.dbhelper.get_views_names()
        for view in views_names:
            self.load_view_data(view, self.get_current_tree_views_for_sql_views(view))

    def create_tabs(self):
        tab_control = ttk.Notebook(self.root)

        tables_combobox = ttk.Combobox(self.root, values=self.dbhelper.get_table_names())
        tables_combobox.state(['readonly'])
        tables_combobox.set('Select Tables')
        tables_combobox.grid(row=0, column=0, padx=10, pady=10)
        tables_combobox.bind("<<ComboboxSelected>>", lambda event: self.on_combobox_selected(tables_combobox))

        views_combobox = ttk.Combobox(self.root, values=self.dbhelper.get_views_names())
        views_combobox.state(['readonly'])
        views_combobox.set('Select Views')
        views_combobox.grid(row=0, column=1, padx=10, pady=10)
        views_combobox.bind("<<ComboboxSelected>>", lambda event: self.on_combobox_selected(views_combobox))

        tab_control.grid(row=1, column=0, columnspan=2, sticky="nsew")

        # Set weights for grid columns and rows to make the Treeview expand
        self.root.grid_rowconfigure(1, weight=1)
        self.root.grid_columnconfigure(0, weight=1)
        self.root.grid_columnconfigure(1, weight=1)

        self.tab_control = tab_control
        self.tables_combobox = tables_combobox
        self.views_combobox = views_combobox

    def on_combobox_selected(self, combobox):
        selected_item = combobox.get()

        if self.frame_views.get(selected_item):
            self.tab_control.select(self.frame_views.get(selected_item))
        elif self.frame_views_for_sql_views.get(selected_item):
            self.tab_control.select(self.frame_views_for_sql_views.get(selected_item))

    def show_table_tab(self, table_name):
        if table_name not in self.frame_views:
            tab = ttk.Frame(self.tab_control)
            self.tab_control.add(tab, text=table_name)
            self.create_table_tab(tab, table_name)
            self.frame_views[table_name] = tab  # Store the frame in the dictionary

    def show_view_tab(self, view_name):
        if view_name not in self.frame_views_for_sql_views:
            tab = ttk.Frame(self.tab_control)
            self.tab_control.add(tab, text=view_name)
            self.create_view_tab(tab, view_name)
            self.frame_views_for_sql_views[view_name] = tab  # Store the frame in the dictionary

    def create_view_tab(self, tab, view_name):
        tree = ttk.Treeview(tab, selectmode='browse', show = 'headings', height = 20)
        tree["columns"] = tuple(self.dbhelper.get_column_names_of_view(view_name))
        for col in tree["columns"]:
            tree.column(col, anchor=tk.CENTER, width=150)
            tree.heading(col, text=col, anchor=tk.CENTER)

        # Configure tags for alternate rows
        tree.tag_configure("oddrow", background="#f0f0f0")
        tree.tag_configure("evenrow", background="#ffffff")

        tree.pack(pady=10)

        self.tree_views_for_sql_views[view_name] = tree

        # Fetch and display data
        self.load_view_data(view_name, tree)

    def create_table_tab(self, tab, table_name):
        tree = ttk.Treeview(tab, selectmode='browse', show = 'headings', height = 20)
        tree["columns"] = tuple(self.dbhelper.get_column_names(table_name))
        for col in tree["columns"]:
            tree.column(col, anchor=tk.CENTER, width=150)
            tree.heading(col, text=col, anchor=tk.CENTER)
            # Enable cell editing
            tree.bind("<Double-Button-1>", lambda event, table_name=table_name, tree=tree: self.edit_cell(event, table_name, tree))

        # Configure tags for alternate rows
        tree.tag_configure("oddrow", background="#f0f0f0")
        tree.tag_configure("evenrow", background="#ffffff")

        tree.pack(pady=10)

        self.tree_views[table_name] = tree

        # Buttons for CRUD operations
        add_frame = ttk.Frame(tab)
        add_frame.pack(pady=10)

        if table_name in config.db_info['tables'] and config.db_info['tables'][table_name]['insert']['insert_type'] == 'Procedure':
            column_names = config.db_info['tables'][table_name]['insert']['procedure_input_params']
        else:
            column_names = self.dbhelper.get_column_names_except_primary_key_columns(table_name)

        # Get column names and foreign key relationships
        foreign_keys = self.dbhelper.get_foreign_keys(table_name)

        entry_values = {}

        for col in column_names:
            label = ttk.Label(add_frame, text=col)
            label.grid(row=len(entry_values), column=0, sticky=tk.E, padx=10, pady=5)
            if col in foreign_keys and foreign_keys[col]['referenced_table'] in config.db_info['tables']:
                # If yes, create a dropdown instead of an entry
                values = self.dbhelper.get_related_table_values(foreign_keys[col]['referenced_table'], config.db_info['tables'][foreign_keys[col]['referenced_table']]['columns_to_show_when_referenced'])
                entry = ttk.Combobox(add_frame, values=values)
                entry.grid(row=len(entry_values), column=1, sticky=tk.W + tk.E, padx=10, pady=5)
                entry.bind("<<ComboboxSelected>>", lambda event, combobox=entry: self.update_combobox_value(event, combobox))
            else:
                entry = ttk.Entry(add_frame)
                entry.grid(row=len(entry_values), column=1, sticky=tk.W + tk.E, padx=10, pady=5)
            
            entry_values[col] = entry

        add_button = ttk.Button(add_frame, text="Add", command=lambda: self.add_item(table_name, entry_values, tree))
        add_button.grid(row=len(entry_values), column=0, columnspan=2, pady=10)

        if entry_values:
            first_entry = next(iter(entry_values.values()))
            first_entry.focus_set()

        # Fetch and display data
        self.load_table_data(table_name, tree)

    def update_combobox_value(self, event, combobox):
        selected_value = combobox.get()
        if selected_value:
            first_parameter = selected_value.split(', ')[0].strip()
            combobox.set(first_parameter)

    def edit_cell(self, event, table_name, tree):
        item = tree.selection()
        if not item:
            return

        column = tree.identify_column(event.x)
        col_index = int(column.split("#")[-1]) - 1
        primary_key_columns = self.dbhelper.get_primary_key_columns(table_name)
        col_name = tree["columns"][col_index]
        # Primary key can't be edit 
        if col_name in primary_key_columns:
            return

        # Get the bounds of the cell
        x, y, _, h = tree.bbox(item, column)

        # Create an entry widget for editing
        entry = tk.Entry(tree, justify="center")
        entry.place(x=x, y=y, width=tree.column(col_name, "width"), height=h)

        entry.insert(0, tree.set(item, col_name))

        # Set focus to the entry widget
        entry.focus_set()

        # Bind the return key to update the cell
        entry.bind("<Return>", lambda event, table_name=table_name, tree=tree, entry=entry, item=item, col_name=col_name: self.update_cell(event, table_name, tree, entry, item, col_name))

        # Bind the escape key and focus out event to discard changes
        entry.bind("<Escape>", lambda event, entry=entry: self.discard_changes(entry))
        entry.bind("<FocusOut>", lambda event, entry=entry: self.discard_changes(entry))
        
    def load_table_data(self, table_name, tree):
        columns_to_select = self.dbhelper.get_column_names(table_name)
        columns_to_select = [f'[{col}]' for col in columns_to_select]
        query = f"SELECT {', '.join([f'CONVERT(VARCHAR, {col}, 120) AS {col}' if 'datetime' in col.lower() else col for col in columns_to_select])} FROM {table_name}"
        result, cursor, error = self.dbhelper.execute_query(query, select_query=True)
        if not result:
            messagebox.showinfo("Error", f"Error: {error}")

        rows = [list(row) for row in cursor.fetchall()]

        for item in tree.get_children():
            tree.delete(item)

        # Custom event for delete button click
        tree.tag_bind("delete_tag", "<Triple-Button-1>", lambda event, table_name=table_name, tree=tree: self.delete_selected_item(table_name, tree, event))

        for i, row in enumerate(rows):
            tags = ("evenrow", "oddrow")[i % 2]
            tags=(tags, "delete_tag")
            tree.insert("", "end", values=row, tags=tags)
        
    def load_view_data(self, view_name, tree):
        query = f"SELECT * FROM {view_name}"
        result, cursor, error = self.dbhelper.execute_query(query, select_query=True)
        if not result:
            messagebox.showinfo("Error", f"Error: {error}")

        rows = [list(row) for row in cursor.fetchall()]

        for item in tree.get_children():
            tree.delete(item)

        for i, row in enumerate(rows):
            tags = ("evenrow", "oddrow")[i % 2]
            tree.insert("", "end", values=row, tags=tags)

    def update_cell(self, event, table_name, tree, entry, item, col_name):
        new_value = entry.get()

        # Update the value in the database
        primary_key = tree.item(item, "values")[0]  # Assuming the first column is the primary key

        if table_name in config.db_info['tables'] and config.db_info['tables'][table_name]['update']['update_type'] == 'Procedure':
            query = f"EXEC {config.db_info['tables'][table_name]['update']['procedure_name']} {primary_key}" # ToDo: specific input params
        else:
            query = f"UPDATE {table_name} SET {col_name} = '{new_value}' WHERE {self.dbhelper.get_primary_key_condition(table_name, primary_key)}"

        result, _, error = self.dbhelper.execute_query(query)
        if result:
            # Update the value in the Treeview
            tree.set(item, col_name, new_value)
            self.reload_all_tabs()
        else:
            messagebox.showinfo("Error", f"Error: {error}")

        # Destroy the entry widget
        entry.destroy()

    def delete_selected_item(self, table_name, tree, event=None):
        # If the event is triggered by the delete button, get the item under the cursor
        if event:
            item = tree.identify_row(event.y)
            if not item:
                return

        # Get the primary key value for the selected item
        primary_key_value = tree.item(item, "values")[0]
        # Ask for confirmation before deletion
        result = messagebox.askyesno("Confirm Deletion", "Are you sure you want to delete this item?")
        if result:
            if table_name in config.db_info['tables'] and config.db_info['tables'][table_name]['delete']['delete_type'] == 'Procedure':
                query = f"EXEC {config.db_info['tables'][table_name]['delete']['procedure_name']} {primary_key_value}" # ToDo: specific input params
            else:
                if self.dbhelper.get_primary_key_condition(table_name, primary_key_value):
                    query = f"DELETE FROM {table_name} WHERE {self.dbhelper.get_primary_key_condition(table_name, primary_key_value)}"
                else:
                    query = f"DELETE FROM {table_name} WHERE {self.dbhelper.get_primary_key_condition(table_name, primary_key_value)}"

            result, _, error = self.dbhelper.execute_query(query)
            if result:
                self.reload_all_tabs()
            else:
                messagebox.showinfo("Error", f"Error: {error}")

    def add_item(self, table_name, entry_values, tree):
        data = {col: entry.get() for col, entry in entry_values.items()}
        columns = ', '.join(data.keys())
        values = ', '.join([f"'{value}'" for value in data.values()])
        if table_name in config.db_info['tables'] and config.db_info['tables'][table_name]['insert']['insert_type'] == 'Procedure':
            query = f"EXEC {config.db_info['tables'][table_name]['insert']['procedure_name']} {values}"
        else:
            query = f"INSERT INTO {table_name} ({columns}) VALUES ({values})"
        result, _, error = self.dbhelper.execute_query(query)
        if result:
            self.reload_all_tabs()
            # Clear entry values after successful addition
            for entry in entry_values.values():
                entry.delete(0, tk.END)
            # Set focus on the first entry after successful addition
            first_entry = next(iter(entry_values.values()))
            first_entry.focus_set()
        else:
            messagebox.showinfo("Error", f"Error: {error}")
