from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    mysql_url: str = "mysql+pymysql://root:123456@localhost:3306/toeic_master?charset=utf8mb4"
    jwt_secret: str = "super_secret_key"

    class Config:
        env_file = ".env"


settings = Settings()
