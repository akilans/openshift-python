from flask_app import app
import unittest

# python -m unittest test_flask_app

class TestMyApp(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()

    def test_main(self):
        res = self.app.get('/')
        self.assertEqual(res.status, '200 OK')
        self.assertIn(b'Hello World!', res.data)

    def test_404(self):
        res = self.app.get('/other')
        self.assertEqual(res.status, '404 NOT FOUND')