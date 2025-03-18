## Enable mobile hotspot

The ip should be 192.168.137.1 in Local Area Connection* 10

If not, change de ip on enpoints used in flutter app "menulateralbanco_nuevo"

## DB

Start mysql service 

Ej: XAMP


## Backend Flask

cd backend/

### Crear entorno virtual

python env venv  #En windows

python3 venv venv #En linux

### Activar entorno virtual

.\env\Scripts\activate   #En windows

source venv/bin/activate  #En linux

### Librerias adicionales

pip install requirements.txt

### Iniciar servidor Flask

py app.py


## Backend Springboot 

Enter with Intellij IDEA to crud_mysql_service project

Run the project.

## Flutter APP 

cd menulateralbanco_nuevo/

flutter build apk --release 

Obtain apk from menulateralbanco_nuevo/build/app/outputs/apk/release

Install apk in physic mobile  # Mobile should be connected to Mobile hotspot created.



