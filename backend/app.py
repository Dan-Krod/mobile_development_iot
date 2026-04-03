from flask import Flask, request, jsonify
from flask_cors import CORS
import sqlite3
import jwt
import datetime
import os

app = Flask(__name__)
CORS(app) 

SECRET_KEY = "iot_secret_key"
DB_NAME = "backend/iot_system.db" 

def init_db():
    conn = sqlite3.connect(DB_NAME)
    c = conn.cursor()
    
    c.execute('''CREATE TABLE IF NOT EXISTS users (
                    fullName TEXT, 
                    email TEXT PRIMARY KEY, 
                    password TEXT,
                    hardware TEXT, 
                    database TEXT)''')
    
    c.execute('''CREATE TABLE IF NOT EXISTS tanks (
                    id TEXT PRIMARY KEY,
                    userEmail TEXT,
                    title TEXT,
                    currentLevel REAL,
                    capacity REAL,
                    unit TEXT,
                    colorValue INTEGER,
                    isHardwareBound BOOLEAN)''')
    
    c.execute('''CREATE TABLE IF NOT EXISTS logs (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    userEmail TEXT, 
                    action TEXT, 
                    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP)''')
    conn.commit()
    conn.close()

init_db()

def get_db_connection():
    conn = sqlite3.connect(DB_NAME)
    conn.row_factory = sqlite3.Row
    return conn

@app.route('/api/auth/register', methods=['POST'])
def register():
    data = request.json
    try:
        conn = get_db_connection()
        conn.execute('''INSERT INTO users (fullName, email, password, hardware, database) 
                        VALUES (?, ?, ?, ?, ?)''',
                        (data.get('fullName'), data.get('email'), data.get('password'), 
                        data.get('hardware', 'ESP32-S3'), data.get('database', 'SQLite')))
        conn.commit()
        return jsonify({"message": "User registered successfully"}), 201
    except sqlite3.IntegrityError:
        return jsonify({"error": "Email already exists"}), 400
    finally:
        conn.close()

@app.route('/api/auth/login', methods=['POST'])
def login():
    data = request.json
    conn = get_db_connection()
    user = conn.execute('SELECT * FROM users WHERE email = ? AND password = ?', 
                        (data.get('email'), data.get('password'))).fetchone()
    conn.close()

    if user:
        token = jwt.encode({
            'email': user['email'],
            'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=24)
        }, SECRET_KEY, algorithm="HS256")
        
        log_action(user['email'], "SYSTEM LOGIN")

        return jsonify({
            "token": token,
            "user": dict(user) 
        }), 200
    return jsonify({"error": "Invalid credentials"}), 401

@app.route('/api/auth/update', methods=['PUT'])
def update_user():
    data = request.json
    try:
        conn = get_db_connection()
        conn.execute('''UPDATE users 
                        SET fullName = ?, hardware = ?, database = ? 
                        WHERE email = ?''',
                        (data.get('fullName'), data.get('hardware'), data.get('database'), data.get('email')))
        conn.commit()
        log_action(data.get('email'), "PROFILE UPDATED")
        return jsonify({"message": "User updated successfully"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

@app.route('/api/tanks', methods=['GET'])
def get_tanks():
    user_email = request.args.get('email')
    if not user_email:
        return jsonify({"error": "Email is required"}), 400
        
    conn = get_db_connection()
    tanks = conn.execute('SELECT * FROM tanks WHERE userEmail = ?', (user_email,)).fetchall()
    conn.close()
    return jsonify([dict(tank) for tank in tanks]), 200

@app.route('/api/tanks', methods=['POST'])
def save_tank():
    data = request.json
    try:
        conn = get_db_connection()
        conn.execute('''INSERT OR REPLACE INTO tanks 
                        (id, userEmail, title, currentLevel, capacity, unit, colorValue, isHardwareBound) 
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?)''',
                        (data.get('id'), data.get('userEmail'), data.get('title'), 
                        data.get('currentLevel'), data.get('capacity'), data.get('unit', 'L'),
                        data.get('colorValue'), data.get('isHardwareBound')))
        conn.commit()
        return jsonify({"message": "Tank saved successfully"}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        conn.close()

@app.route('/api/logs', methods=['GET', 'POST'])
def handle_logs():
    conn = get_db_connection()
    if request.method == 'POST':
        data = request.json
        conn.execute('INSERT INTO logs (userEmail, action) VALUES (?, ?)', 
                        (data.get('email', 'system'), data.get('action')))
        conn.commit()
        conn.close()
        return jsonify({"message": "Log saved"}), 201
    else:
        logs = conn.execute('SELECT * FROM logs ORDER BY timestamp DESC LIMIT 20').fetchall()
        conn.close()
        return jsonify([dict(log) for log in logs]), 200

@app.route('/api/auth/delete', methods=['DELETE'])
def delete_account():
    email = request.args.get('email')
    if not email:
        return jsonify({"error": "Email required"}), 400

    conn = get_db_connection()
    conn.execute('DELETE FROM users WHERE email = ?', (email,))
    conn.execute('DELETE FROM tanks WHERE userEmail = ?', (email,))
    conn.commit()
    conn.close()
    return jsonify({"message": "Account completely deleted"}), 200

def log_action(email, action):
    conn = get_db_connection()
    conn.execute('INSERT INTO logs (userEmail, action) VALUES (?, ?)', (email, action))
    conn.commit()
    conn.close()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)