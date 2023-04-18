import functools

from flask import (
    Blueprint, request
)

from app import db
from app.models import User

from datetime import datetime, date

bp = Blueprint('hello', __name__, url_prefix='/hello')

# PUT /username
@bp.put('/<string:username>')
def put(username):
    if username.isalpha():
        data = request.get_json()
        if data is not None:
            if 'dateOfBirth' in data:
                dateOfBirth = date.fromisoformat(data['dateOfBirth'])

                if dateOfBirth < date.today():
                    # check if user exists
                    user = User.query.filter_by(username=username).first()
                    if user is None:
                        # if doesn't exist create it
                        user = User(username=username, dateOfBirth=dateOfBirth)
                        db.session.add(user)
                    else:
                        # update the dateOfBirth field
                        user.dateOfBirth = dateOfBirth

                    # commit the transaction
                    db.session.commit()

                    # return 204
                    return {}, 204

    # bad request
    return {}, 400
 
# GET /username
@bp.get('/<string:username>')
def get(username):

    if username.isalpha():
        # get the user or return not found
        user = db.one_or_404(db.select(User).filter_by(username=username))

        # get today date
        today = date.today()
        dayOfBirth = user.dateOfBirth.replace(year=today.year)
        if dayOfBirth < today:
            dayOfBirth = user.dateOfBirth.replace(year=today.year + 1)

        # get n of days until the birthday
        ndays = abs((today - dayOfBirth).days)
        if ndays == 0:
            return { "message": f"Hello, {username}! Happy birthday!" }
        else:
            return { "message": f"Hello, {username}! Your birthday is in {ndays} day(s)" }

    # bad request
    return {}, 400

