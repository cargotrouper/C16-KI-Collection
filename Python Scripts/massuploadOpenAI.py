import requests
import os

def send_file_to_api(file_path, url):
    """Sendet eine Datei an die API und gibt die Antwort zurück."""
    with open(file_path, 'rb') as file:
        response = requests.post(url, files={'file': file})
    return response

def log_message(message, file_path):
    """Schreibt eine Nachricht in eine angegebene Log-Datei."""
    with open(file_path, 'a') as file:
        file.write(message + "\n")

def process_directory(directory, api_url, output_file, failed_output_file):
    """Durchläuft alle Dateien im Verzeichnis und sendet sie an die API."""
    for filename in os.listdir(directory):
        file_path = os.path.join(directory, filename)
        if os.path.isfile(file_path):
            response = send_file_to_api(file_path, api_url)
            if response.status_code == 200:
                log_message(f"Datei {filename} erfolgreich gesendet.", output_file)
            elif response.status_code == 500:
                log_message(f"Datei {filename}", failed_output_file)
            else:
                log_message(f"Fehler beim Senden der Datei {filename}: {response.status_code}", output_file)

# Hauptverzeichnis und API-URL
directory = r'C:\Users\mk1\Documents\ki\c16sc\KI\Conzept C16 Handbuch_conv'
api_url = 'http://127.0.0.1:8002/v1/ingest'
output_file = 'UploadOutput.txt'
failed_output_file = 'FailedUploadOutput.txt'

# Verarbeitung starten
process_directory(directory, api_url, output_file, failed_output_file)
