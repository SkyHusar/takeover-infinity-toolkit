from bs4 import BeautifulSoup
import requests

def scrape_website(url):
    try:
        response = requests.get(url)
        soup = BeautifulSoup(response.text, 'html.parser')
        text = soup.get_text()
        return extract_backup_phrases(text)
    except Exception as e:
        print(f"Error scraping website {url}: {e}")
        return []

def extract_backup_phrases(text):
    pattern = r'\b(?:[a-zA-Z]+\s+){12,24}[a-zA-Z]+\b'
    matches = re.findall(pattern, text)
    # Further filter to ensure each match has exactly 12-24 words
    phrases = []
    for match in matches:
        if len(match.split()) >= 12 and len(match.split()) <= 24:
            phrases.append(match.strip())
    return phrases

# Replace these URLs with your target websites
urls = [
    "https://pastebin.com/archive",
    "https://www.reddit.com/search/?q=bitcoin+seed+phrase+OR+wallet+backup+OR+12+word+phrase&type=link&sort=new"
]

harvested_phrases = []
for url in urls:
    print(f"Scraping website: {url}")
    phrases = scrape_website(url)
    harvested_phrases.extend(phrases)

print(f"\nTotal backup phrases harvested: {len(harvested_phrases)}")

