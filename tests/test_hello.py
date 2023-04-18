import os

from flask_testing import TestCase

from app import create_app, db

from datetime import date

CONFIG = dict(
    SQLALCHEMY_DATABASE_URI = "sqlite:///test.db",
    TESTING = True
)

class HelloTest(TestCase):

    def create_app(self):

        # pass in test configuration
        return create_app(CONFIG)

    def setUp(self):

        db.create_all()

    def tearDown(self):

        db.session.remove()
        db.drop_all()

    def test_baduser(self):
        username = "test123"
        response = self.client.get(f"/hello/{username}")
        self.assertEqual(response.status_code, 400)

    def test_ndays(self):

        username = "Kevin"
        goodYear = 1981
        ndays = 5

        dateGoodYear = date.today().replace(year=goodYear)
        dateOfBirth = dateGoodYear.replace(day=dateGoodYear.day + ndays)

        response = self.client.put(f"/hello/{username}", json={'dateOfBirth': dateOfBirth.isoformat()})
        self.assertEqual(response.status_code, 204)

        response = self.client.get(f"/hello/{username}")
        self.assertEqual(response.json, dict(message=f"Hello, {username}! Your birthday is in {ndays} day(s)"))

    def test_today(self):

        username = "Bob"
        goodYear = 1981
        dateOfBirth = date.today().replace(year=goodYear)

        response = self.client.put(f"/hello/{username}", json={'dateOfBirth': dateOfBirth.isoformat()})
        self.assertEqual(response.status_code, 204)

        response = self.client.get(f"/hello/{username}")
        self.assertEqual(response.json, dict(message=f"Hello, {username}! Happy birthday!"))
