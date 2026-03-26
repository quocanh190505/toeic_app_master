from fastapi import FastAPI

from app.routers import auth, progress, questions

app = FastAPI(title='TOEIC Master Pro API')

app.include_router(auth.router)
app.include_router(progress.router)
app.include_router(questions.router)


@app.get('/')
def root():
    return {'message': 'TOEIC Master Pro API is running'}
