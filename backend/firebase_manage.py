import firebase_admin
from firebase_admin import credentials, messaging

# 🔥 Cargar credenciales del archivo JSON de la cuenta de servicio
cred = credentials.Certificate("D:/LaptopSemesters/6to/AplicacionesMoviles/FlutterProjects/U3/Tarea_MenuContextualBanco/backend/banco-bapiriya.json")  # Reemplázalo con la ruta real
firebase_admin.initialize_app(cred)

def send_push_notification(token, sender, amount):
    message = messaging.Message(
        notification=messaging.Notification(
            title=" Transferencia recibida",
            body=f"Has recibido ${amount} de {sender}",
        ),
        token=token,
    )

    response = messaging.send(message)
    print(" Notificación enviada con éxito:", response)
