from app import db

# User object
class User(db.Model):
    __tablename__ = 'users'

    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    dateOfBirth = db.Column(db.Date)

    def __repr__(self):
        return f"<User {self.username}>"
