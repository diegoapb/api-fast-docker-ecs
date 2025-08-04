from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional
import uvicorn
import os

# Crear la instancia de FastAPI
app = FastAPI(
    title="Simple API",
    description="Una API simple para demostrar containerización y despliegue en AWS",
    version="1.0.0"
)

# Modelos Pydantic
class Item(BaseModel):
    id: Optional[int] = None
    name: str
    description: Optional[str] = None
    price: float
    is_available: bool = True

class ItemResponse(BaseModel):
    id: int
    name: str
    description: Optional[str] = None
    price: float
    is_available: bool

# Base de datos simulada en memoria
items_db = []
item_counter = 1

# Endpoint de health check
@app.get("/")
async def root():
    return {"message": "¡API funcionando correctamente!", "status": "healthy"}

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "Simple API"}

# Obtener todos los items
@app.get("/items", response_model=List[ItemResponse])
async def get_items():
    return items_db

# Obtener un item por ID
@app.get("/items/{item_id}", response_model=ItemResponse)
async def get_item(item_id: int):
    item = next((item for item in items_db if item["id"] == item_id), None)
    if not item:
        raise HTTPException(status_code=404, detail="Item no encontrado")
    return item

# Crear un nuevo item
@app.post("/items", response_model=ItemResponse)
async def create_item(item: Item):
    global item_counter
    new_item = {
        "id": item_counter,
        "name": item.name,
        "description": item.description,
        "price": item.price,
        "is_available": item.is_available
    }
    items_db.append(new_item)
    item_counter += 1
    return new_item

# Actualizar un item
@app.put("/items/{item_id}", response_model=ItemResponse)
async def update_item(item_id: int, item: Item):
    existing_item = next((item for item in items_db if item["id"] == item_id), None)
    if not existing_item:
        raise HTTPException(status_code=404, detail="Item no encontrado")
    
    existing_item.update({
        "name": item.name,
        "description": item.description,
        "price": item.price,
        "is_available": item.is_available
    })
    return existing_item

# Eliminar un item
@app.delete("/items/{item_id}")
async def delete_item(item_id: int):
    global items_db
    item = next((item for item in items_db if item["id"] == item_id), None)
    if not item:
        raise HTTPException(status_code=404, detail="Item no encontrado")
    
    items_db = [item for item in items_db if item["id"] != item_id]
    return {"message": "Item eliminado correctamente"}

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)
