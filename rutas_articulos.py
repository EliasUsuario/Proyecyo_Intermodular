
# rutas_articulos.py - catálogo maestro (artículos y categorías)

from fastapi import APIRouter
from conexion import conectar

# Configuracion del router. Todas las rutas aquí empezarán por /articulos
router = APIRouter(prefix="/articulos", tags=["Catálogo"])

@router.get("/")
def listar_articulos():
    try:
        conn = conectar()
        cursor = conn.cursor()
        
        # Consulta para obtener todos los artículos de la tabla "articulos"
        cursor.execute("""
            SELECT id_articulo, nombre, tipo, activo 
            FROM articulos 
            ORDER BY nombre;
        """)
        lista_articulos = cursor.fetchall()
        
        cursor.close()
        conn.close()
        
        return lista_articulos

    except Exception as e:
        return {"error": f"Error al obtener los artículos: {str(e)}"}