import random
from http import HTTPStatus

from fastapi import FastAPI, HTTPException
from starlette.requests import Request
from starlette.responses import Response

from service.application.logging.log import setup_logging
from service.application.logging.http_status_filter import http_status_code

setup_logging()

app = FastAPI(
    title=f"PLP API",
    version="v1",
)

@app.middleware("http")
async def log_http_status_code(request: Request, call_next):
    response: Response = await call_next(request)
    http_status_code.set(str(response.status_code))
    return response


@app.get(
    path="/",
    summary="Healthcheck endpoint"
)
async def root():
    responses = [
        {
            'code': 200,
            'message': 'I\'m a teapot 21 !!'
        },
        {
            'code': 404,
            'message': 'Teapot not found :('
        },
        {
            'code': 500,
            'message': 'Teapot broken !!!!!!'
        }
    ]

    response = random.choice(responses)

    if response['code'] == 200:
        return response['message']
    raise HTTPException(status_code=HTTPStatus(response['code']),detail=response['message'])