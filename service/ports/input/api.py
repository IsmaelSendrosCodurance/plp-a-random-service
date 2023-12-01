import random
from http import HTTPStatus

from fastapi import FastAPI, HTTPException

app = FastAPI(
    title=f"PLP API",
    version="v1",
)


@app.get(
    path="/",
    summary="Healthcheck endpoint"
)
async def root():
    responses = [
        {
            'code': 200,
            'message': 'I\'m a teapot !!'
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

    if response['code'] == '200':
        return "I'm a random teapot!"
    else:
        raise HTTPException(status_code=HTTPStatus(response['code']),detail=response['message'])
