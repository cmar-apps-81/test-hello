from flask import (
    Blueprint, request
)

bp = Blueprint('root', __name__, url_prefix='/')

# GET /health
#  health check
@bp.get('/health')
def health():
    return {}, 200


