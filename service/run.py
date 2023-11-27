import uvicorn


def start():
    uvicorn.run(
        "service.ports.input.api:app",
        host="0.0.0.0",
        port=8080,
        workers=1,
    )
