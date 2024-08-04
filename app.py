from flask import Flask, render_template, request, flash, redirect, url_for, session
import pymysql
import os

app = Flask(__name__)
app.config['SECRET_KEY'] = os.urandom(24).hex()

# Your database configuration
db_config = {
    'host': 'localhost',
    'user': 'root',
    'password': 'Reehan@786',
    'database': 'fms',
}

def validate_user_credentials(role, name):
    # Connect to MySQL database
    db = pymysql.connect(**db_config)
    cursor = db.cursor()

    # Validate user credentials based on the selected role
    cursor.execute(f"SELECT * FROM {role} WHERE name = %s", (name))
    user_data = cursor.fetchone()

    cursor.close()
    db.close()

    return user_data

@app.route('/', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        role = request.form['role']
        name = request.form['name']

        # Validate user credentials based on selected role
        user_data = validate_user_credentials(role, name)

        if user_data:
            
            print('Flash message:', 'Login successful!')
            # Store user-related information in the session
            session['user_data'] = user_data
            return redirect(url_for('farmer_dashboard'))
        else:
            flash('Invalid credentials. Please try again.')
            print('Flash message:', 'Invalid credentials. Please try again.')



    return render_template('index.html')
@app.route('/signup',methods=['GET','POST'])
def signup():
    if request.method == 'POST':
        role = request.form['role']
        name = request.form['name']
        user_data = validate_user_credentials(role,name)
        if not user_data:
            db = pymysql.connect(**db_config)
            cursor = db.cursor()

            phone_number = request.form['phone_number']
            if role == "farmers":
                dob = request.form['dob']
                insert_query = "INSERT INTO farmers (name, phone_number, dob) VALUES (%s, %s, %s)"
                cursor.execute(insert_query, (name, phone_number, dob))
                db.commit()

            elif role == "customers":
                address = request.form['address']
                email_address = request.form['email']
                insert_query = "INSERT INTO customers (name, address, phone_number,email_address) VALUES (%s, %s, %s,%s)"
                cursor.execute(insert_query, (name, address, phone_number,email_address))
                db.commit()
           
            cursor.close()
            db.close()

        return redirect('/login')
    return render_template('signup.html')



@app.route('/farmer_dashboard')
def farmer_dashboard():
    # Retrieve user-related information from the session
    user_data = session.get('user_data')
    
    if not user_data:
        # Redirect to login if user is not in the session
        return redirect(url_for('login'))

    return render_template('dashboard.html', user_data=user_data)

#newly added code here
@app.route('/crops')
def crops():

    user_data = session.get('user_data')
    print(user_data)
    farmer_id = int(user_data[0])

    db = pymysql.connect(**db_config)
    cursor = db.cursor()
    # Fetch data from the database for Livestock
    cursor.execute('CALL GetFarmerCrops(%s)',(farmer_id))
    crop_data = cursor.fetchall()

    cursor.close()
    db.close()

    return render_template('crop.html', crop_data = crop_data)


@app.route('/livestock')
def livestock():
    user_data = session.get('user_data')
    farmer_id = int(user_data[0])
    
    db = pymysql.connect(**db_config)
    cursor = db.cursor()
    # Fetch data from the database for Livestock
    cursor.execute('CALL GetLivestockByFarmerId(%s)',(farmer_id))
    livestock_data = cursor.fetchall()
    cursor.close()
    db.close()

    return render_template('livestock.html', livestock_data=livestock_data)

@app.route('/equipments')
def equipments():
    user_data = session.get('user_data')
    print(user_data)
    farmer_id = int(user_data[0])
    db = pymysql.connect(**db_config)
    cursor = db.cursor()
    # Fetch data from the database for Equipment
    cursor.execute('CALL GetEquipmentByFarmerId(%s)',(farmer_id))
    equipment_data = cursor.fetchall()
    cursor.close()
    db.close()

    return render_template('equipment.html', equipment_data=equipment_data)

@app.route('/orders')
def orders():
    user_data = session.get('user_data')
    print(user_data)
    farmer_id = int(user_data[0])
    db = pymysql.connect(**db_config)
    cursor = db.cursor()
    # Fetch data from the database for Orders
    cursor.execute('CALL GetOrdersByFarmerId(%s)',(farmer_id))
    order_data = cursor.fetchall()
    cursor.close()
    db.close()

    return render_template('orders.html', order_data=order_data)


@app.route('/sales')
def sales():
    user_data = session.get('user_data')
    print(user_data)
    farmer_id = int(user_data[0])
    db = pymysql.connect(**db_config)
    cursor = db.cursor()
    # Fetch data from the database for Orders
    cursor.execute('CALL GetSalesByFarmerId(%s)',(farmer_id))
    crop_sales_data = cursor.fetchall()
    cursor.close()
    db.close()

    return render_template('sales.html', crop_sales_data=crop_sales_data)
@app.route('/employees')
def employees():
    user_data = session.get('user_data')
    farmer_id = int(user_data[0])
    db = pymysql.connect(**db_config)
    cursor = db.cursor()
    # Fetch data from the database for Orders
    cursor.execute('CALL GetEmployeesByFarmerId(%s)',(farmer_id))
    employee_data = cursor.fetchall()
    cursor.close()
    db.close()

    return render_template('employee.html', employee_data=employee_data)

@app.route('/expenses')
def expenses():
    user_data = session.get('user_data')
    farmer_id = int(user_data[0])
    db = pymysql.connect(**db_config)
    cursor = db.cursor()
    # Fetch data from the database for Orders
    cursor.execute('SELECT * from expenses where farmer_id = (%s)',(farmer_id))
    expenses_data = cursor.fetchall()
    cursor.close()
    db.close()

    return render_template('expenses.html', expenses_data=expenses_data)

@app.route('/addCrop',methods=['GET','POST'])
def addCrop():
    if request.method == 'POST':
        user_data = session.get('user_data')
        farm_id = int(user_data[0])
        variety = request.form['cropName']
        planting_date = request.form['plantedDate']
        harvesting_date = request.form['harvestingDate']
        expected_yield = request.form['expected_yield']
        db = pymysql.connect(**db_config)
        cursor = db.cursor()
        cursor.execute('INSERT INTO crops(farm_id, variety, planting_date, harvesting_date, expected_yield) VALUES (%s,%s,%s,%s,%s)',(farm_id,variety,planting_date,harvesting_date,expected_yield))
        db.commit()
        cursor.close()
        db.close()
        return redirect('crops')
    return render_template('addCrop.html')

@app.route('/removeCrop',methods=['GET','POST'])
def removeCrop():
    if request.method == 'POST':
        user_data = session.get('user_data')
        farm_id = int(user_data[0])
        id = int(request.form['cropID'])
        print(id)
        db = pymysql.connect(**db_config)
        cursor = db.cursor()
        cursor.execute('DELETE FROM crops WHERE crop_id = %s and farm_id = %s', (id,farm_id))
        db.commit()
        cursor.close()
        db.close()
        return redirect('crops')
    return render_template('removecrop.html')

if __name__ == '__main__':
    app.run(debug=True)
