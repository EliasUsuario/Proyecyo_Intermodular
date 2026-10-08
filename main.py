# main.py - arranque de la API de GestorMaterial


from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import rutas_articulos 

app = FastAPI(title="GestorMaterial API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


app.include_router(rutas_articulos.router)

@app.get("/")
def inicio():
    return {"mensaje": "API de GestorMaterial funcionando correctamente"}