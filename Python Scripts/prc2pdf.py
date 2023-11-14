from fpdf import FPDF
import os

def convert_text_to_pdf(file_list):
    for file_name in file_list:
        # Überprüfen, ob die Datei eine .prc Datei ist
        if file_name.endswith('.prc'):
            pdf = FPDF()
            pdf.add_page()
            pdf.set_font("Arial", size=12)

            # .prc Datei öffnen und in PDF umwandeln
            try:
                with open(file_name, 'r', encoding='utf-8') as file:
                    for line in file:
                        pdf.cell(200, 10, txt=line, ln=True)

                # PDF-Datei mit dem gewünschten Namen speichern
                new_file_name = f"{os.path.splitext(file_name)[0]}.pdf"
                pdf.output(new_file_name)
                print(f"Datei {file_name} wurde erfolgreich in {new_file_name} umgewandelt.")
            except FileNotFoundError:
                print(f"Datei {file_name} nicht gefunden.")

def read_file_names_from_file(file_name):
    with open(file_name, 'r', encoding='utf-8') as file:
        # Entfernt den Präfix "Datei " und den Zeilenumbruch am Ende jeder Zeile
        return [line.strip().replace('Datei ', '') for line in file]

# Dateinamen aus der Datei 'FailedUploadOutput.txt' lesen
file_list = read_file_names_from_file('FailedUploadOutput.txt')
convert_text_to_pdf(file_list)

#file_list = ["prco1.prc", "proc2.prc"] # Ersetzen Sie dies mit Ihrer eigenen Dateiliste



