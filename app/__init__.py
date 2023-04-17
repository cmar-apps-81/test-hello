import os

from flask import Flask, request
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate

db = SQLAlchemy()

def create_app(config=None):
    # create and configure the app
    app = Flask(__name__, instance_relative_config=True)

    app.config.from_mapping(
        SECRET_KEY='dev',
        SQLALCHEMY_DATABASE_URI = os.getenv('DATABASE_URL')
    )

    if config is not None:
        # load the test config if passed in
        app.config.from_mapping(config)

    db.init_app(app)
    migrate = Migrate(app,db)

    from . import root
    app.register_blueprint(root.bp)

    from . import hello
    app.register_blueprint(hello.bp)

    return app

