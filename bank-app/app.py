from flask import Flask, jsonify, render_template_string
import socket

app = Flask(__name__)

# HTML template
HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
	<title>Zero Trust Bank</title>
	<style>
		body { font-family: sans-serif; text-align: center; padding: 50px; background-color: #f0f2f5;}
		.card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); display: inline-block; }
		h1 { color: #1a73e8; }
		.balance { font-size: 2em; color: #28a745; font-weight: bold; }
		.id { color: #666; font-size: 0.8em; margin-top: 20px; }
	</style>
</head>
<body>

@app.route('/')
def home():
	return render_
	<div class="card">
		<h1>Zero Trust Bank</h1>
		<p>Welcome back, User.</p>
		<div class="balance">$1,450,200.00</div>
		<p>Status: <span style="color:greem">● Secure</span></p>
		<div class="id">Server ID: {{ hostname }}</div>
	</div>
</body>
</html>
"""
@app.route('/')
def home():
	return render_template_string(HTML_TEMPLATE, hostname=socket.gethostname())

@app.route('/health')
def health():
	return jsonify({"status": "healthy"}), 200

if __name__ == '__main__':
	app.run(host='0.0.0.0', port=5000)
