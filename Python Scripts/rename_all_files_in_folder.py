import os

# Verzeichnispfad
directory = r'C:\Users\mk1\Documents\ki\c16sc\KI\StahlControl Prozeduren'

# Durchlaufen aller Dateien im Verzeichnis
for filename in os.listdir(directory):
    if filename.endswith('.txt'):
        # Voller Pfad der aktuellen Datei
        old_file = os.path.join(directory, filename)

        # Neuer Dateiname mit .txt Endung
        new_file = os.path.join(directory, filename[:-4] + '.prc')

        # Umbenennen der Datei
        os.rename(old_file, new_file)
        print(f"Datei {old_file} wurde umbenannt in {new_file}")
