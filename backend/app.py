from flask import Flask
import pytesseract
import cv2
import re

app = Flask(__name__)

@app.route("/scan", method=["POST"])
def scan_cv():
    return 'tes'
