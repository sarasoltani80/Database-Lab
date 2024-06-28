# conn_str = 'DRIVER={SQL Server};SERVER=localhost,1434;DATABASE=carwash;UID=login_mrmim;PWD=admin123'
conn_str = 'DRIVER={SQL Server};SERVER=localhost,1434;DATABASE=SampleDatabase2;UID=login_mrmim;PWD=admin123'
# conn_str = 'DRIVER={SQL Server};SERVER=localhost,1434;DATABASE=AdventureWorks2012;UID=login_mrmim;PWD=admin123'

db_info = {
    'tables': {
        'dbo.Orders': {
            'insert': {
                'insert_type': 'Procedure', # Or 'INSERT'
                'procedure_name': 'AddNewOrder', # Only if insert_type is 'Procedure'
                'procedure_input_params': ['CustomerID', 'VehicleID', 'ServiceID', 'NewOrderID'] # Only if insert_type is 'Procedure'
            },
            'update': {
                'update_type': 'UPDATE' # Or 'Procedure' like insert
            },
            'delete': {
                'delete_type': 'DELETE' # Or 'Procedure' like insert
            },
            'select': {     
                'select_type': 'SELECT' # Or 'SELECT'
            },
            'columns_to_show_when_referenced': [] # Columns to show when referenced to this table
        },
        'dbo.Customers': {
            'insert': {
                'insert_type': 'Procedure',
                'procedure_name': 'AddNewCustomer',
                'procedure_input_params': ['Name', 'Phone', 'Email', 'Address', 'EmployeeRole']
            },
            'update': {
                'update_type': 'UPDATE'
            },
            'delete': {
                'delete_type': 'DELETE'
            },
            'select': {
                'select_type': 'SELECT'
            },
            'columns_to_show_when_referenced': ['CustomerID', 'Name']
        },
        'dbo.Vehicles': {
            'insert': {
                'insert_type': 'Procedure',
                'procedure_name': 'AddNewVehicle',
                'procedure_input_params': ['LicensePlate', 'Model', 'VehicleType', 'PricingFactor', 'EmployeeRole']
            },
            'update': {
                'update_type': 'UPDATE'
            },
            'delete': {
                'delete_type': 'DELETE'
            },
            'select': {
                'select_type': 'SELECT'
            },
            'columns_to_show_when_referenced': ['VehicleID', 'LicensePlate', 'Model']
        },
        'dbo.Services': {
            'insert': {
                'insert_type': 'Procedure',
                'procedure_name': 'AddNewService',
                'procedure_input_params': ['ServiceName', 'Description', 'Price', 'EmployeeRole']
            },
            'update': {
                'update_type': 'UPDATE'
            },
            'delete': {
                'delete_type': 'DELETE'
            },
            'select': {
                'select_type': 'SELECT'
            },
            'columns_to_show_when_referenced': ['ServiceID', 'ServiceName']
        },
        'dbo.Feedbacks': {
            'insert': {
                'insert_type': 'Procedure',
                'procedure_name': 'AddNewFeedback',
                'procedure_input_params': ['CustomerID', 'ServiceID', 'Rating', 'Comments', 'EmployeeRole']
            },
            'update': {
                'update_type': 'UPDATE'
            },
            'delete': {
                'delete_type': 'DELETE'
            },
            'select': {
                'select_type': 'SELECT'
            },
            'columns_to_show_when_referenced': []
        },
        'dbo.Employees': {
            'insert': {
                'insert_type': 'Procedure',
                'procedure_name': 'AddNewEmployee',
                'procedure_input_params': ['Name', 'Phone', 'Email', 'Role', 'AdminRole']
            },
            'update': {
                'update_type': 'UPDATE'
            },
            'delete': {
                'delete_type': 'DELETE'
            },
            'select': {
                'select_type': 'SELECT'
            },
            'columns_to_show_when_referenced': []
        },
        'dbo.PaymentTransactions': {
            'insert': {
                'insert_type': 'Procedure',
                'procedure_name': 'ProcessOrderPayments',
                'procedure_input_params': ['OrderIDs', 'PaymentType']
            },
            'update': {
                'update_type': 'UPDATE'
            },
            'delete': {
                'delete_type': 'DELETE'
            },
            'select': {
                'select_type': 'SELECT'
            },
            'columns_to_show_when_referenced': ['TransactionID']
        },
    },
}
