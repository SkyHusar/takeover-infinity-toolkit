#!/bin/bash

# Takeover Infinity Toolkit - All-In-One Build Script
# Version: 2.1
# Date: May 18, 2025

echo "Building Takeover Infinity Toolkit Web App and Local Tools on localhost..."

# Define base directory for the toolkit
BASE_DIR="/opt/takeover_infinity"
echo "Setting up toolkit in $BASE_DIR..."

# Check if script is running with sudo privileges (needed for directory creation in /opt)
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root (use sudo) for directory permissions. Exiting..."
    exit 1
fi

# Create directory structure
echo "Creating directory structure..."
mkdir -p $BASE_DIR/{repos/exploits,repos/payloads,repos/vulnerabilities,logs,targets,output,web_panel/static,web_panel/templates,scripts,modules,venv}
chmod -R 755 $BASE_DIR

# Setup virtual environment to avoid system-wide package installation
echo "Setting up virtual environment in $BASE_DIR/venv..."
python3 -m venv $BASE_DIR/venv
source $BASE_DIR/venv/bin/activate

# Install dependencies in virtual environment (stable versions)
echo "Installing required Python packages in virtual environment..."
pip install flask==2.3.2 requests==2.31.0 aiohttp==3.9.1 beautifulsoup4==4.12.2 pandas==2.2.0 numpy==1.26.3 openai==1.12.0

# Create basic configuration file
echo "Creating configuration file..."
mkdir -p $BASE_DIR/config
cat > $BASE_DIR/config/api_keys.conf << EOL
openai_api_key=placeholder_key
cis_db_endpoint=https://global.cis.db/api
cis_db_auth=placeholder_auth
EOL

# Create Web App with Flask
echo "Building Flask Web App for Takeover Infinity Toolkit..."
cat > $BASE_DIR/web_panel/app.py << EOL
from flask import Flask, render_template, request, jsonify
import os
import subprocess
import json

app = Flask(__name__, static_folder='static', template_folder='templates')

# Load configuration
CONFIG_FILE = "$BASE_DIR/config/api_keys.conf"
def load_config():
    config = {}
    with open(CONFIG_FILE, 'r') as f:
        for line in f:
            if '=' in line:
                key, value = line.strip().split('=', 1)
                config[key] = value
    return config

# Home route for dashboard
@app.route('/')
def home():
    tools = os.listdir('$BASE_DIR/modules')
    return render_template('index.html', tools=tools)

# Route to execute a specific module
@app.route('/execute', methods=['POST'])
def execute_module():
    data = request.json
    module = data.get('module')
    target = data.get('target')
    if not module or not target:
        return jsonify({'error': 'Module and target are required'}), 400
    try:
        result = subprocess.run(['python3', f'$BASE_DIR/modules/{module}.py', '--target', target],
                                capture_output=True, text=True, timeout=60)
        return jsonify({'output': result.stdout, 'error': result.stderr})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Route to view logs
@app.route('/logs')
def view_logs():
    log_file = '$BASE_DIR/logs/operation.log'
    with open(log_file, 'r') as f:
        logs = f.read()
    return render_template('logs.html', logs=logs)

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8080, debug=False)
EOL

# Create HTML templates for the web panel
echo "Creating HTML templates for web panel..."
cat > $BASE_DIR/web_panel/templates/index.html << EOL
<!DOCTYPE html>
<html>
<head>
    <title>Takeover Infinity Toolkit v2.1</title>
    <link rel="stylesheet" href="{{ url_for('static', filename='style.css') }}">
</head>
<body>
    <h1>Takeover Infinity Toolkit Dashboard</h1>
    <p>Running on 127.0.0.1:8080</p>
    <h2>Available Tools ({{ tools|length }})</h2>
    <ul>
        {% for tool in tools %}
            <li>{{ tool }} <button onclick="runTool('{{ tool }}')">Run</button></li>
        {% endfor %}
    </ul>
    <div>
        <label for="target">Target:</label>
        <input type="text" id="target" placeholder="e.g., test.target.com">
    </div>
    <div id="output">
        <h3>Output</h3>
        <pre id="output_text"></pre>
    </div>
    <a href="/logs">View Operation Logs</a>
    <script>
        async function runTool(tool) {
            const target = document.getElementById('target').value;
            if (!target) {
                alert('Please enter a target');
                return;
            }
            const response = await fetch('/execute', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({module: tool, target: target})
            });
            const result = await response.json();
            document.getElementById('output_text').textContent = result.output || result.error;
        }
    </script>
</body>
</html>
EOL

cat > $BASE_DIR/web_panel/templates/logs.html << EOL
<!DOCTYPE html>
<html>
<head>
    <title>Operation Logs - Takeover Infinity Toolkit</title>
    <link rel="stylesheet" href="{{ url_for('static', filename='style.css') }}">
</head>
<body>
    <h1>Operation Logs</h1>
    <pre>{{ logs }}</pre>
    <a href="/">Back to Dashboard</a>
</body>
</html>
EOL

