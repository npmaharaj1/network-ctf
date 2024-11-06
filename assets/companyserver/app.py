from flask import Flask, request, redirect, url_for, render_template, send_from_directory
import subprocess as sp
import os

app = Flask(__name__)

UPLOAD_FOLDER = 'uploads'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

# Ensure the upload folder exists
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

@app.route('/')
def upload_form():
    return render_template('index.html')

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return 'No file part'
    file = request.files['file']
    if file.filename == '':
        return 'No selected file'
    if file:
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], file.filename)
        file.save(filepath)
        return f'File {file.filename} uploaded successfully to {UPLOAD_FOLDER}!'

@app.route('/uploads')
def list_files():
    # List the files in the upload directory
    files = os.listdir(app.config['UPLOAD_FOLDER'])
    files_list = ''.join([f'<li><a href="/uploads/{file}">{file}</a></li>' for file in files])
    return f'''
    <!doctype html>
    <title>Uploaded Files</title>
    <h1>List of Uploaded Files</h1>
    <ul>
        {files_list}
    </ul>
    '''

@app.route('/uploads/<filename>')
def uploaded_file(filename):
    # Serve the files from the uploads directory
    if filename.split(".", 1)[-1] if "." in filename else filename == "php":
        sp.run(["php", f"/uploads/{filename}"], stdout=sp.PIPE)
        return "about:blank"
    else:
        # print(filename.split(".", 1)[-1] if "." in filename else filename)
        return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

@app.route('/getstarted/')
def getstarted():
    return render_template('getstarted/index.html')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
