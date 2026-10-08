# main.py - arranque de la API de GestorMaterial


from fastapi import FastAPI
from conexion import conectar

app = FastAPI(title="Test de Conexión GestorMaterial")

@app.get("/")
def probar_conexion():
    try:
        # Conexión a PostgreSQL
        conn = conectar()
        cursor = conn.cursor()
        
        # Consulta de prueba a la tabla creada
        cursor.execute("SELECT COUNT(*) AS total FROM usuarios;")
        resultado = cursor.fetchone()
        
        # Cierre de la conexión para no dejarla colgada
        cursor.close()
        conn.close()
        
        # Resultado de la conexión y consulta
        return {
            "estado": "OK. Conexión a PostgreSQL",
            "usuarios_registrados": resultado["total"],
            "mensaje": "Conexión y prueba sin errores"
        }
        
    except Exception as e:
        return {
            "estado": "Error al conectar con pgAdmin4",
            "detalle_del_error": str(e)
        }