def find_filenames_with_500(input_file, output_file, base_path):
    with open(input_file, 'r') as file:
        lines = file.readlines()

    # Extrahieren der Dateinamen aus Zeilen, die am Ende '500' enthalten
    file_names_with_500 = []
    for line in lines:
        if '500' in line:
            parts = line.split(' ')
            if len(parts) > 5:
                file_name = parts[5].rstrip(':')
                full_path = base_path + '\\' + file_name
                file_names_with_500.append(full_path)

    # Schreiben der gefundenen Dateipfade in die Output-Datei, formatiert mit dem Wort "Datei" davor
    with open(output_file, 'w') as file:
        for path in file_names_with_500:
            file.write(f"Datei {path}\n")

# Pfad zur Eingabedatei, bitte anpassen
input_file_path = 'failed.txt'

# Basispfad der Dateien, bitte anpassen
base_path = r'C:\Users\mk1\Documents\ki\c16sc\KI\StahlControl Prozeduren';

# Ausführen der Funktion mit dem Pfad zur Eingabedatei, dem Namen der Ausgabedatei und dem Basispfad der Dateien
find_filenames_with_500(input_file_path, 'FailedUploadOutput.txt', base_path)

print("Vollständige Pfade der Dateien mit '500' am Ende wurden in 'FailedUploadOutput.txt' geschrieben.")
