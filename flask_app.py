from flask import Flask

'''
# Cron Job at 10 seconds interval
import time
import atexit
import os

from apscheduler.schedulers.background import BackgroundScheduler

def print_hello_timestamp(folder):
    file = open(os.path.join(folder,'hello.txt'), 'a+')
    file.write(time.strftime("%m/%d/%Y %H:%M:%S ")+ "Hello Word \n")
    file.close()


write_folder = str(os.environ.get("WRITE_FOLDER", "/tmp"))
scheduler = BackgroundScheduler()
scheduler.add_job(func=print_hello_timestamp, args=[write_folder], trigger="interval", seconds=10)
scheduler.start()

# Shut down the scheduler when exiting the app
atexit.register(lambda: scheduler.shutdown())
'''

app = Flask(__name__)

@app.route("/")
def hello():
    return "Hello World!"


if __name__ == "__main__":
    app.run(debug=True,host='0.0.0.0',port=8000)
