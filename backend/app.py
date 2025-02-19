import datetime
from flask import Flask, request, jsonify, send_file
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
import io

app = Flask(__name__)

# Configuración de CORS (permitir desde cualquier origen, puedes restringirlo a tu frontend específico)
CORS(app, resources={r"/api/*": {"origins": "http://localhost:43293"}})

# Configuración de la base de datos
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql://root:1234@localhost/banco_DB'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

# Modelo de la tabla de pagos
class Payment(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, nullable=False) 
    amount = db.Column(db.Numeric(10, 2), nullable=False)
    status = db.Column(db.Enum('pending', 'completed', 'failed', name='status_enum'), default='pending')
    created_at = db.Column(db.DateTime, server_default=db.func.now())

    def __repr__(self):
        return f'<Payment {self.id}>'


# Modelo de la tabla de transacciones
class Transaction(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    payment_id = db.Column(db.Integer, db.ForeignKey('payment.id'), nullable=False) 
    card_number = db.Column(db.String(16), nullable=False)
    amount = db.Column(db.Float, nullable=False)
    status = db.Column(db.String(50), nullable=False)
    created_at = db.Column(db.DateTime, server_default=db.func.now())
    description = db.Column(db.String(20), nullable=False)

    payment = db.relationship('Payment', backref=db.backref('transactions', lazy=True)) 

    def __repr__(self):
        return f'<Transaction {self.id}>'
    
class User(db.Model):
    __tablename__ = 'user'
    
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(255), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    created_at = db.Column(db.TIMESTAMP, default=datetime.UTC)
    account_number = db.Column(db.String(20), unique=True, nullable=False)
    balance = db.Column(db.Numeric(10, 2), default=0.00, nullable=False)
    
    cards = db.relationship('Card', backref='user', lazy=True)

class Card(db.Model):
    __tablename__ = 'card'
    
    id = db.Column(db.BigInteger, primary_key=True, autoincrement=True)
    card_holder_name = db.Column(db.String(255), nullable=True)
    card_number = db.Column(db.String(255), nullable=True)
    created_at = db.Column(db.DateTime, default=datetime.UTC)
    cvv = db.Column(db.String(255), nullable=True)
    expiration_date = db.Column(db.Date, nullable=True)
    is_frozen = db.Column(db.Boolean, nullable=False, default=False)
    user_id = db.Column(db.BigInteger, db.ForeignKey('user.id'), nullable=True)
    

# Modelo de Transferencias
class Transfer(db.Model):
    __tablename__ = 'transferencia'
    
    id = db.Column(db.Integer, primary_key=True)
    noCuentaOrigen = db.Column(db.Integer, nullable=False)
    noCuentaDestino = db.Column(db.Integer, nullable=False)
    amount = db.Column(db.Numeric(10, 2), nullable=False)
    create_at = db.Column(db.DateTime, server_default=db.func.now()) 

    def __repr__(self):
        return f'<Transfer {self.id}>'

@app.route('/api/payments', methods=['POST'])
def process_payment():
    data = request.get_json()

    user_id = data.get('user_id')
    amount = data.get('amount')
    card_number = data.get('card_number')

    if not user_id or not amount or not card_number:
        return jsonify({'error': 'Monto, tarjeta y usuario son necesarios'}), 400

    if amount <= 0:
        return jsonify({'error': 'Monto inválido'}), 400

    # Verificar si el usuario existe y obtener su balance
    user = User.query.filter_by(id=user_id).first()
    if not user:
        return jsonify({'error': 'Usuario no encontrado'}), 404

    # Verificar si la tarjeta pertenece al usuario
    card = Card.query.filter_by(user_id=user_id, card_number=card_number).first()
    if not card:
        return jsonify({'error': 'Tarjeta no válida para este usuario'}), 400

    # Verificar si el usuario tiene saldo suficiente
    if user.balance < amount:
        return jsonify({'error': 'Fondos insuficientes'}), 400

    try:
        # Restar el monto del balance del usuario
        user.balance -= amount
        db.session.commit()

        # Guardar el pago en la base de datos
        payment = Payment(user_id=user_id, amount=amount, status='completed')
        db.session.add(payment)
        db.session.commit()

        # Crear la transacción relacionada
        transaction = Transaction(
            payment_id=payment.id,
            card_number=card_number,
            amount=amount,
            status='completed',
            description='pago'
        )
        db.session.add(transaction)
        db.session.commit()

        return jsonify({
            'message': 'Pago procesado correctamente',
            'payment': {
                'id': payment.id,
                'amount': payment.amount,
                'status': payment.status,
                'created_at': payment.created_at
            },
            'transaction': {
                'id': transaction.id,
                'card_number': transaction.card_number,
                'amount': transaction.amount,
                'status': transaction.status,
                'created_at': transaction.created_at
            }
        }), 200
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Error en el procesamiento del pago: {str(e)}'}), 500



# Endpoint para obtener el historial de transacciones en JSON
@app.route('/api/transactions', methods=['GET'])
def get_transactions():
    transactions = Transaction.query.all()
    transaction_list = [
        {
            'card_number': trans.card_number,
            'amount': trans.amount,
            'status': trans.status,
            'created_at': trans.created_at
        } for trans in transactions
    ]
    return jsonify(transaction_list), 200

# Endpoint para descargar el historial de transacciones en PDF
@app.route('/api/transactions/pdf', methods=['GET'])
def download_pdf():
    transactions = Transaction.query.all()
    buffer = io.BytesIO()
    c = canvas.Canvas(buffer, pagesize=letter)
    width, height = letter

    c.drawString(100, height - 100, "Historial de Transacciones")
    y_position = height - 120

    for trans in transactions:
        c.drawString(100, y_position, f"Card: {trans.card_number} | Amount: {trans.amount} | Status: {trans.status}")
        y_position -= 20

    c.showPage()
    c.save()
    buffer.seek(0)

    return send_file(buffer, as_attachment=True, download_name="transactions.pdf", mimetype="application/pdf")

# Funcion para las transferencias entre un usuario a otro usuario...
@app.route('/api/transfer', methods=['POST'])
def transfer():
    data = request.get_json()
    noCuentaOrigen = data.get('sender')
    noCuentaDestino = data.get('receiver')
    amount = data.get('amount')
    
    if not noCuentaOrigen or not noCuentaDestino or not amount:
        return jsonify({'error': 'El id del emisor, el id del receptor y el monto son necesarios'}), 400

    if amount <= 0:
        return jsonify({'error': 'Monto inválido'}), 400

    # Verificar si el usuario emisor existe y obtener su balance
    sender = User.query.filter_by(account_number=noCuentaOrigen).first()
    if not sender:
        return jsonify({'error': 'Usuario emisor no encontrado'}), 404

    # Verificar si el usuario receptor existe y obtener su balance
    receiver = User.query.filter_by(account_number=noCuentaDestino).first()
    if not receiver:
        return jsonify({'error': 'Usuario receptor no encontrado'}), 404

    # Verificar si el usuario emisor tiene saldo suficiente
    if sender.balance < amount:
        return jsonify({'error': 'Fondos insuficientes'}), 400

    try:
        # Restar el monto del balance del usuario emisor
        sender.balance -= amount
        db.session.commit()

        # Sumar el monto al balance del usuario receptor
        receiver.balance += amount
        db.session.commit()
        
        # Guardar la transferencia en la base de datos
        trans = Transfer(noCuentaOrigen=noCuentaOrigen, noCuentaDestino=noCuentaDestino, amount=amount)
        db.session.add(trans)
        db.session.commit()
        
        # obtener el user_id del emisor
        user_id = User.query.filter_by(account_number=noCuentaOrigen).first().id
        
        # Guardar el pago en la base de datos
        payment = Payment(user_id=user_id, amount=amount, status='completed')
        db.session.add(payment)
        db.session.commit()
        
        # Crear la transacción relacionada
        transaction = Transaction(
            payment_id=payment.id,
            card_number=noCuentaOrigen,
            amount=amount,
            status='completed',
            description='transferencia'
        )
        db.session.add(transaction)
        db.session.commit()

        return jsonify({
            'message': 'Transferencia realizada correctamente',
            'sender': {
                'id': sender.id,
                'balance': sender.balance
            },
            'receiver': {
                'id': receiver.id,
                'balance': receiver.balance
            },
            'amount': amount,
            'created_at': datetime.datetime.now()
        }), 200
    
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'Error en la transferencia: {str(e)}'}), 500

if __name__ == '__main__':
    app.run(debug=True)
