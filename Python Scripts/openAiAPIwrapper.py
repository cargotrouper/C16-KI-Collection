import requests
import json


class OpenAIAPIWrapper:
    def __init__(self, base_url, output_file='WrapperOutput.txt'):
        self.base_url = base_url
        self.output_file = output_file

    def ingest(self, file_path):
        url = f"{self.base_url}/v1/ingest"
        files = {'file': open(file_path, 'rb')}
        response = requests.post(url, files=files)
        return response.json()

    def list_ingested(self):
        url = f"{self.base_url}/v1/ingest/list"
        response = requests.get(url)
        return response.json()

    def delete_ingested(self, doc_id):
        url = f"{self.base_url}/v1/ingest/{doc_id}"
        response = requests.delete(url)
        return response.json()

    def completion(self, prompt, use_context=False, context_filter=None, stream=False):
        url = f"{self.base_url}/v1/completions"
        data = {
            "prompt": prompt,
            "use_context": use_context,
            "context_filter": context_filter,
            "stream": stream
        }
        response = requests.post(url, json=data)
        return response.json()

    def chat_completion(self, messages, use_context=False, context_filter=None, stream=False):
        url = f"{self.base_url}/v1/chat/completions"
        data = {
            "messages": messages,
            "use_context": use_context,
            "context_filter": context_filter,
            "stream": stream
        }
        response = requests.post(url, json=data)
        return response.json()

    def chunks_retrieval(self, text, context_filter=None, limit=10, prev_next_chunks=0):
        url = f"{self.base_url}/v1/chunks"
        data = {
            "text": text,
            "context_filter": context_filter,
            "limit": limit,
            "prev_next_chunks": prev_next_chunks
        }
        response = requests.post(url, json=data)
        return response.json()

    def embeddings_generation(self, input_text):
        url = f"{self.base_url}/embeddings"
        data = {"input": input_text}
        response = requests.post(url, json=data)
        return response.json()

    def _save_to_file(self, data):
        with open(self.output_file, 'a') as file:
            file.write(json.dumps(data, indent=4) + '\n\n')

    def execute_action(self, action, **kwargs):
        result = None
        if action == 'ingest':
            result = self.ingest(kwargs.get('file_path'))
        elif action == 'list_ingested':
            result = self.list_ingested()
        elif action == 'delete_ingested':
            result = self.delete_ingested(kwargs.get('doc_id'))
        elif action == 'completion':
            result = self.completion(kwargs.get('prompt'), kwargs.get('use_context', False), kwargs.get('context_filter', None), kwargs.get('stream', False))
        elif action == 'chat_completion':
            result = self.chat_completion(kwargs.get('messages'), kwargs.get('use_context', False), kwargs.get('context_filter', None), kwargs.get('stream', False))
        elif action == 'chunks_retrieval':
            result = self.chunks_retrieval(kwargs.get('text'), kwargs.get('context_filter', None), kwargs.get('limit', 10), kwargs.get('prev_next_chunks', 0))
        elif action == 'embeddings_generation':
            result = self.embeddings_generation(kwargs.get('input_text'))
        else:
            raise ValueError("Unbekannte Aktion")

        self._save_to_file(result)
        return result
    
api = OpenAIAPIWrapper("http://127.0.0.1:8002","WrapperOutput.txt")

# Beispielaufrufe
#response = api.execute_action('ingest', file_path="pfad_zur_datei.pdf")
ingested_docs = api.execute_action('list_ingested')
#delete_response = api.execute_action('delete_ingested', doc_id="dokument_id")
#completion_response = api.execute_action('completion', prompt="Wie brät man ein Ei?")
#chat_response = api.execute_action('chat_completion', messages=[{"role": "user", "content": "Hallo!"}])
#chunks_response = api.execute_action('chunks_retrieval', text="Q3 2023 Verkaufszahlen")
#embeddings_response = api.execute_action('embeddings_generation', input_text="Hallo Welt")
