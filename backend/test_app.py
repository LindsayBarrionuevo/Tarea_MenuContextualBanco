import pytest
from app import app, db, User, Card, Payment, Transaction

@pytest.fixture
def client():
    app.config['TESTING'] = True
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///:memory:'
    with app.test_client() as client:
        with app.app_context():
            db.create_all()
            # Add test data
            user = User(email='test@example.com', password_hash='hashed_password', account_number='1234567890', balance=1000.00)
            db.session.add(user)
            db.session.commit()
            card = Card(user_id=user.id, card_number='1111222233334444')
            db.session.add(card)
            db.session.commit()
        yield client

def test_process_payment_valid(client):
    response = client.post('/api/payments', json={
        'user_id': 1,
        'amount': 100.00,
        'card_number': '1111222233334444'
    })
    assert response.status_code == 200
    assert response.json['message'] == 'Pago procesado correctamente'

def test_process_payment_invalid_amount(client):
    response = client.post('/api/payments', json={
        'user_id': 1,
        'amount': -100.00,
        'card_number': '1111222233334444'
    })
    assert response.status_code == 400
    assert response.json['error'] == 'Monto inválido'

def test_get_transactions(client):
    response = client.get('/api/transactions')
    assert response.status_code == 200
    assert isinstance(response.json, list)

def test_download_pdf(client):
    response = client.get('/api/transactions/pdf')
    assert response.status_code == 200
    assert response.headers['Content-Type'] == 'application/pdf'