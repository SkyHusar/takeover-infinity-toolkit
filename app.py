#!/usr/bin/env python3
from flask import Flask, render_template, request, jsonify
import os
import subprocess
import json
from datetime import datetime

app = Flask(__name__, static_folder='/opt/takeover_infinity/web_panel/static', template_folder='/opt/takeover_infinity/web_panel/templates')

# Load configuration (e.g., API keys)
def load_config():
    config_path = '/opt/takeover_infinity/config/api_keys.conf'
    config = {}
    if os.path.exists(config_path):
        with open(config_path, 'r') as f:
            for line in f:
                if '=' in line:
                    key, value = line.strip().split('=', 1)
                    config[key.strip()] = value.strip()
    return config

# Get list of available tools from modules directory
def get_tools_list():
    modules_dir = '/opt/takeover_infinity/modules'
    tools = []
    if os.path.exists(modules_dir):
        for filename in os.listdir(modules_dir):
            if filename.endswith('.py'):
                tools.append(filename[:-3])  # Remove .py extension
    return sorted(tools)

@app.route('/')
def index():
    tools = get_tools_list()
    return render_template('index.html', tools=tools)

@app.route('/run_tool', methods=['POST'])
def run_tool():
    data = request.json
    tool_name = data.get('tool_name', '')
    target = data.get('target', '')
    if not tool_name or not target:
        return jsonify({'error': 'Tool name and target are required'})
    
    log_file = '/opt/takeover_infinity/logs/operation.log'
    try:
        # Execute the tool script using subprocess
        cmd = f"python3 /opt/takeover_infinity/modules/{tool_name}.py --target {target} --log {log_file}"
        output = subprocess.check_output(cmd, shell=True, text=True)
        return jsonify({'output': output})
    except subprocess.CalledProcessError as e:
        return jsonify({'error': f"Execution failed: {str(e.output)}"})
    except Exception as e:
        return jsonify({'error': f"Unexpected error: {str(e)}"})

@app.route('/view_logs', methods=['GET'])
def view_logs():
    log_file = '/opt/takeover_infinity/logs/operation.log'
    if os.path.exists(log_file):
        with open(log_file, 'r') as f:
            logs = f.read()
        return jsonify({'logs': logs})
    else:
        return jsonify({'logs': 'No logs available yet.'})

@app.route('/ai_generate', methods=['POST'])
def ai_generate():
    data = request.json
    prompt = data.get('prompt', '')
    if not prompt:
        return jsonify({'error': 'Prompt is required'})
    config = load_config()
    try:
        from openai import OpenAI
        client = OpenAI(api_key=config['openai_api_key'])
        completion = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[{"role": "user", "content": f"Generate a phishing email for {prompt}"}]
        )
        return jsonify({'response': completion.choices[0].message.content})
    except Exception as e:
        return jsonify({'error': f"AI request failed: {str(e)}"})

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8080, debug=True)

