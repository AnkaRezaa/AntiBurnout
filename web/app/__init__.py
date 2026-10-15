import os
from flask import Flask
from app.config import config_by_name

def create_app(config_name=None):
    """Application factory untuk inisialisasi aplikasi Flask"""
    if not config_name:
        config_name = os.environ.get('FLASK_ENV', 'development')

    app = Flask(__name__)
    app.config.from_object(config_by_name.get(config_name, config_by_name['default']))

    # Registrasi Blueprints
    from app.routes.home_routes import home_bp
    from app.routes.auth_routes import auth_bp

    app.register_blueprint(home_bp)
    app.register_blueprint(auth_bp, url_prefix='/auth')

    return app
