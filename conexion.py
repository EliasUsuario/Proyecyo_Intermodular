# conexión a la base de datos PostgreSQL


import os  # para leer las variables del .env
import psycopg2  # librería para conectar Python con PostgreSQL
from psycopg2.extras import RealDictCursor  # hace que cada fila salga como diccionario y no como tupla
from dotenv import load_dotenv  # para cargar el fichero .env

# cargo las variables del fichero .env en el entorno
load_dotenv()


def conectar():
    # abro una conexión nueva a la BD cada vez que se llama a esta función
    # los valores por defecto (los de la derecha) por si se me olvida el .env (menos la contraseña, que no se pone por seguridad)
    conn = psycopg2.connect(
        host=os.getenv("DB_HOST", "localhost"),
        port=os.getenv("DB_PORT", "5432"),
        dbname=os.getenv("DB_NAME", "gestormaterial"),
        user=os.getenv("DB_USER", "postgres"),
        password=os.getenv("DB_PASSWORD", ""),
        cursor_factory=RealDictCursor,  # así los resultados son diccionarios
    )
    return conn  # devuelvo la conexión para usarla en cada endpoint

# Cada endpoint abre su conexión y la cierra en el finally.
# Hacer pool de conexiones¿?