# Proyecto Intermodular: GestorMaterial
**Alumno:** Elías Martínez

## 1. Resumen contenido

App móvil para que un operario de taller registre en pocos segundos lo que gasta o se lleva del almacén, escaneando un QR con la cámara del móvil.

- **Consumibles** (material "abundante", como cables, conectores, tornillería...): se escanea o se busca la pieza y se suma o resta stock con los botones +1 / -1.
- **Maquinaria** (material más valioso o escaso, como herramientas, medidores...): cada unidad tiene su propio QR. Se escanea para cogerla y para devolverla. Si vuelve con daños, se reporta una incidencia y pasa a mantenimiento.


## 2. Arquitectura del sistema:

- App móvil: React Native con Expo (cámara para QR o código de barras)
- API: Python con FastAPI o similar.
- Base de datos: PostgreSQL

## 3. Roles

- **Operario:** busca y escanea material, registra consumo, coge y devuelve herramientas, reporta incidencias.
- **Administrador:** todo lo del operario, y además da de alta material, ve el estado del almacén, resuelve incidencias y bloquea o reserva material.

### Mejoras a futuro (NO se desarrolla en este proyecto, pero se deja preparado)
- Auditoría fotográfica al coger y dejar una máquina.
- Modo offline con cola de peticiones.

Como mucho, si da tiempo, se deja la base de datos preparada (columnas que admitan nulos). Ni la toma de fotos ni el modo offline se programan.

## 5. Reglas de negocio (para no olvidarme de ninguna)

- Usuarios con sesión individual (id operario).
- Las contraseñas se guardan con hash, quedarian expuestas.
- El stock nunca puede quedar en negativo (si no hay no se puede restar)
- El operario solo puede restar de (stock actual y stock reservado para él)
- Una máquina solo se puede coger si está "Disponible"(no reservada)
- ** investigar** Evitar que dos personas se lleven la misma máquina.
- La devolución la hace el titular del préstamo o un administrador
- Una incidencia deja la máquina "En mantenimiento" hasta que el admin la de de alta o baja.
- Cada movimiento de consumible queda guardado en el histórico (importante para el inventario real, por si no coincide)
- Si una máquina está reservada por admin, la app avisa al operario al escanearla o en busqueda (solo no disponible, no dar información de más).

## 6. Modelo de datos (resumen para que no se me olvide)

1. **Usuarios:** nombre, email, contraseña (con hash), rol.
2. **Catálogo maestro:** nombre, descripción, categoría, EAN (opcional), tipo (consumible o maquinaria).
3. **Inventario físico:**
   - Consumibles: stock actual, stock mínimo, stock reservado. Un QR o codigo de barras por artículo (no ambos).
   - Maquinaria: una fila por unidad, con QR propio y estado (Disponible, En uso, En mantenimiento, Reservado por gerencia).
4. **Historial de cada artículo:** préstamos, incidencias, movimientos de consumibles y reservas (muy importante para cotejar si fallan los inventarios)

## 7. Estructura de carpetas
```
Carpeta       | Contenido

- backend/    | API 
- app/        | App Expo / React Native
- sql/        | gestormaterial.sql y datos_prueba.sql
- README.md   | 
```

## 9. Cómo arrancarlo en local

**Base de datos:** crear la BD `gestormaterial` en PostgreSQL y ejecutar `sql/schema.sql` y `sql/datos_prueba.sql`.

## 10. Decisiones tomadas

- Estado de una máquina prestada: `en_uso`
- Stock en números enteros (por ejemplo, el cable se mide en metros enteros, sin decimales)
- Fotos y modo offline: columnas a NULL, no se programan, pero si da tiempo las dejo preparadas.
- Material bloqueado por el admin: `activo = FALSE` (**comprobar si con esto el operario no lo ve)
- Sin triggers en SQL: los cambios de estado y las reglas de stock las haré en la API.