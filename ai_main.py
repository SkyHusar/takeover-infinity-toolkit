#!/usr/bin/env python3

# AI Main Script for Takeover Hacking Manifestation Tool
# Location: /opt/takeover-ai/scripts/ai_main.py

import nltk
import spacy
import requests
import subprocess
import tensorflow as tf
from nltk.corpus import stopwords
from sklearn.feature_extraction.text import TfidfVectorizer
from transformers import pipeline

nltk.download('punkt')
nltk.download('stopwords')
nlp = spacy.load("en_core_web_sm")

class TakeoverAI:
    def __init__(self):
        self.generator = pipeline("text-generation", model="gpt2")
        self.vectorizer = TfidfVectorizer()
        self.stop_words = set(stopwords.words('english'))

    def generate_phishing_email(self, target_name, target_domain):
        prompt = f"Compose a phishing email to {target_name} pretending to be IT support from {target_domain} asking for credentials."
        email_content = self.generator(prompt, max_length=200, num_return_sequences=1)[0]['generated_text']
        return email_content

    def analyze_vuln_report(self, nmap_output):
        doc = nlp(nmap_output)
        vulnerabilities = [ent.text for ent in doc.ents if ent.label_ in ["PRODUCT", "VERSION"]]
        return vulnerabilities

    def run_recon(self, target_ip):
        cmd = f"nmap -A {target_ip} -oN /opt/takeover-ai/output/{target_ip}_scan.txt"
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        return result.stdout

    def suggest_exploits(self, vuln_list):
        suggestions = []
        for vuln in vuln_list:
            cmd = f"searchsploit {vuln}"
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
            suggestions.append(f"Exploits for {vuln}:\n{result.stdout}")
        return suggestions

if __name__ == "__main__":
    ai = TakeoverAI()
    print("Takeover Hacking Manifestation AI Tool - AI Module")
    print("1. Generate Phishing Email")
    print("2. Run Nmap Scan and Analyze")
    print("3. Suggest Exploits for Vulnerabilities")
    choice = input("Select an option (1-3): ")

    if choice == "1":
        target_name = input("Enter target name: ")
        target_domain = input("Enter target domain (e.g., company.com): ")
        email = ai.generate_phishing_email(target_name, target_domain)
        print("Generated Phishing Email:")
        print(email)
    elif choice == "2":
        target_ip = input("Enter target IP: ")
        scan_result = ai.run_recon(target_ip)
        vulns = ai.analyze_vuln_report(scan_result)
        print("Detected Vulnerabilities:", vulns)
    elif choice == "3":
        vulns = input("Enter vulnerabilities (comma-separated): ").split(", ")
        exploits = ai.suggest_exploits(vulns)
        for e in exploits:
            print(e)

