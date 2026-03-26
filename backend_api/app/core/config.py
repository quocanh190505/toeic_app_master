from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    mysql_url: str = "mysql+pymysql://toeic_user:19052005@localhost:3306/toeic_master"
    jwt_secret: str = "super_secret_key"

    class Config:
        env_file = ".env"


settings = Settings()