# Source — Georgian Document Assistant

A Georgian-language document search application built with React and FastAPI. Search PDF and text files using keyword matching or local multilingual embeddings, inspect original passages with page references, and optionally generate cited answers through Ollama.

## Version 0.2 status

The quantized multilingual E5-small model runs locally (384-dimensional embeddings). Download it using the setup command below. Generated answers are disabled by default and require a separately installed Ollama model. Generation integration is tested with simulated provider responses; live-model evaluation is not included.

## Run on Windows

Requires Python 3.10+ and Node.js 20.19+.

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r backend/requirements.txt
npm.cmd install
npm.cmd run build
.\.venv\Scripts\python.exe backend/download_model.py
.\.venv\Scripts\python.exe -m uvicorn app:app --app-dir backend --host 127.0.0.1 --port 8000
```

Open http://127.0.0.1:8000. Stop the server with Ctrl+C. No API key is needed.
For UI development run `npm.cmd run dev` in another terminal, alongside the backend, and use the Vite URL.

## როგორ მუშაობს

1. React აგზავნის PDF/TXT ფაილს `POST /api/documents` მისამართზე.
2. Python კითხულობს ტექსტს გვერდების მიხედვით; სკანირებულ PDF-ს OCR ჯერ არ აქვს.
3. ტექსტი იყოფა 60-სიტყვიან ფრაგმენტებად, 15-სიტყვიანი გადაფარვით. ფრაგმენტი გვერდის საზღვარს არ სცდება.
4. შესაძლებელია სიტყვებით ან E5 embedding ვექტორებით ძებნა. E5 იყენებს query/passage პრეფიქსებს, masked mean pooling-ს და ნორმალიზებულ ვექტორებს. კოსინუსური მსგავსებით ბრუნდება მაქსიმუმ სამი ამონარიდი.
5. React აჩვენებს ამონარიდს და გვერდს. დამთხვევის არქონისას სისტემა ამას პირდაპირ ამბობს.

## Limits and privacy

- Keyword mode uses exact word matching; semantic mode can retrieve paraphrases but can also return unrelated passages. Neither proves a question has an answer.
- Semantic mode uses local E5 embeddings. Optional Ollama generation is disabled unless OLLAMA_MODEL is configured. No cloud API is configured.
- Local prototype only. Bind to localhost; do not expose publicly. No user accounts, production isolation or hardened PDF sandbox.
- Maximum upload 10 MB, 200 PDF pages, 1000 chunks, 10 documents. Text and vectors are in process memory. Access expires after one hour; expired entries are removed on a later upload, deletion or process restart. Restart clears all documents.
- TXT is treated as one page. Encrypted and image-only PDFs are rejected. PDF reading order and Unicode extraction depend on the source file.
- The stylesheet requests an optional Georgian font from Google Fonts; document content is never sent there. System fonts are the offline fallback.

## Tests

```powershell
.\.venv\Scripts\python.exe -m unittest discover -s backend -p "test_*.py" -v
```

Tests exercise upload, Georgian matching, missing results, citations, deletion, invalid files and size limits.

## Semantic model and evaluation

Run `python backend/download_model.py` explicitly to download the ONNX weights (approximately 118 MB) and tokenizer. The app reads these files locally and never downloads on a query. User text is not sent to Hugging Face. Inputs are truncated at 512 tokens; very long passages may be partly represented. Vectors are computed lazily on the first semantic question.

Run `python backend/evaluate.py` to regenerate `evaluation.json`. On six handcrafted Georgian smoke cases, **both methods get 4/6 expected outcomes**. E5 finds the password-recovery paraphrase that keyword search misses, but returns opening hours for an unanswerable membership-price question. The short registration question is below the initial threshold. These development examples are not a held-out benchmark or proof of overall improvement. The 0.80 threshold is an initial heuristic, configurable with `SEMANTIC_THRESHOLD`, not an answerability classifier.

## Optional local generated answers

Install Ollama from its official distribution and download a suitable local model separately. Set `$env:OLLAMA_MODEL = 'your-installed-model-name'` before starting the server. The AI checkbox then becomes available. Requests go to `http://127.0.0.1:11434/api/generate`. Use a genuinely local model rather than a cloud-backed model if keeping documents on-device is required.

The adapter requests structured JSON and validates source IDs. A valid citation ID does not prove factual support. Connection failures, invalid citations and malformed output fall back to excerpts with a visible warning. No real generation model has been evaluated in this setup.

## Development

GitHub Actions runs the API tests and frontend build. Runtime environments, downloaded models and secrets are excluded by `.gitignore`. See `LEARNING.md` for a Georgian architecture walkthrough.

References: [E5 model card](https://huggingface.co/intfloat/multilingual-e5-small), [quantized ONNX files](https://huggingface.co/Xenova/multilingual-e5-small/tree/main/onnx) at revision `761b726`, [Ollama generate API](https://docs.ollama.com/api/generate).

## Development notes

Developed with AI coding assistance. Evaluation results and known limitations are documented above.