# Create basic CSS for web panel
cat > $BASE_DIR/web_panel/static/style.css << EOL
body {
    font-family: Arial, sans-serif;
    margin: 20px;
    background-color: #f4f4f4;
}
h1, h2, h3 {
    color: #333;
}
ul {
    list-style-type: none;
    padding: 0;
}
li {
    margin: 10px 0;
    background: #fff;
    padding: 10px;
    border-radius: 5px;
    display: flex;
    justify-content: space-between;
    align-items: center;
}
button {
    background: #007bff;
    color: white;
    border: none;
    padding: 5px 10px;
    cursor: pointer;
    border-radius: 3px;
}
button:hover {
    background: #0056b3;
}
input {
    padding: 5px;
    width: 300px;
    margin: 10px 0;
}
#output {
    margin-top: 20px;
    background: #fff;
    padding: 10px;
    border-radius: 5px;
}
pre {
    white-space: pre-wrap;
    font-family: monospace;
    background: #e9ecef;
    padding: 10px;
}
a {
    color: #007bff;
    text-decoration: none;
}
a:hover {
    text-decoration: underline;
}
EOL

# Create placeholder scripts for all 38 tools as local modules
echo "Creating placeholder scripts for 38 tools..."
declare -a tools=(
    "BankVaultCracker" "PaymentHijack" "CredentialHarvest" "APIMaster" "DivineLedger"
    "GlobalWireTap" "CreditClone" "StockMarketSiphon" "ATMHackGrid" "CryptoWalletDrain"
    "BlockchainForge" "TaxSystemInfiltrator" "PayrollPuppet" "LoanShark" "InsuranceFraudKit"
    "GovIDStealth" "ElectionRigTool" "SurveillanceSpike" "MilitaryNetProbe" "DiplomaticLeak"
    "PowerGridDisruptor" "WaterSupplyHack" "TrafficChaosEngine" "HealthcareDataRansom"
    "PharmaFormulaTheft" "EduHackPortal" "MediaPropagandaBot" "SocialCreditManipulator"
    "DarkWebBroker" "ZeroDayForge" "RansomwareDeployX" "DDoSStormCloud" "DeepFakeGenerator"
    "VoiceSpoofMaster" "LocationSpoofer" "SmartHomeInvasion" "CorporateEspionageKit"
    "QuantumCrackProto"
)

for tool in "${tools[@]}"; do
    cat > $BASE_DIR/modules/$tool.py << EOL
#!/usr/bin/env python3
import sys
import argparse

def main():
    parser = argparse.ArgumentParser(description='$tool from Takeover Infinity Toolkit')
    parser.add_argument('--target', required=True, help='Target for the tool (e.g., URL or IP)')
    parser.add_argument('--test-mode', action='store_true', help='Run in test mode')
    parser.add_argument('--log', default='$BASE_DIR/logs/operation.log', help='Log file path')
    args = parser.parse_args()
    
    print(f"Running $tool on target: {args.target}")
    with open(args.log, 'a') as f:
        f.write(f"[$tool] Target: {args.target} - Operation simulated on {__import__('datetime').datetime.now()}\\n")
    if args.test_mode:
        print(f"Test mode enabled for $tool")
    return 0

if __name__ == "__main__":
    sys.exit(main())
EOL
    chmod +x $BASE_DIR/modules/$tool.py
done

# Create a main launcher script for CLI usage
echo "Creating CLI launcher script..."
cat > $BASE_DIR/main.py << EOL
#!/usr/bin/env python3
import argparse
import os
import subprocess
import sys

BASE_DIR = "$BASE_DIR"
TOOLS_DIR = f"{BASE_DIR}/modules"
LOG_FILE = f"{BASE_DIR}/logs/operation.log"

def list_tools():
    return [f for f in os.listdir(TOOLS_DIR) if f.endswith('.py')]

def run_tool(tool, target):
    tool_path = f"{TOOLS_DIR}/{tool}.py"
    if not os.path.exists(tool_path):
        print(f"Tool {tool} not found in {TOOLS_DIR}")
        return 1
    result = subprocess.run(['python3', tool_path, '--target', target, '--log', LOG_FILE],
                            capture_output=True, text=True)
    print(result.stdout)
    if result.stderr:
        print(f"Errors: {result.stderr}")
    return result.returncode

def main():
    parser = argparse.ArgumentParser(description='Takeover Infinity Toolkit CLI')
    parser.add_argument('--full-attack', action='store_true', help='Run full attack chain on target')
    parser.add_argument('--target', help='Target for attack (e.g., URL or IP)')
    parser.add_argument('--tool', help='Specific tool to run')
    parser.add_argument('--list-tools', action='store_true', help='List available tools')
    args = parser.parse_args()
    
    if args.list_tools:
        print("Available tools:", list_tools())
        return 0
    if args.full_attack and not args.target:
        print("Target required for full attack. Use --target <target>")
        return 1
    if args.tool and not args.target:
        print("Target required for specific tool. Use --target <target>")
        return 1
    
    if args.full_attack:
        print(f"Running full attack chain on {args.target}...")
        for tool in list_tools():
            run_tool(tool[:-3], args.target)
    elif args.tool:
        return run_tool(args.tool, args.target)
    else:
        print("Use --list-tools to see available tools or specify --full-attack or --tool")
        return 1
    return 0

if __name__ == "__main__":
    sys.exit(main())
EOL
chmod +x $BASE_DIR/main.py

# Instructions to run the web app and CLI tools
echo "Build complete. Instructions to run the toolkit:"
echo "1. Activate virtual environment: source $BASE_DIR/venv/bin/activate"
echo "2. Run web app: python3 $BASE_DIR/web_panel/app.py"
echo "   - Access web panel at http://127.0.0.1:8080"
echo "3. Run CLI tools: python3 $BASE_DIR/main.py --list-tools"
echo "   - Run specific tool: python3 $BASE_DIR/main.py --tool <tool_name> --target <target>"
echo "   - Run full attack: python3 $BASE_DIR/main.py --full-attack --target <target>"
echo "Logs are stored in $BASE_DIR/logs/operation.log"

