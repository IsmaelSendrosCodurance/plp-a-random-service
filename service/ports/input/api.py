from fastapi import FastAPI

app = FastAPI(
    title=f"PLP API",
    version="v1",
)

@app.get(
    path="/",
    summary="Healthcheck endpoint"
)
async def root():
    return "I'm a random teapot!"